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
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: isLargeScreen ? 70 : 60,
        title: Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: isLargeScreen ? 24 : 20,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              'Chi tiết giao hàng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 16 : 14,
              ),
            ),
            Spacer(),
            if (deliveryDetail != null &&
                deliveryDetail!['deliveryStatus'] != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 16 : 10,
                  vertical: isLargeScreen ? 8 : 5,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(deliveryDetail!['deliveryStatus'])[0],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(deliveryDetail!['deliveryStatus']),
                      color: _getStatusColor(
                        deliveryDetail!['deliveryStatus'],
                      )[1],
                      size: isLargeScreen ? 18 : 14,
                    ),
                    SizedBox(width: isLargeScreen ? 6 : 4),
                    Flexible(
                      child: Text(
                        _getStatusText(deliveryDetail!['deliveryStatus']),
                        style: TextStyle(
                          color: _getStatusColor(
                            deliveryDetail!['deliveryStatus'],
                          )[1],
                          fontWeight: FontWeight.bold,
                          fontSize: isLargeScreen ? 16 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: isLargeScreen ? 24 : 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isLargeScreen ? 80 : 64,
              color: Colors.red[300],
            ),
            SizedBox(height: isLargeScreen ? 24 : 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: isLargeScreen ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isLargeScreen ? 16 : 14,
              ),
            ),
            SizedBox(height: isLargeScreen ? 24 : 16),
            ElevatedButton(
              onPressed: _loadDeliveryDetail,
              child: Text(
                'Thử lại',
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
              ),
            ),
          ],
        ),
      );
    }

    if (deliveryDetail == null) {
      return Center(
        child: Text(
          'Không tìm thấy thông tin đơn hàng',
          style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
        ),
      );
    }

    final images = deliveryDetail!['images'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mã đơn hàng, trạng thái, giá
          Card(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.blue,
                    size: isLargeScreen ? 24 : 20,
                  ),
                  SizedBox(width: isLargeScreen ? 12 : 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Mã đơn hàng: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 16 : 14,
                            ),
                          ),
                          TextSpan(
                            text: deliveryDetail!['orderCode'] ?? '',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: isLargeScreen ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isLargeScreen ? 12 : 8),
                  Text(
                    '${deliveryDetail!['deliveryPrice'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 24 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),

          // Thông tin thời gian
          Card(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.pink,
                        size: isLargeScreen ? 24 : 20,
                      ),
                      SizedBox(width: isLargeScreen ? 12 : 8),
                      Text(
                        'Thông tin thời gian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isLargeScreen ? 18 : 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 16 : 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày tạo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 12 : 10,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 4 : 2),
                            Text(
                              _formatDate(deliveryDetail!['createdAt'] ?? ''),
                              style: TextStyle(
                                fontSize: isLargeScreen ? 11 : 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isLargeScreen ? 20 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày giao hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 12 : 10,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 4 : 2),
                            Text(
                              deliveryDetail!['deliveredAt'] != null
                                  ? _formatDate(deliveryDetail!['deliveredAt'])
                                  : 'Chưa có',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 11 : 9,
                                color: Colors.grey[600],
                              ),
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
          SizedBox(height: isLargeScreen ? 20 : 16),

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
              SizedBox(width: isLargeScreen ? 16 : 12),
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
          SizedBox(height: isLargeScreen ? 20 : 16),

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
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: isSender ? Colors.red : Colors.green,
                  size: isLargeScreen ? 22 : 18,
                ),
                SizedBox(width: isLargeScreen ? 10 : 8),
                Text(
                  isSender ? 'Người gửi' : 'Người nhận',
                  style: TextStyle(
                    color: isSender ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person,
                  size: isLargeScreen ? 20 : 18,
                  color: Colors.grey[700],
                ),
                SizedBox(width: isLargeScreen ? 8 : 6),
                Expanded(
                  child: Text(
                    name ?? '',
                    style: TextStyle(fontSize: isLargeScreen ? 15 : 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: isLargeScreen ? 6 : 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: isLargeScreen ? 20 : 18,
                  color: Colors.grey[700],
                ),
                SizedBox(width: isLargeScreen ? 8 : 6),
                Expanded(
                  child: Text(
                    address ?? '',
                    style: TextStyle(fontSize: isLargeScreen ? 15 : 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: isLargeScreen ? 6 : 4),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: isLargeScreen ? 20 : 18,
                  color: Colors.grey[700],
                ),
                SizedBox(width: isLargeScreen ? 8 : 6),
                Text(
                  phone ?? '',
                  style: TextStyle(fontSize: isLargeScreen ? 15 : 13),
                ),
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
    if (status == null) return '';

    switch (status.toLowerCase()) {
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
        return status;
    }
  }

  // Helper method to get status colors
  List<Color> _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'readytopick':
        return [Colors.blue[50]!, Colors.blue[700]!];
      case 'picked':
        return [Colors.orange[50]!, Colors.orange[700]!];
      case 'delivering':
        return [Colors.yellow[50]!, Colors.yellow[700]!];
      case 'delivered':
        return [Colors.green[50]!, Colors.green[700]!];
      case 'cancelled':
        return [Colors.grey[50]!, Colors.grey[700]!];
      case 'created':
        return [Colors.indigo[50]!, Colors.indigo[700]!];
      case 'shippingtodesigner':
        return [Colors.purple[50]!, Colors.purple[700]!];
      case 'designerrejected':
        return [Colors.red[50]!, Colors.red[700]!];
      case 'inprogress':
        return [Colors.amber[50]!, Colors.amber[700]!];
      case 'completed':
        return [Colors.green[50]!, Colors.green[700]!];
      case 'shippingtocustomer':
        return [Colors.deepPurple[50]!, Colors.deepPurple[700]!];
      case 'customerrejected':
        return [Colors.red[50]!, Colors.red[700]!];
      case 'done':
        return [Colors.teal[50]!, Colors.teal[700]!];
      case 'pendingconflict':
        return [Colors.orange[50]!, Colors.orange[700]!];
      case 'rejected':
        return [Colors.red[50]!, Colors.red[700]!];
      case 'requestshiptocus':
        return [Colors.cyan[50]!, Colors.cyan[700]!];
      default:
        return [Colors.grey[50]!, Colors.grey[700]!];
    }
  }

  // Helper method to get status icons
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'readytopick':
        return Icons.schedule;
      case 'picked':
        return Icons.local_shipping;
      case 'delivering':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'created':
        return Icons.add_circle;
      case 'shippingtodesigner':
        return Icons.forward;
      case 'designerrejected':
        return Icons.block;
      case 'inprogress':
        return Icons.pending;
      case 'completed':
        return Icons.done_all;
      case 'shippingtocustomer':
        return Icons.local_shipping_outlined;
      case 'customerrejected':
        return Icons.thumb_down;
      case 'done':
        return Icons.verified;
      case 'pendingconflict':
        return Icons.warning;
      case 'rejected':
        return Icons.close;
      case 'requestshiptocus':
        return Icons.assignment_return;
      default:
        return Icons.info;
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
                  color: Colors.black.withValues(alpha: 0.3),
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
