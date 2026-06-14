import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  DateTime? _selectedDate;

  final List<String> _availableInterests = [
    'Coffee',
    'Gym',
    'Anime',
    'Reading',
    'Coding',
    'Photography',
    'Gaming',
    'Travel',
    'Music',
    'Art',
    'Sports',
    'Foodie',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill if we navigated back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingNotifierProvider);

      // Auto-fill locked university from verified auth metadata
      final userMetadata =
          Supabase.instance.client.auth.currentUser?.userMetadata;
      final verifiedCollege = userMetadata?['college_name'] as String?;

      if (state.name != null) _nameController.text = state.name!;

      if (verifiedCollege != null && verifiedCollege.isNotEmpty) {
        _universityController.text = verifiedCollege;
      } else if (state.university != null) {
        _universityController.text = state.university!;
      }

      if (state.major != null) _majorController.text = state.major!;
      if (state.dateOfBirth != null) _selectedDate = state.dateOfBirth;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 16),
      ), // Minimum age 16/18
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool get _isValid {
    final state = ref.read(onboardingNotifierProvider);
    return _nameController.text.isNotEmpty &&
        _universityController.text.isNotEmpty &&
        _majorController.text.isNotEmpty &&
        _selectedDate != null &&
        state.interests.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            notifier.previousStep();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            index <= 1
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
                "Let's get the basics",
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameController,
                label: 'First Name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Date of Birth (Not shown publicly)'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            color:
                                _selectedDate == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildTextField(
                controller: _universityController,
                label: 'University / College (Verified via Email)',
                icon: Icons.school_outlined,
                readOnly: true,
              ),

              const SizedBox(height: 20),
              _buildTextField(
                controller: _majorController,
                label: 'Major / Field of Study',
                icon: Icons.book_outlined,
              ),

              const SizedBox(height: 40),
              Text(
                'Interests (${state.interests.length}/5)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _availableInterests.map((interest) {
                      final isSelected = state.interests.contains(interest);
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(
                            context,
                          ).unfocus(); // dismiss keyboard if open
                          notifier.toggleInterest(interest);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor.withValues(
                                      alpha: 0.2,
                                    )
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.dividerColor,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSecondary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 48),
              ElevatedButton(
                onPressed:
                    _isValid
                        ? () {
                          notifier.updateBasicInfo(
                            name: _nameController.text.trim(),
                            dateOfBirth: _selectedDate!,
                            university: _universityController.text.trim(),
                            major: _majorController.text.trim(),
                          );
                          notifier.nextStep();
                          context.push('/onboarding/photos');
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary),
      onChanged: (_) => setState(() {}), // trigger validation check
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      ),
    );
  }
}
