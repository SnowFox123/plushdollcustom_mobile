import 'package:flutter/material.dart';

// Sync with web StatusBadge: 0 Locked, 1 NotReceived, 2 Received, 3 Completed
enum PostStatus {
  unknown(-1, 'Unknown', 'Không xác định'),
  locked(0, 'Locked', 'Đã khóa'),
  notReceived(1, 'NotReceived', 'Chưa được nhận'),
  received(2, 'Received', 'Đã được nhận'),
  completed(3, 'Completed', 'Đã hoàn thành');

  const PostStatus(this.value, this.name, this.displayName);

  final int value;
  final String name;
  final String displayName;

  static PostStatus fromValue(int value) {
    return PostStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PostStatus.unknown,
    );
  }

  static PostStatus fromName(String name) {
    return PostStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => PostStatus.unknown,
    );
  }

  Color get color {
    switch (this) {
      case PostStatus.unknown:
        return const Color(0xFF1F2937); // Gray-800
      case PostStatus.locked:
        return const Color(0xFF991B1B); // Red-800
      case PostStatus.notReceived:
        return const Color(0xFF92400E); // Yellow-800
      case PostStatus.received:
        return const Color(0xFF1E40AF); // Blue-800
      case PostStatus.completed:
        return const Color(0xFF065F46); // Green-800
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PostStatus.unknown:
        return const Color(0xFFF3F4F6); // Gray-100
      case PostStatus.locked:
        return const Color(0xFFFEE2E2); // Red-100
      case PostStatus.notReceived:
        return const Color(0xFFFEF3C7); // Yellow-100
      case PostStatus.received:
        return const Color(0xFFDBEAFE); // Blue-100
      case PostStatus.completed:
        return const Color(0xFFD1FAE5); // Light green
    }
  }

  IconData get icon {
    switch (this) {
      case PostStatus.unknown:
        return Icons.help_outline;
      case PostStatus.locked:
        return Icons.lock;
      case PostStatus.notReceived:
        return Icons.schedule;
      case PostStatus.received:
        return Icons.check_circle_outline;
      case PostStatus.completed:
        return Icons.task_alt;
    }
  }
}
