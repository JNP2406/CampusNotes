import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Headers,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Friends')
@ApiBearerAuth()
@Controller('friends')
export class FriendsController {
  constructor(private httpService: HttpService) {}

  private readonly authUrl = 'http://localhost:3001';

  @ApiOperation({ summary: 'Get friends list' })
  @Get()
  async getFriends(@Headers('authorization') auth: string) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/friends`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get incoming friend requests' })
  @Get('requests')
  async getRequests(@Headers('authorization') auth: string) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/friends/requests`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Search users' })
  @Get('search')
  async searchUsers(
    @Headers('authorization') auth: string,
    @Query('query') query: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/friends/search?query=${query}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get friend recommendations' })
  @Get('recommendations')
  async getRecommendations(@Headers('authorization') auth: string) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/friends/recommendations`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get friendship status' })
  @Get('status/:targetUserId')
  async getFriendshipStatus(
    @Headers('authorization') auth: string,
    @Param('targetUserId') targetUserId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/friends/status/${targetUserId}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Send friend request' })
  @Post('request')
  async sendRequest(
    @Headers('authorization') auth: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.authUrl}/friends/request`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Accept friend request' })
  @Patch('request/:id/accept')
  async acceptRequest(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.patch(
        `${this.authUrl}/friends/request/${id}/accept`,
        {},
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Reject friend request' })
  @Delete('request/:id/reject')
  async rejectRequest(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.delete(
        `${this.authUrl}/friends/request/${id}/reject`,
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Unfriend' })
  @Delete(':friendId')
  async unfriend(
    @Headers('authorization') auth: string,
    @Param('friendId') friendId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.delete(`${this.authUrl}/friends/${friendId}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}