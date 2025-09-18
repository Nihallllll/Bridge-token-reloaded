import { Contract, JsonRpcProvider, Wallet, Interface } from "ethers";
import Bull from "bull";
import dotenv from "dotenv";
import { abi } from  "./abi";
import { prisma } from "db/clients";

dotenv.config();



const providerSEPOLIA = new JsonRpcProvider(process.env.SEPOLIA_RPC);
const providerHOLESKY = new JsonRpcProvider(process.env.HOLESKY_RPC);

const contractBNB = new Contract(
  process.env.BRIDGE_CONTRACT_ADDRESS_SEPOLIA!,
  abi,
  providerSEPOLIA
);
const contractAVA = new Contract(
  process.env.BRIDGE_CONTRACT_ADDRESS_HOLESKY!,
  abi,
  providerHOLESKY
);

const redisConfig = {
  redis: {
    host: process.env.REDIS_HOST || "127.0.0.1",
    port: parseInt(process.env.REDIS_PORT || "6379", 10),
    password: process.env.REDIS_PASSWORD || "",
  },
};
const bridgeQueue = new Bull("bridgeQueue", redisConfig);

const bridgeInterface = new Interface(abi);

const listenToBridgeEvents = async (
  provider: JsonRpcProvider,
  contract: Contract,
  network: "SEPOLIA" | "HOLESKY"
) => {
  try {
    let lastProcessedBlock = await prisma.networkStatus.findUnique({
      where: { network },
    });
    const latestBlock = await provider.getBlockNumber();

    if (!lastProcessedBlock) {
      const data = await prisma.networkStatus.create({
        data: { network, lastProcessedBlock: latestBlock },
      });
      lastProcessedBlock = { ...data };
    }

    if (lastProcessedBlock.lastProcessedBlock >= latestBlock) {
      return;
    }

    const filter = contract.filters.Bridge();
    const logs = await provider.getLogs({
      ...filter,
      fromBlock: lastProcessedBlock.lastProcessedBlock + 1,
      toBlock: "latest",
    });

    logs.forEach(async (log) => {
      const parsedLog = bridgeInterface.parseLog(log);

      if (parsedLog) {
        const txhash = log.transactionHash;
        const tokenAddress = parsedLog.args[0].toString();
        const amount = parsedLog.args[1].toString();
        const sender = parsedLog.args[2].toString();

        bridgeQueue.add({
          txhash: txhash.toLowerCase(),
          tokenAddress: tokenAddress,
          amount: amount,
          sender: sender,
          network,
        });
      }
    });

    await prisma.networkStatus.update({
      where: { network },
      data: { lastProcessedBlock: latestBlock },
    });
  } catch (error) {
    throw error;
  }
};

// Set up polling listeners
setInterval(() => listenToBridgeEvents(providerBNB, contractBNB, "SEPOLIA"), 5000);
setInterval(
  () => listenToBridgeEvents(providerAVA, contractAVA, "HOLESKY"),
  5000
);

bridgeQueue.process(async (job) => {
  const { txhash, tokenAddress, amount, sender, network } = job.data;

  try {
    let transaction = await prisma.transactionData.findUnique({
      where: { txHash: txhash },
    });

    if (!transaction) {
      const nonceRecord = await prisma.nonce.upsert({
        where: { network },
        update: { nonce: { increment: 1 } },
        create: { network, nonce: 1 },
      });

      transaction = await prisma.transactionData.create({
        data: {
          txHash: txhash,
          tokenAddress,
          amount,
          sender,
          network,
          isDone: false,
          nonce: nonceRecord.nonce,
        },
      });
    }

    if (transaction.isDone) {
      return { success: true, message: "Transaction already processed" };
    }

    await transferToken(network === "SEPOLIA", amount, sender, transaction.nonce);
    await prisma.transactionData.update({
      where: { txHash: txhash },
      data: { isDone: true },
    });

    return { success: true };
  } catch (error) {
    throw error;
  }
});

const transferToken = async (
  isSepolia: boolean,
  amount: string,
  sender: string,
  nonce: number
) => {
  try {
    const RPC = !isSepolia ? process.env.SEPOLIA_RPC : process.env.HOLESKY_RPC;
    const pk = process.env.PK!;
    const contractAddress = !isSepolia
      ? process.env.BRIDGE_CONTRACT_ADDRESS_SEPOLIA!
      : process.env.BRIDGE_CONTRACT_ADDRESS_HOLESKY!;

    const provider = new JsonRpcProvider(RPC);
    const wallet = new Wallet(pk, provider);
    const contractInstance = new Contract(contractAddress, abi, wallet);

    const testToken = !isSepolia
      ? process.env.TESTTOKEN_SEPOLIA!
      : process.env.TESTTOKEN_HOLESKY!;

    const tx = await contractInstance.redeem(testToken, sender, amount, nonce);
    await tx.wait();
  } catch (error) {
    throw error;
  }
};
