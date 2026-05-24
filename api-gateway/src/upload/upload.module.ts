import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { StaticController } from './static.controller';

@Module({
  imports: [HttpModule],
  controllers: [StaticController],
})
export class UploadModule {}