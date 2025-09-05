import 'package:flutter/material.dart';
import '../constants/post_status_constants.dart';

class PostStatusBadge extends StatelessWidget {
  final dynamic postStatus;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const PostStatusBadge({
    super.key,
    required this.postStatus,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    // Handle both int and string status values
    PostStatus status;
    if (postStatus is int) {
      status = PostStatus.fromValue(postStatus);
    } else if (postStatus is String) {
      // Try to find by name first, then fallback to unknown
      try {
        status = PostStatus.fromName(postStatus);
      } catch (e) {
        switch (postStatus.toLowerCase()) {
          case 'locked':
            status = PostStatus.locked;
            break;
          case 'notreceived':
          case 'not_received':
          case 'not-received':
            status = PostStatus.notReceived;
            break;
          case 'received':
            status = PostStatus.received;
            break;
          case 'completed':
            status = PostStatus.completed;
            break;
          default:
            status = PostStatus.unknown;
        }
      }
    } else {
      status = PostStatus.unknown;
    }

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.icon, color: status.color, size: iconSize ?? 16),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
