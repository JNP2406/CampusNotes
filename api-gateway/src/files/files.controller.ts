import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  Headers,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Files')
@ApiBearerAuth()
@Controller('files')
export class FilesController {
  constructor(private httpService: HttpService) {}

  private readonly studyUrl = 'http://localhost:3002';

  @ApiOperation({ summary: 'Get all files' })
  @Get()
  async getFiles(
    @Headers('authorization') auth: string,
    @Query('courseId') courseId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(
        `${this.studyUrl}/files?courseId=${courseId}`,
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get friend files' })
  @Get('friend/:friendId')
  async getFriendFiles(
    @Headers('authorization') auth: string,
    @Param('friendId') friendId: string,
    @Query('courseId') courseId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(
        `${this.studyUrl}/files/friend/${friendId}?courseId=${courseId}`,
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get file by id' })
  @Get(':id')
  async getFile(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.studyUrl}/files/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Create file' })
  @Post()
  async createFile(
    @Headers('authorization') auth: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.studyUrl}/files`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Update file' })
  @Put(':id')
  async updateFile(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.put(`${this.studyUrl}/files/${id}`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Delete file' })
  @Delete(':id')
  async deleteFile(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.delete(`${this.studyUrl}/files/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}