import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/nvidia_ai_service.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;
  late NvidiaImageService service;
  const request = GenerationRequest(
    prompt: 'A calm mountain sunrise',
    style: 'dogal',
    width: 1080,
    height: 1920,
  );

  setUp(() {
    mockDioClient = MockDioClient();
    service = NvidiaImageService(
      dioClient: mockDioClient,
      apiKey: 'test-key',
      model: 'black-forest-labs/flux.1-schnell',
    );
  });

  test('NetworkException oldugunda internet baglanti hatasi doner', () async {
    when(
      () => mockDioClient.externalPost<dynamic>(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenThrow(const NetworkException('offline'));

    await expectLater(
      () => service.generateImage(request),
      throwsA(
        isA<AIServiceException>().having(
          (exception) => exception.message.toLowerCase(),
          'message',
          contains('internet bağlantısı'),
        ),
      ),
    );
  });

  test('401 oldugunda api anahtari hatasi doner', () async {
    when(
      () => mockDioClient.externalPost<dynamic>(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenThrow(const ServerException('Unauthorized', statusCode: 401));

    await expectLater(
      () => service.generateImage(request),
      throwsA(
        isA<AIServiceException>().having(
          (exception) => exception.message.toLowerCase(),
          'message',
          contains('api anahtarı'),
        ),
      ),
    );
  });

  test('429 oldugunda rate limit hatasi doner', () async {
    when(
      () => mockDioClient.externalPost<dynamic>(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenThrow(const ServerException('Too Many Requests', statusCode: 429));

    await expectLater(
      () => service.generateImage(request),
      throwsA(
        isA<AIServiceException>().having(
          (exception) => exception.message,
          'message',
          contains('429'),
        ),
      ),
    );
  });

  test('500 oldugunda sunucu hatasi doner', () async {
    when(
      () => mockDioClient.externalPost<dynamic>(
        any(),
        data: any(named: 'data'),
        headers: any(named: 'headers'),
      ),
    ).thenThrow(const ServerException('Server Error', statusCode: 500));

    await expectLater(
      () => service.generateImage(request),
      throwsA(
        isA<AIServiceException>().having(
          (exception) => exception.message.toLowerCase(),
          'message',
          contains('sunucu hatası'),
        ),
      ),
    );
  });
}
