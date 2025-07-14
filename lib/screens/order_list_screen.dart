import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart'; // Added import for OrderDetailScreen
import '../widgets/empty_order_widget.dart'; // Thêm import widget empty

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<List<dynamic>> _ordersFuture;
  List<dynamic> _allOrders = [];
  List<dynamic> _filteredOrders = [];
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  final List<String> _statusOptions = [
    'Tất cả',
    'Đang thực hiện',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchOrders() async {
    final orders = await OrderService.getOrder();
    _allOrders = orders;
    _filteredOrders = orders;
    return orders;
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final orderStatus = order['orderStatus'] ?? '';
        final note = (order['note'] ?? '').toString().toLowerCase();
        final orderID = (order['orderID'] ?? '').toString().toLowerCase();

        // Filter by status
        bool statusMatch = _selectedStatus == 'Tất cả';
        if (!statusMatch) {
          String statusText = '';
          switch (orderStatus) {
            case 'InProgress':
              statusText = 'Đang thực hiện';
              break;
            case 'Completed':
              statusText = 'Hoàn thành';
              break;
            case 'Cancelled':
              statusText = 'Đã hủy';
              break;
          }
          statusMatch = statusText == _selectedStatus;
        }

        // Filter by search query
        bool searchMatch =
            _searchQuery.isEmpty ||
            note.contains(_searchQuery.toLowerCase()) ||
            orderID.contains(_searchQuery.toLowerCase());

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  // Thêm hàm định dạng tiền tệ
  String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearchExpanded
              ? Container(
                  key: const ValueKey('search'),
                  width: 320,
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10, // Để text nằm giữa theo chiều dọc
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = false;
                            _searchController.clear();
                            _searchQuery = '';
                            _filterOrders();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterOrders();
                    },
                  ),
                )
              : const Text(
                  'Đơn hàng của tôi',
                  key: ValueKey('title'),
                  style: TextStyle(fontSize: 20),
                ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSearchExpanded
                ? const SizedBox.shrink()
                : IconButton(
                    key: const ValueKey('search_icon'),
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                  ),
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
                          children: _statusOptions.map((status) {
                            final isSelected = _selectedStatus == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedStatus = status;
                                    _filterOrders();
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
          // Orders List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (_filteredOrders.isEmpty) {
                  return const EmptyOrderWidget(
                    message: 'Không có đơn hàng nào',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    final orderID = order['orderID'] ?? '---';
                    final orderStatus = order['orderStatus']?.toString() ?? '';
                    final totalPrice = order['totalPrice'] ?? 0.0;
                    final requiredDeposit = order['requiredDepositAmount'] ?? 0;
                    final designerDeposit = order['designerDepositAmount'] ?? 0;
                    final note = order['note'] ?? '';
                    final startDate = order['startDate']?.toString() ?? '';
                    final deadlineAt = order['deadlineAt']?.toString() ?? '';
                    final createdAt = order['createdAt'] ?? '';

                    // Format date
                    String formatDate(String dateString) {
                      if (dateString.isEmpty) return '---';
                      try {
                        final date = DateTime.parse(dateString);
                        return '${date.day}/${date.month}/${date.year}';
                      } catch (e) {
                        return '---';
                      }
                    }

                    // Format status
                    String getStatusText(String status) {
                      switch (status.trim()) {
                        case 'InProgress':
                          return 'Đang thực hiện';
                        case 'Completed':
                          return 'Hoàn thành';
                        case 'Cancelled':
                          return 'Đã hủy';
                        default:
                          return status.trim().isEmpty ? '---' : status;
                      }
                    }

                    return GestureDetector(
                      onTap: () async {
                        final detail = await OrderService.getOrderDetail(
                          orderId: orderID,
                        );
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailScreen(orderDetail: detail),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blue.withOpacity(0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mã đơn + trạng thái
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Đơn hàng #${orderID.length > 8 ? orderID.substring(0, 8) + '...' : orderID}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: orderStatus == 'InProgress'
                                          ? Colors.blue[50]
                                          : orderStatus == 'Completed'
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      getStatusText(orderStatus),
                                      style: TextStyle(
                                        color: orderStatus == 'InProgress'
                                            ? Colors.blue[700]
                                            : orderStatus == 'Completed'
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Ghi chú
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  note.isNotEmpty ? note : 'Không có ghi chú',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Thông tin tiền
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng tiền:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(totalPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Đặt cọc yêu cầu:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(requiredDeposit),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Designer đã cọc:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(designerDeposit),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Ngày bắt đầu & deadline
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bắt đầu:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDate(startDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Hoàn thành:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDate(deadlineAt),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
