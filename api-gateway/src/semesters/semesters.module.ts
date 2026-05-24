import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { SemestersController } from './semesters.controller';

@Module({
  imports: [HttpModule],
  controllers: [SemestersController],
})
export class SemestersModule {}