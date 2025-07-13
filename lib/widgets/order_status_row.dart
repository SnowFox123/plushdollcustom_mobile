import 'package:flutter/material.dart';
import '../services/order_status_service.dart';
import '../models/order_status.dart';

class OrderStatusRow extends StatefulWidget {
  final void Function(int index)? onTap;

  const OrderStatusRow({Key? key, this.onTap}) : super(key: key);

  @override
  State<OrderStatusRow> createState() => _OrderStatusRowState();
}

class _OrderStatusRowState extends State<OrderStatusRow> {
  Map<String, int> _statusCount = {};
  bool _isLoading = true;
  String? _error;

  // Định nghĩa các status chính để hiển thị
  static const List<String> mainStatuses = [
    'Pending',
    'ReadyToPick',
    'Delivering',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _loadStatusCount();
  }

  Future<void> _loadStatusCount() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final statusCount = await OrderStatusService.getOrderStatusCount();

      setState(() {
        _statusCount = statusCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              Text('Lỗi tải dữ liệu', style: TextStyle(color: Colors.red)),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadStatusCount,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: mainStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final orderStatus = OrderStatus.getByCode(status);

            return _buildOrderStatusItem(
              icon: orderStatus?.icon ?? Icons.help_outline,
              label: orderStatus?.name ?? status,
              badge: _statusCount[status] ?? 0,
              color: orderStatus?.color ?? Colors.grey,
              onTap: () => widget.onTap?.call(index),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required int badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 32, color: color),
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
