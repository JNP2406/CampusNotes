import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { createProxyMiddleware } from 'http-proxy-middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const expressApp = app.getHttpAdapter().getInstance();

  // Proxy /upload ke study-service
  expressApp.use('/upload', createProxyMiddleware({
    target: 'http://localhost:3002',
    changeOrigin: true,
  }));

  // Proxy /uploads ke study-service
  expressApp.use('/uploads', createProxyMiddleware({
    target: 'http://localhost:3002',
    changeOrigin: true,
  }));

  const config = new DocumentBuilder()
    .setTitle('SA Project API Gateway')
    .setDescription('API Gateway for Auth Service and Study Service')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(3000);
}
bootstrap();