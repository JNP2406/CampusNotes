import { IsOptional, IsString, IsBoolean } from 'class-validator';

export class UpdateFileDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  fileUrl?: string;

  @IsOptional()
  @IsString()
  fileType?: string;

  @IsOptional()
  @IsBoolean()
  isShared?: boolean;
}