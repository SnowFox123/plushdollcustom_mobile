import 'package:flutter/material.dart';
import '../models/order_status.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderStatus = OrderStatus.getByCode(status);

    if (orderStatus == null) {
      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: orderStatus.color.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: orderStatus.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            orderStatus.icon,
            size: (fontSize ?? 12) + 2,
            color: orderStatus.color,
          ),
          const SizedBox(width: 4),
          Text(
            orderStatus.name,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              color: orderStatus.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị status với icon nhỏ
class StatusIcon extends StatelessWidget {
  final String status;
  final double size;

  const StatusIcon({Key? key, required this.status, this.size = 16})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderStatus = OrderStatus.getByCode(status);

    return Icon(
      orderStatus?.icon ?? Icons.help_outline,
      size: size,
      color: orderStatus?.color ?? Colors.grey,
    );
  }
}

// Widget hiển thị status với text đơn giản
class StatusText extends StatelessWidget {
  final String status;
  final TextStyle? style;

  const StatusText({Key? key, required this.status, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderStatus = OrderStatus.getByCode(status);

    return Text(
      orderStatus?.name ?? status,
      style:
          style?.copyWith(color: orderStatus?.color) ??
          TextStyle(
            color: orderStatus?.color ?? Colors.grey,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
