import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class CoursesService {
  constructor(
    private prisma: PrismaService,
    private httpService: HttpService,
    private configService: ConfigService,
  ) {}

  private async verifyFriendship(userId: number, friendId: number, token: string) {
    const authServiceUrl = this.configService.get('AUTH_SERVICE_URL') || 'http://localhost:3000';
    const response = await firstValueFrom(
      this.httpService.get(`${authServiceUrl}/friends/status/${friendId}`, {
        headers: { Authorization: token },
      }),
    );
    if (response.data.status !== 'friends') {
      throw new ForbiddenException('You are not friends with this user');
    }
  }

  async create(userId: number, dto: CreateCourseDto) {
    return this.prisma.course.create({
      data: { ...dto, userId },
    });
  }

  async findAll(userId: number, semesterId: number) {
    return this.prisma.course.findMany({
      where: { userId, semesterId },
      include: { files: true },
    });
  }

  async findOne(id: number, userId: number) {
    return this.prisma.course.findFirst({
      where: { id, userId },
      include: { files: true },
    });
  }

  async update(id: number, userId: number, dto: UpdateCourseDto) {
    return this.prisma.course.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number, userId: number) {
    return this.prisma.course.delete({
      where: { id },
    });
  }

  // Lihat courses milik teman
  async findFriendCourses(currentUserId: number, friendId: number, semesterId: number, token: string) {
    await this.verifyFriendship(currentUserId, friendId, token);
    return this.prisma.course.findMany({
      where: { userId: friendId, semesterId },
      include: { files: true },
    });
  }
}