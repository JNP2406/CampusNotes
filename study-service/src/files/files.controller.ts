import { Controller, Get, Post, Put, Delete, Body, Param, Request, Query, UseGuards } from '@nestjs/common';
import { FilesService } from './files.service';
import { CreateFileDto } from './dto/create-file.dto';
import { UpdateFileDto } from './dto/update-file.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('files')
export class FilesController {
  constructor(private filesService: FilesService) {}

  @Post()
  create(@Request() req, @Body() dto: CreateFileDto) {
    return this.filesService.create(req.user.id, dto);
  }

  @Get()
  findAll(@Request() req, @Query('courseId') courseId: string) {
    return this.filesService.findAll(req.user.id, +courseId);
  }

  @Get('shared')
  findShared() {
    return this.filesService.findShared();
  }

  // Lihat files milik teman
  @Get('friend/:friendId')
  findFriendFiles(
    @Param('friendId') friendId: string,
    @Query('courseId') courseId: string,
    @Request() req,
  ) {
    const token = req.headers.authorization;
    return this.filesService.findFriendFiles(req.user.id, +friendId, +courseId, token);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.filesService.findOne(+id, req.user.id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Request() req, @Body() dto: UpdateFileDto) {
    return this.filesService.update(+id, req.user.id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.filesService.remove(+id, req.user.id);
  }
}