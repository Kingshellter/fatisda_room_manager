import 'package:flutter/material.dart';

class CustomNotification {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 3),
    String? subtitle,
  }) {
    if (_isShowing) {
      hide(); // Hide existing notification
    }

    _isShowing = true;
    _overlayEntry = _createOverlayEntry(context, message, type, subtitle);
    Overlay.of(context).insert(_overlayEntry!);

    // Auto hide after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null && _isShowing) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String message,
    NotificationType type,
    String? subtitle,
  ) {
    return OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        subtitle: subtitle,
        onDismiss: hide,
      ),
    );
  }
}

enum NotificationType { success, error, info, warning }

class _NotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final String? subtitle;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.type,
    this.subtitle,
    required this.onDismiss,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.error:
        return const Color(0xFFEF4444);
      case NotificationType.info:
        return const Color(0xFF3B82F6);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: _backgroundColor.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _backgroundColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_icon, color: _backgroundColor, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Close Button
                    GestureDetector(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          widget.onDismiss();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
