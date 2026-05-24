import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateSemesterDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  coverUrl?: string;
}