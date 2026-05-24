import { Controller, Get, Put, Body, Request, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getMe(@Request() req) {
    return this.usersService.findById(req.user.id);
  }

  @Put('me')
  updateMe(@Request() req, @Body() body: {
    username?: string;
    binusian?: string;
    major?: string;
    regionCampus?: string;
    avatarUrl?: string;
  }) {
    return this.usersService.update(req.user.id, body);
  }
}