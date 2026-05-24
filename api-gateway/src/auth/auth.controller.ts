import { Controller, Post, Body } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private httpService: HttpService) {}

  private readonly authUrl = 'http://localhost:3001';

  @ApiOperation({ summary: 'Register user' })
  @Post('register')
  async register(@Body() body: RegisterDto) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.authUrl}/auth/register`, body),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Login user' })
  @Post('login')
  async login(@Body() body: LoginDto) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.authUrl}/auth/login`, body),
    );
    return response.data;
  }
}