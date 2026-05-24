import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AuthController } from './auth.controller';
import { UsersController } from './users.controller';

@Module({
  imports: [HttpModule],
  controllers: [AuthController, UsersController],
})
export class AuthModule {}