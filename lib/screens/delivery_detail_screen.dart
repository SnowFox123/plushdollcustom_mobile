import 'package:flutter/material.dart';
import '../services/delivery_service.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  Map<String, dynamic>? deliveryDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeliveryDetail();
  }

  Future<void> _loadDeliveryDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final detail = await DeliveryService.getDeliveryDetail(
        deliveryId: widget.deliveryId,
      );

      setState(() {
        deliveryDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Chi tiết giao hàng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Spacer(),
            if (deliveryDetail != null &&
                deliveryDetail!['deliveryStatus'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.amber[800],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(deliveryDetail!['deliveryStatus']),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeliveryDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (deliveryDetail == null) {
      return const Center(child: Text('Không tìm thấy thông tin đơn hàng'));
    }

    final images = deliveryDetail!['images'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mã đơn hàng, trạng thái, giá
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Mã đơn hàng: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: deliveryDetail!['orderCode'] ?? '',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${deliveryDetail!['deliveryPrice'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Thông tin thời gian
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: Colors.pink),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông tin thời gian',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày tạo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatDate(deliveryDetail!['createdAt'] ?? ''),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày giao hàng',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              deliveryDetail!['deliveredAt'] != null
                                  ? _formatDate(deliveryDetail!['deliveredAt'])
                                  : 'Chưa có',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Người gửi & Người nhận
          Row(
            children: [
              Expanded(
                child: _buildPersonCard(
                  isSender: true,
                  name: deliveryDetail!['senderName'],
                  address: deliveryDetail!['senderAddress'],
                  phone: deliveryDetail!['senderPhoneNumber'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPersonCard(
                  isSender: false,
                  name: deliveryDetail!['receiverName'],
                  address: deliveryDetail!['receiverAddress'],
                  phone: deliveryDetail!['receiverPhoneNumber'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thông tin gói hàng
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông tin gói hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPackageInfo(
                        'Chiều dài',
                        '${deliveryDetail!['length']} cm',
                      ),
                      _buildPackageInfo(
                        'Chiều rộng',
                        '${deliveryDetail!['width']} cm',
                      ),
                      _buildPackageInfo(
                        'Chiều cao',
                        '${deliveryDetail!['height']} cm',
                      ),
                      _buildPackageInfo(
                        'Cân nặng',
                        '${deliveryDetail!['weight']} g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hình ảnh gói hàng
          if (images.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image_outlined, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Hình ảnh gói hàng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int count = images.length;
                        int crossAxisCount = count == 1
                            ? 1
                            : (count == 2 ? 2 : 3);
                        double spacing = 8;
                        double totalSpacing = spacing * (crossAxisCount - 1);
                        double maxItemSize = 70;
                        double itemWidth =
                            ((constraints.maxWidth - totalSpacing) /
                                    crossAxisCount)
                                .clamp(0, maxItemSize);
                        double itemHeight = itemWidth;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: images.map<Widget>((img) {
                            return GestureDetector(
                              onTap: () =>
                                  _showImagePreview(img['imageUrl'], context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  img['imageUrl'],
                                  width: itemWidth,
                                  height: itemHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ghi chú
          if (deliveryDetail!['note'] != null &&
              deliveryDetail!['note'].toString().isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Ghi chú',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deliveryDetail!['note'],
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(
        dateString,
      ).toUtc().add(const Duration(hours: 7));
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Các hàm phụ trợ:
  Widget _buildPersonCard({
    required bool isSender,
    required String? name,
    required String? address,
    required String? phone,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: isSender ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isSender ? 'Người gửi' : 'Người nhận',
                  style: TextStyle(
                    color: isSender ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Expanded(child: Text(name ?? '')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Expanded(child: Text(address ?? '')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(phone ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '';
    return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫';
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'ReadyToPick':
        return 'Sẵn sàng lấy hàng';
      // Thêm các trạng thái khác nếu cần
      default:
        return status ?? '';
    }
  }

  // Hàm phóng to ảnh
  void _showImagePreview(String imageUrl, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, url, error) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
