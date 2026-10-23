import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

class ChatPhotoPickerSheet extends StatefulWidget {
  final Function({
    required Uint8List bytes,
    required String fileName,
    required bool isViewOnce,
    String? caption,
  }) onSend;

  const ChatPhotoPickerSheet({
    super.key,
    required this.onSend,
  });

  static Future<void> show(
    BuildContext context, {
    required Function({
      required Uint8List bytes,
      required String fileName,
      required bool isViewOnce,
      String? caption,
    }) onSend,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChatPhotoPickerSheet(onSend: onSend),
    );
  }

  @override
  State<ChatPhotoPickerSheet> createState() => _ChatPhotoPickerSheetState();
}

class _ChatPhotoPickerSheetState extends State<ChatPhotoPickerSheet> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedBytes;
  String? _selectedFileName;
  bool _isViewOnce = true; // Default to Snapchat view-once style
  final TextEditingController _captionController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedBytes = bytes;
          _selectedFileName = file.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141923),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            _selectedBytes == null ? 'Share Photo or Snap' : 'Preview Snap',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (_selectedBytes == null) ...[
            // Picker buttons
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Snap',
                    color: const Color(0xFFFF5252),
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: AppTheme.primaryColor,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '🔥 Send view-once snaps or keep photos in chat.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ] else ...[
            // Selected preview thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.memory(
                    _selectedBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 14,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedBytes = null;
                        _selectedFileName = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Mode Toggle (View Once vs Regular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2433),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isViewOnce
                        ? Icons.local_fire_department_rounded
                        : Icons.photo_rounded,
                    color: _isViewOnce
                        ? const Color(0xFFFF5252)
                        : AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isViewOnce
                              ? 'Snapchat View-Once (Expiring)'
                              : 'Standard Photo (Keep in Chat)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _isViewOnce
                              ? 'Recipient can only view for 10 seconds'
                              : 'Saved in the conversation',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isViewOnce,
                    activeColor: const Color(0xFFFF5252),
                    onChanged: (val) {
                      setState(() {
                        _isViewOnce = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Caption Field
            TextField(
              controller: _captionController,
              maxLength: 100,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a caption (optional)...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: const Color(0xFF1E2433),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Send Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isViewOnce
                      ? const Color(0xFFFF5252)
                      : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isViewOnce
                            ? Icons.local_fire_department_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                      ),
                label: Text(
                  _isProcessing
                      ? 'Sending...'
                      : _isViewOnce
                          ? 'Send View-Once Snap 🔥'
                          : 'Send Photo 📷',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isProcessing
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        Navigator.pop(context);
                        await widget.onSend(
                          bytes: _selectedBytes!,
                          fileName: _selectedFileName ?? 'snap.jpg',
                          isViewOnce: _isViewOnce,
                          caption: _captionController.text.trim().isEmpty
                              ? null
                              : _captionController.text.trim(),
                        );
                      },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
