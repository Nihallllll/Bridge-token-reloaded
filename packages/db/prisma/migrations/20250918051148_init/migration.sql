-- CreateEnum
CREATE TYPE "public"."Network" AS ENUM ('Sepolia', 'Holesky');

-- CreateTable
CREATE TABLE "public"."Transaction" (
    "id" SERIAL NOT NULL,
    "txhash" TEXT NOT NULL,
    "isDone" BOOLEAN NOT NULL DEFAULT false,
    "amount" TEXT NOT NULL,
    "sender" TEXT NOT NULL,
    "nonce" INTEGER NOT NULL,
    "network" TEXT NOT NULL,
    "tokenAddress" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."NetworkStatus" (
    "id" SERIAL NOT NULL,
    "network" "public"."Network" NOT NULL,
    "lastBlock" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "NetworkStatus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Nonce" (
    "id" SERIAL NOT NULL,
    "nonce" INTEGER NOT NULL DEFAULT 0,
    "network" "public"."Network" NOT NULL,

    CONSTRAINT "Nonce_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_txhash_key" ON "public"."Transaction"("txhash");

-- CreateIndex
CREATE UNIQUE INDEX "NetworkStatus_network_key" ON "public"."NetworkStatus"("network");

-- CreateIndex
CREATE UNIQUE INDEX "Nonce_network_key" ON "public"."Nonce"("network");
