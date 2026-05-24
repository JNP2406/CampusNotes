import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards } from '@nestjs/common';
import { SemestersService } from './semesters.service';
import { CreateSemesterDto } from './dto/create-semester.dto';
import { UpdateSemesterDto } from './dto/update-semester.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('semesters')
export class SemestersController {
  constructor(private semestersService: SemestersService) {}

  @Post()
  create(@Request() req, @Body() dto: CreateSemesterDto) {
    return this.semestersService.create(req.user.id, dto);
  }

  @Get()
  findAll(@Request() req) {
    return this.semestersService.findAll(req.user.id);
  }

  @Get('friend/:friendId')
  findFriendSemesters(@Param('friendId') friendId: string, @Request() req) {
    const token = req.headers.authorization;
    return this.semestersService.findFriendSemesters(req.user.id, +friendId, token);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.semestersService.findOne(+id, req.user.id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Request() req, @Body() dto: UpdateSemesterDto) {
    return this.semestersService.update(+id, req.user.id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.semestersService.remove(+id, req.user.id);
  }
}