import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { FriendsService } from './friends.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SendFriendRequestDto } from './dto/friend-request.dto';

@UseGuards(JwtAuthGuard)
@Controller('friends')
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  // GET /friends/search?query=xxx
  @Get('search')
  searchUsers(@Query('query') query: string, @Request() req) {
    return this.friendsService.searchUsers(query, req.user.id);
  }

  // GET /friends/recommendations
  @Get('recommendations')
  getRecommendations(@Request() req) {
    return this.friendsService.getRecommendations(req.user.id);
  }

  // GET /friends/requests
  @Get('requests')
  getIncomingRequests(@Request() req) {
    return this.friendsService.getIncomingRequests(req.user.id);
  }

  // GET /friends/status/:targetUserId
  @Get('status/:targetUserId')
  getFriendshipStatus(
    @Param('targetUserId', ParseIntPipe) targetUserId: number,
    @Request() req,
  ) {
    return this.friendsService.getFriendshipStatus(req.user.id, targetUserId);
  }

  // GET /friends
  @Get()
  getFriends(@Request() req) {
    return this.friendsService.getFriends(req.user.id);
  }

  // POST /friends/request
  @Post('request')
  sendRequest(@Body() dto: SendFriendRequestDto, @Request() req) {
    return this.friendsService.sendRequest(req.user.id, dto.receiverId);
  }

  // PATCH /friends/request/:id/accept
  @Patch('request/:id/accept')
  acceptRequest(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.friendsService.acceptRequest(id, req.user.id);
  }

  // DELETE /friends/request/:id/reject
  @Delete('request/:id/reject')
  rejectRequest(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.friendsService.rejectRequest(id, req.user.id);
  }

  // DELETE /friends/:friendId
  @Delete(':friendId')
  unfriend(
    @Param('friendId', ParseIntPipe) friendId: number,
    @Request() req,
  ) {
    return this.friendsService.unfriend(req.user.id, friendId);
  }
}