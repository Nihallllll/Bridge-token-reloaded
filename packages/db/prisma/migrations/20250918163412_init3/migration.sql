/*
  Warnings:

  - A unique constraint covering the columns `[txhash]` on the table `TransactionData` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `txhash` to the `TransactionData` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "public"."TransactionData" ADD COLUMN     "txhash" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "TransactionData_txhash_key" ON "public"."TransactionData"("txhash");
