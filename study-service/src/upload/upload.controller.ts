import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';

import { FileInterceptor } from '@nestjs/platform-express';

import { diskStorage } from 'multer';

import { extname } from 'path';

@Controller('upload')
export class UploadController {
  @Post()
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',

        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() +
            '-' +
            Math.round(Math.random() * 1e9);

          cb(
            null,
            uniqueSuffix +
              extname(file.originalname),
          );
        },
      }),

      // Allow multiple file types
      fileFilter: (req, file, cb) => {
  console.log(file.mimetype);
  cb(null, true);
},

      // Max 10 MB
      limits: {
        fileSize: 10 * 1024 * 1024,
      },
    }),
  )
  uploadFile(
    @UploadedFile()
    file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException(
        'No file uploaded',
      );
    }

    return {
      message: 'File uploaded successfully',
      url: `/uploads/${file.filename}`,
      fileName: file.originalname,
      fileType: file.mimetype,
    };
  }
}