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

@ApiTags('Courses')
@ApiBearerAuth()
@Controller('courses')
export class CoursesController {
  constructor(private httpService: HttpService) {}

  private readonly studyUrl = 'http://localhost:3002';

  @ApiOperation({ summary: 'Get all courses' })
  @Get()
  async getCourses(
    @Headers('authorization') auth: string,
    @Query('semesterId') semesterId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(
        `${this.studyUrl}/courses?semesterId=${semesterId}`,
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get friend courses' })
  @Get('friend/:friendId')
  async getFriendCourses(
    @Headers('authorization') auth: string,
    @Param('friendId') friendId: string,
    @Query('semesterId') semesterId: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(
        `${this.studyUrl}/courses/friend/${friendId}?semesterId=${semesterId}`,
        { headers: { Authorization: auth } },
      ),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Get course by id' })
  @Get(':id')
  async getCourse(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.get(`${this.studyUrl}/courses/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Create course' })
  @Post()
  async createCourse(
    @Headers('authorization') auth: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.post(`${this.studyUrl}/courses`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Update course' })
  @Put(':id')
  async updateCourse(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    const response = await firstValueFrom(
      this.httpService.put(`${this.studyUrl}/courses/${id}`, body, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }

  @ApiOperation({ summary: 'Delete course' })
  @Delete(':id')
  async deleteCourse(
    @Headers('authorization') auth: string,
    @Param('id') id: string,
  ) {
    const response = await firstValueFrom(
      this.httpService.delete(`${this.studyUrl}/courses/${id}`, {
        headers: { Authorization: auth },
      }),
    );
    return response.data;
  }
}