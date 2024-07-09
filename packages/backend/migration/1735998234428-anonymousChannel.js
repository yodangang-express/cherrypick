/*
 * SPDX-FileCopyrightText: syuilo and misskey-project
 * SPDX-License-Identifier: AGPL-3.0-only
 */

export class anonymousChannel1735998234428 {
  name = 'anonymousChannel1735998234428'

  async up(queryRunner) {
    await queryRunner.query(`ALTER TABLE "channel" ADD "anonymous" boolean DEFAULT false`);
  }

  async down(queryRunner) {
    await queryRunner.query(`ALTER TABLE "channel" DROP COLUMN "anonymous"`);
  }
}
