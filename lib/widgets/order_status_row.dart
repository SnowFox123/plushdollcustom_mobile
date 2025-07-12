import 'package:flutter/material.dart';

class OrderStatusRow extends StatelessWidget {
  final int waitingConfirm;
  final int waitingPickup;
  final int delivering;
  final int toReview;
  final void Function(int index)? onTap;

  const OrderStatusRow({
    Key? key,
    this.waitingConfirm = 0,
    this.waitingPickup = 0,
    this.delivering = 0,
    this.toReview = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildOrderStatusItem(
              icon: Icons.receipt_long,
              label: 'Đơn hàng',
              badge: waitingConfirm,
              onTap: () => onTap?.call(0),
            ),
            _buildOrderStatusItem(
              icon: Icons.inventory_2_outlined,
              label: 'Chờ lấy hàng',
              badge: waitingPickup,
              onTap: () => onTap?.call(1),
            ),
            _buildOrderStatusItem(
              icon: Icons.local_shipping_outlined,
              label: 'Chờ giao hàng',
              badge: delivering,
              onTap: () => onTap?.call(2),
            ),
            _buildOrderStatusItem(
              icon: Icons.star_border,
              label: 'Đánh giá',
              badge: toReview,
              onTap: () => onTap?.call(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required int badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              if (badge > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
