/*
  Warnings:

  - The values [BNB,Avalanche] on the enum `NETWORK` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "public"."NETWORK_new" AS ENUM ('SEPOLIA', 'HOLESKY');
ALTER TABLE "public"."NetworkStatus" ALTER COLUMN "network" TYPE "public"."NETWORK_new" USING ("network"::text::"public"."NETWORK_new");
ALTER TABLE "public"."Nonce" ALTER COLUMN "network" TYPE "public"."NETWORK_new" USING ("network"::text::"public"."NETWORK_new");
ALTER TYPE "public"."NETWORK" RENAME TO "NETWORK_old";
ALTER TYPE "public"."NETWORK_new" RENAME TO "NETWORK";
DROP TYPE "public"."NETWORK_old";
COMMIT;
