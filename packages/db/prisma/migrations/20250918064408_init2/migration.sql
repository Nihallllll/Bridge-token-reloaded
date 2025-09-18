/*
  Warnings:

  - You are about to drop the column `lastBlock` on the `NetworkStatus` table. All the data in the column will be lost.
  - You are about to drop the `Transaction` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `lastProcessedBlock` to the `NetworkStatus` table without a default value. This is not possible if the table is not empty.
  - Changed the type of `network` on the `NetworkStatus` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `network` on the `Nonce` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- CreateEnum
CREATE TYPE "public"."NETWORK" AS ENUM ('BNB', 'Avalanche');

-- AlterTable
ALTER TABLE "public"."NetworkStatus" DROP COLUMN "lastBlock",
ADD COLUMN     "lastProcessedBlock" INTEGER NOT NULL,
DROP COLUMN "network",
ADD COLUMN     "network" "public"."NETWORK" NOT NULL;

-- AlterTable
ALTER TABLE "public"."Nonce" DROP COLUMN "network",
ADD COLUMN     "network" "public"."NETWORK" NOT NULL;

-- DropTable
DROP TABLE "public"."Transaction";

-- DropEnum
DROP TYPE "public"."Network";

-- CreateTable
CREATE TABLE "public"."TransactionData" (
    "id" SERIAL NOT NULL,
    "isDone" BOOLEAN NOT NULL DEFAULT false,
    "tokenAddress" TEXT NOT NULL,
    "amount" TEXT NOT NULL,
    "sender" TEXT NOT NULL,
    "network" TEXT NOT NULL,
    "nonce" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TransactionData_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "NetworkStatus_network_key" ON "public"."NetworkStatus"("network");

-- CreateIndex
CREATE UNIQUE INDEX "Nonce_network_key" ON "public"."Nonce"("network");
