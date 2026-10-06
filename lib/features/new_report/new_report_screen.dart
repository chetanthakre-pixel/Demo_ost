import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/enums.dart';
import '../../providers/new_report_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/hairline_divider.dart';
import '../../core/widgets/section_label.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _onCategorySelected(Category? category) {
    if (category != null) {
      ref.read(newReportProvider.notifier).setCategory(category);
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(newReportProvider.notifier).submitReport();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: AppTheme.statusResolved,
        ),
      );
      // Reset description controller
      _descController.clear();
      context.go('/home'); // Navigate to Reports tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportProvider);

    // Sync description controller if AI updated it
    if (state.description.isNotEmpty && _descController.text.isEmpty) {
      _descController.text = state.description;
    }

    ref.listen<NewReportState>(newReportProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          next.error != 'AI analysis failed — fill in manually.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.statusRejected),
        );
      }
    });

    return AppScaffold(
      appBar: AppBar(
        title: const Text('NEW REPORT'),
      ),
      body: state.isSubmitting
          ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Section
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppTheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          side: BorderSide(color: AppTheme.hairline, width: 1),
                        ),
                        builder: (_) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt, color: AppTheme.text),
                                title: const Text('Take a Photo', style: TextStyle(color: AppTheme.text, fontFamily: 'Inter')),
                                onTap: () {
                                  Navigator.pop(context);
                                  ref.read(newReportProvider.notifier).pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library, color: AppTheme.text),
                                title: const Text('Choose from Gallery', style: TextStyle(color: AppTheme.text, fontFamily: 'Inter')),
                                onTap: () {
                                  Navigator.pop(context);
                                  ref.read(newReportProvider.notifier).pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (state.imagePath != null)
                            Image.file(
                              File(state.imagePath!),
                              fit: BoxFit.cover,
                            )
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 32, color: AppTheme.textMuted),
                                SizedBox(height: 12),
                                Text('TAP TO ADD PHOTO', style: AppTheme.labelStyle),
                              ],
                            ),
                          
                          // AI Overlay
                          if (state.aiOverlayUrl != null)
                            Image.network(
                              state.aiOverlayUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),

                          // AI Loading State
                          if (state.isAnalyzing)
                            Container(
                              color: Colors.black54,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.accent),
                                  SizedBox(height: 16),
                                  Text('AI is analyzing image...', style: AppTheme.labelStyle),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (state.aiSummary != null) ...[
                     const SizedBox(height: 16),
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: AppTheme.surface,
                         border: Border.all(color: AppTheme.accent.withAlpha(100), width: 1),
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Row(
                             children: [
                               Icon(Icons.auto_awesome, size: 16, color: AppTheme.accent),
                               SizedBox(width: 8),
                               Text('AI ANALYSIS SUMMARY', style: AppTheme.labelStyle),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Text(
                             state.aiSummary!,
                             style: const TextStyle(color: AppTheme.text, fontFamily: 'Inter', fontSize: 14),
                           ),
                         ],
                       ),
                     ),
                  ],

                  const SizedBox(height: 32),
                  const HairlineDivider(withChecker: true),
                  const SizedBox(height: 32),

                  // Location Section
                  const SectionLabel('LOCATION'),
                  const SizedBox(height: 16),
                  Material(
                    color: AppTheme.surface2,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppTheme.hairline, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const Icon(Icons.location_on, color: AppTheme.text),
                      title: Text(
                        state.position != null
                            ? '${state.position!.latitude.toStringAsFixed(4)}, ${state.position!.longitude.toStringAsFixed(4)}'
                            : 'Tap to get current location',
                        style: const TextStyle(color: AppTheme.text, fontFamily: 'Inter'),
                      ),
                      trailing: state.position != null
                          ? const Icon(Icons.check_circle, color: AppTheme.statusResolved, size: 20)
                          : OutlinedButton(
                              onPressed: () => ref.read(newReportProvider.notifier).getLocation(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.text,
                                side: const BorderSide(color: AppTheme.hairline, width: 1),
                              ),
                              child: const Text('GET', style: TextStyle(fontFamily: 'Michroma', fontSize: 10, letterSpacing: 1)),
                            ),
                      onTap: state.position == null
                          ? () => ref.read(newReportProvider.notifier).getLocation()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Section
                  const SectionLabel('CATEGORY'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.hairline, width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.hairline, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.accent, width: 1)),
                    ),
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(color: AppTheme.text, fontFamily: 'Inter'),
                    value: state.category,
                    hint: const Text('Select a category', style: TextStyle(color: AppTheme.textMuted)),
                    items: Category.values
                        .where((c) => c != Category.unknown)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: _onCategorySelected,
                  ),
                  const SizedBox(height: 32),

                  // Description Section
                  const SectionLabel('DESCRIPTION (OPTIONAL)'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: AppTheme.text, fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'Add more details...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontFamily: 'Inter'),
                      filled: true,
                      fillColor: AppTheme.surface2,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.hairline, width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.hairline, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.accent, width: 1)),
                    ),
                    maxLines: 4,
                    onChanged: (val) => ref.read(newReportProvider.notifier).setDescription(val),
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (state.imagePath != null && state.position != null && state.category != null && !state.isAnalyzing)
                          ? _submit
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppTheme.surface2,
                        disabledForegroundColor: AppTheme.textMuted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('SUBMIT REPORT', style: TextStyle(fontFamily: 'Michroma', letterSpacing: 2, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
