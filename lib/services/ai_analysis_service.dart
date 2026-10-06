import 'package:dio/dio.dart';

class AiAnalysisResult {
  final String overlayImageUrl;
  final String analysisSummary;
  final String? detectedCategory;

  const AiAnalysisResult({
    required this.overlayImageUrl,
    required this.analysisSummary,
    this.detectedCategory,
  });
}

class AiAnalysisService {
  static const String _baseUrl = 'https://amitk-39-smart-city.hf.space';
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// Maps AI output text to one of our category values
  String? _detectCategory(String summary) {
    final lower = summary.toLowerCase();
    if (lower.contains('pothole')) return 'pothole';
    if (lower.contains('road damage') || lower.contains('damaged road') || lower.contains('crack')) return 'damaged_road';
    if (lower.contains('parking') || lower.contains('illegal')) return 'illegal_parking';
    if (lower.contains('sign') || lower.contains('road sign')) return 'broken_road_sign';
    if (lower.contains('tree') || lower.contains('fallen')) return 'fallen_tree';
    if (lower.contains('garbage') || lower.contains('waste') || lower.contains('litter') || lower.contains('trash')) return 'garbage';
    if (lower.contains('vandal') || lower.contains('graffiti')) return 'vandalism';
    if (lower.contains('animal') || lower.contains('dead')) return 'dead_animal';
    if (lower.contains('concrete') || lower.contains('pavement')) return 'damaged_concrete';
    if (lower.contains('electric') || lower.contains('wire') || lower.contains('power')) return 'electric_hazard';
    return 'other';
  }

  Future<AiAnalysisResult> analyzeImage(String imagePath) async {
    // Step 1: Upload the image file
    final formData = FormData.fromMap({
      'files': await MultipartFile.fromFile(imagePath),
    });

    final uploadResp = await _dio.post(
      '$_baseUrl/upload',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final uploadedPath = (uploadResp.data as List).first as String;

    // Step 2: Call the predict endpoint
    final predictResp = await _dio.post(
      '$_baseUrl/run/predict_urban_issues',
      data: {
        'data': [
          {
            'path': uploadedPath,
            'meta': {'_type': 'gradio.FileData'},
          }
        ]
      },
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
    );

    final resultData = (predictResp.data['data'] as List);
    // result[0] is overlay image (could be a URL string or file data map)
    // result[1] is the analysis text
    final analysisText = resultData[1] as String? ?? 'No analysis available.';

    // Extract overlay image URL
    String overlayUrl = '';
    final overlayRaw = resultData[0];
    if (overlayRaw is Map) {
      overlayUrl = overlayRaw['url'] as String? ?? overlayRaw['path'] as String? ?? '';
      if (overlayUrl.isNotEmpty && !overlayUrl.startsWith('http')) {
        overlayUrl = '$_baseUrl/file=$overlayUrl';
      }
    } else if (overlayRaw is String) {
      overlayUrl = overlayRaw.startsWith('http') ? overlayRaw : '$_baseUrl/file=$overlayRaw';
    }

    return AiAnalysisResult(
      overlayImageUrl: overlayUrl,
      analysisSummary: analysisText,
      detectedCategory: _detectCategory(analysisText),
    );
  }
}
