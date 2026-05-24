import { Controller, Get, Post, Put, Delete, Body, Param, Request, Query, UseGuards } from '@nestjs/common';
import { CoursesService } from './courses.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('courses')
export class CoursesController {
  constructor(private coursesService: CoursesService) {}

  @Post()
  create(@Request() req, @Body() dto: CreateCourseDto) {
    return this.coursesService.create(req.user.id, dto);
  }

  @Get()
  findAll(@Request() req, @Query('semesterId') semesterId: string) {
    return this.coursesService.findAll(req.user.id, +semesterId);
  }

  // Lihat courses milik teman
  @Get('friend/:friendId')
  findFriendCourses(
    @Param('friendId') friendId: string,
    @Query('semesterId') semesterId: string,
    @Request() req,
  ) {
    const token = req.headers.authorization;
    return this.coursesService.findFriendCourses(req.user.id, +friendId, +semesterId, token);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.coursesService.findOne(+id, req.user.id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Request() req, @Body() dto: UpdateCourseDto) {
    return this.coursesService.update(+id, req.user.id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.coursesService.remove(+id, req.user.id);
  }
}