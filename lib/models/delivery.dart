class Delivery {
  final String deliveryId;
  final String orderId;
  final String senderName;
  final String receiverName;
  final String orderCode;
  final double deliveryPrice;
  final String? note;
  final String deliveryStatus;
  final String createdAt;
  final String? deliveredAt;

  Delivery({
    required this.deliveryId,
    required this.orderId,
    required this.senderName,
    required this.receiverName,
    required this.orderCode,
    required this.deliveryPrice,
    this.note,
    required this.deliveryStatus,
    required this.createdAt,
    this.deliveredAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      deliveryId: json['deliveryID']?.toString() ?? '',
      orderId: json['orderID']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      orderCode: json['orderCode']?.toString() ?? '',
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString(),
      deliveryStatus: json['deliveryStatus']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      deliveredAt: json['deliveredAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryID': deliveryId,
      'orderID': orderId,
      'senderName': senderName,
      'receiverName': receiverName,
      'orderCode': orderCode,
      'deliveryPrice': deliveryPrice,
      'note': note,
      'deliveryStatus': deliveryStatus,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
    };
  }

  // Helper method to format date
  String get formattedCreatedAt {
    try {
      final date = DateTime.parse(
        createdAt,
      ).toUtc().add(const Duration(hours: 7));
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt;
    }
  }

  // Helper method to check if delivery is completed
  bool get isCompleted => deliveredAt != null;

  // Helper method to get status display name - updated to match actual API response
  String get statusDisplayName {
    switch (deliveryStatus.toLowerCase()) {
      case 'readytopick':
        return 'Sẵn sàng lấy hàng';
      case 'picked':
        return 'Đã lấy hàng';
      case 'delivering':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      case 'created':
        return 'Đã tạo mới';
      case 'shippingtodesigner':
        return 'Đang giao cho NTK';
      case 'designerrejected':
        return 'NTK từ chối';
      case 'inprogress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Đã hoàn thành';
      case 'shippingtocustomer':
        return 'Đang giao cho khách';
      case 'customerrejected':
        return 'Khách từ chối';
      case 'done':
        return 'Hoàn tất';
      case 'pendingconflict':
        return 'Đang xử lý tranh chấp';
      case 'rejected':
        return 'Bị từ chối';
      case 'requestshiptocus':
        return 'Yêu cầu trả hàng cho KH';
      default:
        return deliveryStatus;
    }
  }
}
