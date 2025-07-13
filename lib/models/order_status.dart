import 'package:flutter/material.dart';

class OrderStatus {
  final String code;
  final String name;
  final Color color;
  final IconData icon;

  const OrderStatus({
    required this.code,
    required this.name,
    required this.color,
    required this.icon,
  });

  // Map tất cả status có sẵn
  static const Map<String, OrderStatus> allStatuses = {
    'Pending': OrderStatus(
      code: 'Pending',
      name: 'Chờ xác nhận',
      color: Colors.orange,
      icon: Icons.schedule,
    ),
    'Confirmed': OrderStatus(
      code: 'Confirmed',
      name: 'Đã xác nhận',
      color: Colors.blue,
      icon: Icons.check_circle_outline,
    ),
    'ReadyToPick': OrderStatus(
      code: 'ReadyToPick',
      name: 'Sẵn sàng lấy hàng',
      color: Colors.green,
      icon: Icons.inventory_2_outlined,
    ),
    'Picked': OrderStatus(
      code: 'Picked',
      name: 'Đã lấy hàng',
      color: Colors.teal,
      icon: Icons.local_shipping_outlined,
    ),
    'Delivering': OrderStatus(
      code: 'Delivering',
      name: 'Đang giao hàng',
      color: Colors.purple,
      icon: Icons.delivery_dining,
    ),
    'Delivered': OrderStatus(
      code: 'Delivered',
      name: 'Đã giao hàng',
      color: Colors.green,
      icon: Icons.check_circle,
    ),
    'Cancelled': OrderStatus(
      code: 'Cancelled',
      name: 'Đã hủy',
      color: Colors.red,
      icon: Icons.cancel,
    ),
    'Returned': OrderStatus(
      code: 'Returned',
      name: 'Đã trả hàng',
      color: Colors.red,
      icon: Icons.undo,
    ),
    'Refunded': OrderStatus(
      code: 'Refunded',
      name: 'Đã hoàn tiền',
      color: Colors.grey,
      icon: Icons.money_off,
    ),
  };

  // Lấy status theo code
  static OrderStatus? getByCode(String code) {
    return allStatuses[code];
  }

  // Lấy tên tiếng Việt của status
  static String getName(String code) {
    return allStatuses[code]?.name ?? code;
  }

  // Lấy màu của status
  static Color getColor(String code) {
    return allStatuses[code]?.color ?? Colors.grey;
  }

  // Lấy icon của status
  static IconData getIcon(String code) {
    return allStatuses[code]?.icon ?? Icons.help_outline;
  }

  // Lấy tất cả status codes
  static List<String> getAllCodes() {
    return allStatuses.keys.toList();
  }

  // Lấy tất cả status objects
  static List<OrderStatus> getAllStatuses() {
    return allStatuses.values.toList();
  }
}
