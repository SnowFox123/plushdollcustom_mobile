import 'package:flutter/material.dart';

enum PostStatus {
  notReceived(0, 'NotReceived', 'Đang hoạt động'),
  received(1, 'Received', 'Đang xử lý'),
  completed(2, 'Completed', 'Hoàn thành'),
  locked(3, 'Locked', 'Bị khóa');

  const PostStatus(this.value, this.name, this.displayName);

  final int value;
  final String name;
  final String displayName;

  static PostStatus fromValue(int value) {
    return PostStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PostStatus.notReceived,
    );
  }

  static PostStatus fromName(String name) {
    return PostStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => PostStatus.notReceived,
    );
  }

  Color get color {
    switch (this) {
      case PostStatus.notReceived:
        return const Color(0xFF6B7280); // Gray
      case PostStatus.received:
        return const Color(0xFF3B82F6); // Blue
      case PostStatus.completed:
        return const Color(0xFF10B981); // Green
      case PostStatus.locked:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PostStatus.notReceived:
        return const Color(0xFFF3F4F6); // Light gray
      case PostStatus.received:
        return const Color(0xFFDBEAFE); // Light blue
      case PostStatus.completed:
        return const Color(0xFFD1FAE5); // Light green
      case PostStatus.locked:
        return const Color(0xFFFEE2E2); // Light red
    }
  }

  IconData get icon {
    switch (this) {
      case PostStatus.notReceived:
        return Icons.schedule;
      case PostStatus.received:
        return Icons.check_circle_outline;
      case PostStatus.completed:
        return Icons.task_alt;
      case PostStatus.locked:
        return Icons.lock;
    }
  }
}
