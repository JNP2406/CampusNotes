import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Headers,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Semesters')
@ApiBearerAuth()
@Controller('semesters')
export class SemestersController {
  constructor(private httpService: HttpService) {}

  private readonly studyUrl = 'http://localhost:3002';

  @ApiOperation({ summary: 'Get all semesters' })
  @Get()
  async getSemesters(@Headers('authorization') auth: string) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.studyUrl}/semesters`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get friend semesters' })
  @Get('friend/:friendId')
  async getFriendSemesters(
    @Headers('authorization') auth: string,
    @Param('friendId') friendId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.studyUrl}/semesters/friend/${friendId}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get semester by id' })
  @Get(':id')
  async getSemester(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.studyUrl}/semesters/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Create semester' })
  @Post()
  async createSemester(
    @Headers('authorization') auth: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.studyUrl}/semesters`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Update semester' })
  @Put(':id')
  async updateSemester(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.put(`${this.studyUrl}/semesters/${id}`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Delete semester' })
  @Delete(':id')
  async deleteSemester(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.delete(`${this.studyUrl}/semesters/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}