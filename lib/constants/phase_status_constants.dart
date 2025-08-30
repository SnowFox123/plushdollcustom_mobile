import 'package:flutter/material.dart';

enum PhaseStatus {
  notStarted(0, 'NotStarted', 'Chưa bắt đầu'),
  dealed(1, 'Dealed', 'Đã chốt'),
  deposited(2, 'Deposited', 'Đã đặt cọc'),
  withdrawed(3, 'Withdrawed', 'Đã rút tiền'),
  inProgress(4, 'InProgress', 'Đang thực hiện'),
  rework(5, 'Rework', 'Yêu cầu\nchỉnh sửa'),
  done(6, 'Done', 'Hoàn thành'),
  refund(7, 'Refund', 'Hoàn tiền');

  const PhaseStatus(this.value, this.name, this.displayName);

  final int value;
  final String name;
  final String displayName;

  static PhaseStatus fromValue(int value) {
    return PhaseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PhaseStatus.notStarted,
    );
  }

  static PhaseStatus fromName(String name) {
    return PhaseStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => PhaseStatus.notStarted,
    );
  }

  Color get color {
    switch (this) {
      case PhaseStatus.notStarted:
        return const Color(0xFF6B7280); // Gray
      case PhaseStatus.dealed:
        return const Color(0xFF1E40AF); // Blue-800
      case PhaseStatus.deposited:
        return const Color(0xFF059669); // Green-600
      case PhaseStatus.withdrawed:
        return const Color(0xFFDC2626); // Red-600
      case PhaseStatus.inProgress:
        return const Color(0xFF7C3AED); // Purple-600
      case PhaseStatus.rework:
        return const Color(0xFFEA580C); // Orange-600
      case PhaseStatus.done:
        return const Color(0xFF059669); // Green-600
      case PhaseStatus.refund:
        return const Color(0xFFDC2626); // Red-600
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PhaseStatus.notStarted:
        return const Color(0xFFF3F4F6); // Gray-100
      case PhaseStatus.dealed:
        return const Color(0xFFDBEAFE); // Blue-100
      case PhaseStatus.deposited:
        return const Color(0xFFD1FAE5); // Green-100
      case PhaseStatus.withdrawed:
        return const Color(0xFFFEE2E2); // Red-100
      case PhaseStatus.inProgress:
        return const Color(0xFFF3E8FF); // Purple-100
      case PhaseStatus.rework:
        return const Color(0xFFFED7AA); // Orange-100
      case PhaseStatus.done:
        return const Color(0xFFD1FAE5); // Green-100
      case PhaseStatus.refund:
        return const Color(0xFFFEE2E2); // Red-100
    }
  }

  IconData get icon {
    switch (this) {
      case PhaseStatus.notStarted:
        return Icons.schedule;
      case PhaseStatus.dealed:
        return Icons.check_circle;
      case PhaseStatus.deposited:
        return Icons.account_balance_wallet;
      case PhaseStatus.withdrawed:
        return Icons.account_balance;
      case PhaseStatus.inProgress:
        return Icons.access_time;
      case PhaseStatus.rework:
        return Icons.refresh;
      case PhaseStatus.done:
        return Icons.task_alt;
      case PhaseStatus.refund:
        return Icons.money_off;
    }
  }
}
