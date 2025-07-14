import 'package:flutter/material.dart';

class DeliveryStatusChip extends StatelessWidget {
  final String status;
  final String? customLabel;
  final Color? backgroundColor;
  final Color? textColor;

  const DeliveryStatusChip({
    super.key,
    required this.status,
    this.customLabel,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    final label = customLabel ?? statusInfo.label;
    final bgColor = backgroundColor ?? statusInfo.color.withOpacity(0.1);
    final txtColor = textColor ?? statusInfo.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 16, color: txtColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: txtColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ xử lý':
        return _StatusInfo(
          label: 'Chờ xử lý',
          color: Colors.orange,
          icon: Icons.schedule,
        );
      case 'ready':
      case 'sẵn sàng':
      case 'ready_to_pick':
      case 'readytopick':
        return _StatusInfo(
          label: 'Sẵn sàng lấy hàng',
          color: Colors.blue,
          icon: Icons.check_circle_outline,
        );
      case 'picked':
      case 'đã lấy hàng':
        return _StatusInfo(
          label: 'Đã lấy hàng',
          color: Colors.purple,
          icon: Icons.local_shipping,
        );
      case 'delivering':
      case 'đang giao':
      case 'in_transit':
        return _StatusInfo(
          label: 'Đang giao',
          color: Colors.indigo,
          icon: Icons.local_shipping,
        );
      case 'delivered':
      case 'đã giao':
      case 'completed':
        return _StatusInfo(
          label: 'Đã giao',
          color: Colors.green,
          icon: Icons.done_all,
        );
      case 'cancelled':
      case 'đã hủy':
        return _StatusInfo(
          label: 'Đã hủy',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case 'failed':
      case 'thất bại':
        return _StatusInfo(
          label: 'Thất bại',
          color: Colors.red,
          icon: Icons.error,
        );
      default:
        return _StatusInfo(
          label: status,
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  _StatusInfo({required this.label, required this.color, required this.icon});
}
