import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateSemesterDto } from './dto/create-semester.dto';
import { UpdateSemesterDto } from './dto/update-semester.dto';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SemestersService {
  constructor(
    private prisma: PrismaService,
    private httpService: HttpService,
    private configService: ConfigService,
  ) {}

  // Verifikasi apakah 2 user berteman via auth-service
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

  async create(userId: number, dto: CreateSemesterDto) {
    return this.prisma.semester.create({
      data: { ...dto, userId },
    });
  }

  async findAll(userId: number) {
    return this.prisma.semester.findMany({
      where: { userId },
      include: { courses: true },
    });
  }

  async findOne(id: number, userId: number) {
    return this.prisma.semester.findFirst({
      where: { id, userId },
      include: { courses: true },
    });
  }

  async update(id: number, userId: number, dto: UpdateSemesterDto) {
    return this.prisma.semester.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number, userId: number) {
    return this.prisma.semester.delete({
      where: { id },
    });
  }

  // Lihat semester milik teman
  async findFriendSemesters(currentUserId: number, friendId: number, token: string) {
    await this.verifyFriendship(currentUserId, friendId, token);
    return this.prisma.semester.findMany({
      where: { userId: friendId },
      include: { courses: true },
    });
  }
}