import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateFileDto } from './dto/create-file.dto';
import { UpdateFileDto } from './dto/update-file.dto';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class FilesService {
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

  async create(userId: number, dto: CreateFileDto) {
    return this.prisma.file.create({
      data: { ...dto, userId },
    });
  }

  async findAll(userId: number, courseId: number) {
    return this.prisma.file.findMany({
      where: { userId, courseId },
    });
  }

  async findShared() {
    return this.prisma.file.findMany({
      where: { isShared: true },
    });
  }

  async findOne(id: number, userId: number) {
    return this.prisma.file.findFirst({
      where: { id, userId },
    });
  }

  async update(id: number, userId: number, dto: UpdateFileDto) {
    return this.prisma.file.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number, userId: number) {
    return this.prisma.file.delete({
      where: { id },
    });
  }

  // Lihat files milik teman
  async findFriendFiles(currentUserId: number, friendId: number, courseId: number, token: string) {
    await this.verifyFriendship(currentUserId, friendId, token);
    return this.prisma.file.findMany({
      where: { userId: friendId, courseId },
    });
  }
}