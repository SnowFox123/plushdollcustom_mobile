import 'package:flutter/material.dart';
import '../services/delivery_service.dart';
import '../models/delivery.dart';
import '../widgets/delivery_status_chip.dart';
import 'delivery_detail_screen.dart';
import '../widgets/animated_arrow.dart';

class DeliveryListScreen extends StatefulWidget {
  final String? initialStatus;

  const DeliveryListScreen({super.key, this.initialStatus});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  List<Delivery> deliveries = [];
  List<Delivery> filteredDeliveries = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedSortOption = 'Tất cả';

  // Define sort options
  final List<String> sortOptions = [
    'Tất cả',
    'Sẵn sàng lấy hàng',
    'Đã lấy hàng',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial status if provided
    if (widget.initialStatus != null) {
      selectedSortOption = widget.initialStatus!;
    }
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final deliveryData = await DeliveryService.getDelivery();

      setState(() {
        deliveries = deliveryData
            .map((json) => Delivery.fromJson(json))
            .toList();
        _applySorting();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _applySorting() {
    if (selectedSortOption == 'Tất cả') {
      filteredDeliveries = List.from(deliveries);
    } else {
      filteredDeliveries = deliveries.where((delivery) {
        // Map Vietnamese display names back to actual status codes
        String targetStatus = '';
        switch (selectedSortOption) {
          case 'Sẵn sàng lấy hàng':
            targetStatus = 'ReadyToPick';
            break;
          case 'Đã lấy hàng':
            targetStatus = 'Picked';
            break;
          case 'Đang giao':
            targetStatus = 'Delivering';
            break;
          case 'Đã giao':
            targetStatus = 'Delivered';
            break;
          case 'Đã hủy':
            targetStatus = 'Cancelled';
            break;
          default:
            targetStatus = selectedSortOption;
        }

        return delivery.deliveryStatus == targetStatus;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn giao hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveries,
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Filter
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: sortOptions.map((status) {
                            final isSelected = selectedSortOption == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedSortOption = status;
                                    _applySorting();
                                  });
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: Colors.blue[100],
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.blue[700]
                                      : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.blue[600]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Deliveries List
          Expanded(child: _buildBody()),
        ],
      ),
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
              onPressed: _loadDeliveries,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (filteredDeliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              selectedSortOption == 'Tất cả'
                  ? 'Không có đơn giao hàng nào'
                  : 'Không có đơn hàng với trạng thái "$selectedSortOption"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              selectedSortOption == 'Tất cả'
                  ? 'Bạn chưa có đơn giao hàng nào'
                  : 'Thử chọn trạng thái khác hoặc tạo đơn hàng mới',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = filteredDeliveries[index];
          return _buildDeliveryCard(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DeliveryDetailScreen(deliveryId: delivery.deliveryId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã đơn hàng + trạng thái
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mã đơn hàng: ${delivery.orderCode}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DeliveryStatusChip(
                    status: delivery.deliveryStatus,
                    customLabel: delivery.statusDisplayName,
                    backgroundColor: Colors.amber[50],
                    textColor: Colors.brown[700],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ngày tạo
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Ngày tạo: ${delivery.formattedCreatedAt}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Box người gửi - người nhận
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Người gửi',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            delivery.senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Thay thế Icon bằng AnimatedArrow
                    AnimatedArrow(size: 26, color: Colors.blue),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Người nhận',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            delivery.receiverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Phí giao hàng
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Phí giao hàng: ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${delivery.deliveryPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (delivery.note != null && delivery.note!.isNotEmpty) ...[
                const Divider(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Ghi chú: ${delivery.note}',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
