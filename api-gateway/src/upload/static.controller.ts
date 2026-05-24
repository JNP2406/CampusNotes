import { Controller, Get, Param, Res } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import type { Response } from 'express';

@Controller('uploads')
export class StaticController {
  constructor(private httpService: HttpService) {}

  private readonly studyUrl = 'http://localhost:3002';

  @Get('*')
  async getFile(@Param('0') filename: string, @Res() res: Response) {
    try {
      const response = await firstValueFrom(
        this.httpService.get(`${this.studyUrl}/uploads/${filename}`, {
          responseType: 'arraybuffer',
        }),
      );
      const contentType = (response.headers['content-type'] as string) || 'application/octet-stream';
      res.set('Content-Type', contentType);
      res.send(response.data);
    } catch (e) {
      res.status(404).json({ message: 'File not found' });
    }
  }
}