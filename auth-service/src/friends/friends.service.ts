import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class FriendsService {
  constructor(private prisma: PrismaService) {}

  // Kirim friend request
  async sendRequest(senderId: number, receiverId: number) {
    if (senderId === receiverId) {
      throw new BadRequestException('Cannot send request to yourself');
    }

    const alreadyFriend = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId: senderId, friendId: receiverId },
          { userId: receiverId, friendId: senderId },
        ],
      },
    });
    if (alreadyFriend) {
      throw new BadRequestException('Already friends');
    }

    const existing = await this.prisma.friendRequest.findFirst({
      where: {
        OR: [
          { senderId, receiverId },
          { senderId: receiverId, receiverId: senderId },
        ],
      },
    });
    if (existing) {
      throw new BadRequestException('Friend request already exists');
    }

    return this.prisma.friendRequest.create({
      data: { senderId, receiverId, status: 'pending' },
    });
  }

  // Lihat incoming requests
  async getIncomingRequests(userId: number) {
    return this.prisma.friendRequest.findMany({
      where: { receiverId: userId, status: 'pending' },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            email: true,
            avatarUrl: true,
            binusian: true,
            major: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // Accept friend request
  async acceptRequest(requestId: number, userId: number) {
    const request = await this.prisma.friendRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) throw new NotFoundException('Request not found');
    if (request.receiverId !== userId) {
      throw new BadRequestException('Not authorized');
    }
    if (request.status !== 'pending') {
      throw new BadRequestException('Request already handled');
    }

    await this.prisma.friendRequest.update({
      where: { id: requestId },
      data: { status: 'accepted' },
    });

    await this.prisma.friend.createMany({
      data: [
        { userId: request.senderId, friendId: request.receiverId },
        { userId: request.receiverId, friendId: request.senderId },
      ],
    });

    return { message: 'Friend request accepted' };
  }

  // Reject friend request
  async rejectRequest(requestId: number, userId: number) {
    const request = await this.prisma.friendRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) throw new NotFoundException('Request not found');
    if (request.receiverId !== userId) {
      throw new BadRequestException('Not authorized');
    }

    await this.prisma.friendRequest.delete({
      where: { id: requestId },
    });

    return { message: 'Friend request rejected' };
  }

  // List semua teman
  async getFriends(userId: number) {
    return this.prisma.friend.findMany({
      where: { userId },
      include: {
        friend: {
          select: {
            id: true,
            username: true,
            email: true,
            avatarUrl: true,
            binusian: true,
            major: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // Unfriend
  async unfriend(userId: number, friendId: number) {
    await this.prisma.friend.deleteMany({
      where: {
        OR: [
          { userId, friendId },
          { userId: friendId, friendId: userId },
        ],
      },
    });

    return { message: 'Unfriended successfully' };
  }

  // Search user
  async searchUsers(query: string, currentUserId: number) {
    return this.prisma.user.findMany({
      where: {
        AND: [
          { id: { not: currentUserId } },
          {
            OR: [
              { username: { contains: query } },
              { email: { contains: query } },
            ],
          },
        ],
      },
      select: {
        id: true,
        username: true,
        email: true,
        avatarUrl: true,
        binusian: true,
        major: true,
      },
      take: 10,
    });
  }

  // Cek status pertemanan
  async getFriendshipStatus(currentUserId: number, targetUserId: number) {
    const friend = await this.prisma.friend.findFirst({
      where: { userId: currentUserId, friendId: targetUserId },
    });
    if (friend) return { status: 'friends' };

    const sentRequest = await this.prisma.friendRequest.findFirst({
      where: { senderId: currentUserId, receiverId: targetUserId, status: 'pending' },
    });
    if (sentRequest) return { status: 'pending_sent', requestId: sentRequest.id };

    const receivedRequest = await this.prisma.friendRequest.findFirst({
      where: { senderId: targetUserId, receiverId: currentUserId, status: 'pending' },
    });
    if (receivedRequest) return { status: 'pending_received', requestId: receivedRequest.id };

    return { status: 'not_friends' };
  }

  // Rekomendasi teman
  async getRecommendations(currentUserId: number) {
    const friendIds = await this.prisma.friend.findMany({
      where: { userId: currentUserId },
      select: { friendId: true },
    });

    const friendIdList = friendIds.map((f) => f.friendId);
    friendIdList.push(currentUserId);

    return this.prisma.user.findMany({
      where: { id: { notIn: friendIdList } },
      select: {
        id: true,
        username: true,
        email: true,
        avatarUrl: true,
        binusian: true,
        major: true,
      },
      take: 5,
    });
  }
}