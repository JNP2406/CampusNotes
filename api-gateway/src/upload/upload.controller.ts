import {
  Controller,
  Post,
  Headers,
  Body,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Upload')
@ApiBearerAuth()
@Controller('upload')
export class UploadController {
  constructor(private httpService: HttpService) {}

  private readonly studyUrl = 'http://localhost:3002';

  @ApiOperation({ summary: 'Upload file' })
  @Post()
  async upload(
    @Headers('authorization') auth: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.studyUrl}/upload`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}