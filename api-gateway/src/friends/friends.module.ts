import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { FriendsController } from './friends.controller';

@Module({
  imports: [HttpModule],
  controllers: [FriendsController],
})
export class FriendsModule {}