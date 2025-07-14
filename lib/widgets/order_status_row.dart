import 'package:flutter/material.dart';
import '../models/order_status.dart';

class OrderStatusRow extends StatelessWidget {
  final void Function(String status)? onTap;

  const OrderStatusRow({Key? key, this.onTap}) : super(key: key);

  // Định nghĩa các status chính để hiển thị cho delivery
  static const List<String> mainDeliveryStatuses = [
    'ReadyToPick',
    'Picked',
    'Delivering',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: mainDeliveryStatuses.map((status) {
            final orderStatus = OrderStatus.getByCode(status);

            return _buildOrderStatusItem(
              icon: orderStatus?.icon ?? Icons.help_outline,
              label: orderStatus?.name ?? status,
              color: orderStatus?.color ?? Colors.grey,
              onTap: () => onTap?.call(status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
