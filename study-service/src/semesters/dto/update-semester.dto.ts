import { IsOptional, IsString } from 'class-validator';

export class UpdateSemesterDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  coverUrl?: string;
}