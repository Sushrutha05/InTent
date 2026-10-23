import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SnapViewDialog extends StatefulWidget {
  final String imageUrl;
  final String? caption;
  final VoidCallback onViewed;

  const SnapViewDialog({
    super.key,
    required this.imageUrl,
    this.caption,
    required this.onViewed,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? caption,
    required VoidCallback onViewed,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      barrierDismissible: true,
      builder: (context) => SnapViewDialog(
        imageUrl: imageUrl,
        caption: caption,
        onViewed: onViewed,
      ),
    );
  }

  @override
  State<SnapViewDialog> createState() => _SnapViewDialogState();
}

class _SnapViewDialogState extends State<SnapViewDialog> {
  int _secondsRemaining = 10;
  bool _isCountdownStarted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenToImageStream();
  }

  void _listenToImageStream() {
    final imageProvider = CachedNetworkImageProvider(widget.imageUrl);
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        _startCountdown();
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        // If load fails, start timer anyway after 2s so user isn't stuck forever
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isCountdownStarted) {
            _startCountdown();
          }
        });
      },
    );
    stream.addListener(listener);
  }

  void _startCountdown() {
    if (_isCountdownStarted || !mounted) return;
    _isCountdownStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onViewed();

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_secondsRemaining <= 1) {
          t.cancel();
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Full image
              Center(
                child: Hero(
                  tag: widget.imageUrl,
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                      imageBuilder: (context, imageProvider) {
                        _startCountdown();
                        return Image(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        );
                      },
                      placeholder: (context, url) => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFFF5252),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Loading snap...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, color: Colors.white54, size: 48),
                            SizedBox(height: 8),
                            Text(
                              'Could not load snap',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Countdown badge in top right
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isCountdownStarted
                          ? const Color(0xFFFF5252)
                          : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isCountdownStarted) ...[
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF5252),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '10s',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFFF5252),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_secondsRemaining}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Close button top left
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),

              // Caption banner at bottom
              if (widget.caption != null && widget.caption!.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      widget.caption!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
