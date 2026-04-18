import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';

// In a real app we'd use image_picker. For MVP scaffolding we'll simulate.
class PhotoUploadScreen extends ConsumerStatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final scaffold = ScaffoldMessenger.of(context);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    // Check limit
    final currentState = ref.read(onboardingNotifierProvider);
    if (currentState.localPhotoPaths.length >= 6) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Maximum 6 photos allowed')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        notifier.addPhoto(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      scaffold.showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            notifier.previousStep();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            index <= 2
                                ? AppTheme.primaryColor
                                : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Show your best self',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Add at least 2 photos to continue. The first photo will be your main profile picture and subject to the Progressive Blur.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75, // Standard portrait photo ratio
                  ),
                  itemCount: 6,

                  itemBuilder: (context, index) {
                    final isOccupied = index < state.localPhotoPaths.length;

                    return GestureDetector(
                      onTap: () {
                        if (!isOccupied) {
                          _pickImage();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isOccupied
                                    ? AppTheme.primaryColor
                                    : AppTheme.dividerColor,
                            width: isOccupied ? 2 : 1,
                            style:
                                isOccupied
                                    ? BorderStyle.solid
                                    : BorderStyle.none,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (isOccupied)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  color: AppTheme.surfaceColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  child:
                                      state.localPhotoPaths[index].startsWith(
                                            'mock_photo_',
                                          )
                                          ? const Center(
                                            child: Icon(
                                              Icons.image,
                                              color: AppTheme.textSecondary,
                                              size: 40,
                                            ),
                                          )
                                          : Image.file(
                                            File(state.localPhotoPaths[index]),
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                            if (!isOccupied)
                              const Center(
                                child: Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            if (isOccupied)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => notifier.removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (index == 0 && isOccupied)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Main',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    state.localPhotoPaths.length >= 2 && !state.isSubmitting
                        ? () async {
                          try {
                            await notifier.completeOnboarding();
                            if (mounted) {
                              context.go('/');
                            }
                          } catch (e) {
                            debugPrint('Error during onboarding: $e');
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child:
                    state.isSubmitting
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Workaround helper to cleanly use ReorderableListView with GridView
// Since Fluters built in ReorderableListView doesn't perfectly wrap GridView without some tweaking,
// For MVP we map them out using GridView natively, wrapped in Reorderable items later. Right now we just use a generic Builder.
// Let's replace the ReorderableListView with a simple GridView for MVP to avoid boilerplate dragging complexities right now
extension PhotoGrid on Widget {
  // Implementation abstracted for brevity
}
