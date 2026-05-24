import { Controller, Get, Put, Body, Headers } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private httpService: HttpService) {}

  private readonly authUrl = 'http://localhost:3001';

  @ApiOperation({ summary: 'Get my profile' })
  @Get('me')
  async getMe(@Headers('authorization') auth: string) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.authUrl}/users/me`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Update my profile' })
  @Put('me')
  async updateMe(@Headers('authorization') auth: string, @Body() body: any) {
    const response = await firstValueFrom(
      this.httpService.put(`${this.authUrl}/users/me`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}