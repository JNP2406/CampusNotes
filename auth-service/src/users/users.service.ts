import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findById(id: number) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async create(data: {
    username: string;
    email: string;
    password: string;
    binusian?: string;
    major?: string;
    regionCampus?: string;
  }) {
    return this.prisma.user.create({ data });
  }

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        username: true,
        email: true,
        binusian: true,
        major: true,
        regionCampus: true,
        avatarUrl: true,
      },
    });
  }

  async update(id: number, data: Partial<{
    username: string;
    binusian: string;
    major: string;
    regionCampus: string;
    avatarUrl: string;
    coverUrl: string;
  }>) {
    return this.prisma.user.update({ where: { id }, data });
  }
}