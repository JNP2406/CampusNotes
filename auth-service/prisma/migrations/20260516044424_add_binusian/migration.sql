/*
  Warnings:

  - You are about to drop the column `revision` on the `user` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE `user` DROP COLUMN `revision`,
    ADD COLUMN `binusian` VARCHAR(191) NULL;
