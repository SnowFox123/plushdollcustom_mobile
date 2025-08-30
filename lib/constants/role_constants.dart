import 'package:flutter/material.dart';

class RoleConstants {
  static const String CUSTOMER = 'Customer';
  static const String FREELANCER = 'Freelancer';
  static const String ADMIN = 'Admin';
  static const String STAFF = 'Staff';
  static const String DESIGNER = 'Designer';

  static const String CUSTOMER_DISPLAY = 'Khách hàng';
  static const String FREELANCER_DISPLAY = 'Freelancer';
  static const String ADMIN_DISPLAY = 'Quản trị viên';
  static const String STAFF_DISPLAY = 'Nhân viên';
  static const String DESIGNER_DISPLAY = 'Nhà Thiết kế';

  static String translateRole(String? role) {
    switch (role) {
      case CUSTOMER:
        return CUSTOMER_DISPLAY;
      case FREELANCER:
        return FREELANCER_DISPLAY;
      case ADMIN:
        return ADMIN_DISPLAY;
      case STAFF:
        return STAFF_DISPLAY;
      case DESIGNER:
        return DESIGNER_DISPLAY;
      default:
        return role ?? 'Không xác định';
    }
  }

  static bool isCustomer(String? role) {
    return role == CUSTOMER;
  }

  static String getAccessDeniedMessage(String? role) {
    if (role == null) {
      return 'Tài khoản không có thông tin vai trò. Ứng dụng di động chỉ hỗ trợ cho khách hàng.';
    }
    final roleDisplay = translateRole(role);
    return 'Tài khoản $roleDisplay không được hỗ trợ trên ứng dụng di động. Ứng dụng di động chỉ dành cho khách hàng.';
  }

  static Color getRoleColor(String? role) {
    switch (role) {
      case CUSTOMER:
        return Colors.green;
      case FREELANCER:
        return Colors.purple;
      case ADMIN:
        return Colors.red;
      case STAFF:
        return Colors.blue;
      case DESIGNER:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
