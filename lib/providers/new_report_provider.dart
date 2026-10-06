import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../models/enums.dart';
import '../repositories/report_repository.dart';
import '../services/ai_analysis_service.dart';
import 'report_provider.dart';

class NewReportState {
  final String? imagePath;
  final Position? position;
  final Category? category;
  final String description;
  final bool isSubmitting;
  final bool isAnalyzing;
  final String? error;
  final String? aiSummary;
  final String? aiOverlayUrl;

  const NewReportState({
    this.imagePath,
    this.position,
    this.category,
    this.description = '',
    this.isSubmitting = false,
    this.isAnalyzing = false,
    this.error,
    this.aiSummary,
    this.aiOverlayUrl,
  });

  NewReportState copyWith({
    String? imagePath,
    Position? position,
    Category? category,
    String? description,
    bool? isSubmitting,
    bool? isAnalyzing,
    String? error,
    String? aiSummary,
    String? aiOverlayUrl,
    bool clearAi = false,
  }) {
    return NewReportState(
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      category: category ?? this.category,
      description: description ?? this.description,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
      aiSummary: clearAi ? null : (aiSummary ?? this.aiSummary),
      aiOverlayUrl: clearAi ? null : (aiOverlayUrl ?? this.aiOverlayUrl),
    );
  }
}

class NewReportNotifier extends Notifier<NewReportState> {
  final _aiService = AiAnalysisService();

  @override
  NewReportState build() {
    return const NewReportState();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        state = state.copyWith(imagePath: pickedFile.path, error: null, clearAi: true);
        // Auto-run AI analysis
        await analyzeImage();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  Future<void> analyzeImage() async {
    if (state.imagePath == null) return;
    state = state.copyWith(isAnalyzing: true, error: null);
    try {
      final result = await _aiService.analyzeImage(state.imagePath!);

      // Auto-set category if detected
      Category? detected;
      if (result.detectedCategory != null) {
        detected = Category.fromJson(result.detectedCategory!);
      }

      state = state.copyWith(
        isAnalyzing: false,
        aiSummary: result.analysisSummary,
        aiOverlayUrl: result.overlayImageUrl.isNotEmpty ? result.overlayImageUrl : null,
        category: detected ?? state.category,
        description: state.description.isEmpty ? result.analysisSummary : state.description,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'AI analysis failed — fill in manually.',
      );
    }
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(error: 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(error: 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(error: 'Location permissions are permanently denied.');
        return;
      }

      state = state.copyWith(error: null);
      final position = await Geolocator.getCurrentPosition();
      state = state.copyWith(position: position);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get location: $e');
    }
  }

  void setCategory(Category category) {
    state = state.copyWith(category: category);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  Future<bool> submitReport() async {
    if (state.imagePath == null || state.position == null || state.category == null) {
      state = state.copyWith(error: 'Please complete all required fields.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.createReport(
        category: state.category!.value,
        latitude: state.position!.latitude,
        longitude: state.position!.longitude,
        imagePath: state.imagePath!,
        description: state.description.isNotEmpty ? state.description : null,
      );

      ref.invalidate(reportListProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to submit report: $e', isSubmitting: false);
      return false;
    }
  }
}

final newReportProvider = NotifierProvider<NewReportNotifier, NewReportState>(() {
  return NewReportNotifier();
});
