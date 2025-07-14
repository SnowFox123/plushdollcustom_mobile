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
      status = PostStatus.fromName(postStatus);
    } else {
      status = PostStatus.notReceived;
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
