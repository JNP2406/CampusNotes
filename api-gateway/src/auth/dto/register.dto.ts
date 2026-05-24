import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'johndoe' })
  username!: string;

  @ApiProperty({ example: 'john@example.com' })
  email!: string;

  @ApiProperty({ example: 'password123' })
  password!: string;

  @ApiProperty({ example: 'B28', required: false })
  binusian?: string;

  @ApiProperty({ example: 'Computer Science', required: false })
  major?: string;

  @ApiProperty({ example: 'Alam Sutera', required: false })
  regionCampus?: string;
}