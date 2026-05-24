import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { CoursesController } from './courses.controller';

@Module({
  imports: [HttpModule],
  controllers: [CoursesController],
})
export class CoursesModule {}