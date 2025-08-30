import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../services/progress_service.dart';
import '../widgets/empty_order_widget.dart';
import '../widgets/phase_status_badge.dart';
import '../screens/create_review_screen.dart';
import '../screens/view_review_screen.dart';

// Mapping backend order statuses to Vietnamese labels (consistent with list screen)
const Map<String, String> kOrderStatusViMap = {
  'Created': 'Đã tạo mới',
  'ShippingToDesigner': 'Đang giao cho NTK',
  'DesignerRejected': 'NTK từ chối',
  'InProgress': 'Đang thực hiện',
  'Completed': 'Đã hoàn thành',
  'ShippingToCustomer': 'Đang giao cho khách',
  'CustomerRejected': 'Khách từ chối',
  'Done': 'Hoàn tất',
  'PendingConflict': 'Đang xử lý tranh chấp',
  'Rejected': 'Bị từ chối',
  'RequestShipToCus': 'Yêu cầu trả hàng cho KH',
};

Color _statusBgColor(String status) {
  switch (status.trim()) {
    case 'Created':
      return Colors.grey[100]!;
    case 'ShippingToDesigner':
      return Colors.indigo[50]!;
    case 'DesignerRejected':
      return Colors.red[50]!;
    case 'InProgress':
      return Colors.blue[50]!;
    case 'Completed':
      return Colors.green[50]!;
    case 'ShippingToCustomer':
      return Colors.orange[50]!;
    case 'CustomerRejected':
      return Colors.red[50]!;
    case 'Done':
      return Colors.teal[50]!;
    case 'PendingConflict':
      return Colors.amber[50]!;
    case 'Rejected':
      return Colors.red[50]!;
    case 'RequestShipToCus':
      return Colors.cyan[50]!;
    case 'Cancelled':
      return Colors.red[50]!;
    default:
      return Colors.grey[50]!;
  }
}

Color _statusTextColor(String status) {
  switch (status.trim()) {
    case 'Created':
      return Colors.grey[800]!;
    case 'ShippingToDesigner':
      return Colors.indigo[700]!;
    case 'DesignerRejected':
      return Colors.red[700]!;
    case 'InProgress':
      return Colors.blue[700]!;
    case 'Completed':
      return Colors.green[700]!;
    case 'ShippingToCustomer':
      return Colors.orange[700]!;
    case 'CustomerRejected':
      return Colors.red[700]!;
    case 'Done':
      return Colors.teal[700]!;
    case 'PendingConflict':
      return Colors.amber[800]!;
    case 'Rejected':
      return Colors.red[700]!;
    case 'RequestShipToCus':
      return Colors.cyan[700]!;
    case 'Cancelled':
      return Colors.red[700]!;
    default:
      return Colors.grey[800]!;
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

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetail;
  const OrderDetailScreen({Key? key, required this.orderDetail})
    : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String mapProgressStepTypeToVietnamese(String? stepType) {
    switch (stepType) {
      case 'NewDesign':
        return 'Thiết kế mới';
      case 'Rework':
        return 'Làm lại';
      default:
        return stepType ?? '';
    }
  }

  String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  String formatDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) return '---';
    try {
      final date = DateTime.parse(dateString.toString());
      // Convert UTC to UTC+7 (Vietnam timezone)
      final vietnamTime = date.add(const Duration(hours: 7));
      return '${vietnamTime.day}/${vietnamTime.month}/${vietnamTime.year}';
    } catch (e) {
      return '---';
    }
  }

  Color getPhaseStatusColor(String? status) {
    switch (status) {
      case 'Dealed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String mapPhaseStatusToVietnamese(String? status) {
    switch (status) {
      case 'NotStarted':
        return 'Chưa bắt đầu';
      case 'Dealed':
        return 'Đã chốt';
      case 'Deposited':
        return 'Đã đặt cọc';
      case 'Withdrawed':
        return 'Đã rút tiền';
      case 'InProgress':
        return 'Đang thực hiện';
      case 'Rework':
        return 'Yêu cầu\nchỉnh sửa';
      case 'Done':
        return 'Hoàn thành';
      case 'Refund':
        return 'Hoàn tiền';
      default:
        return status ?? '';
    }
  }

  bool isDone(String? status) {
    return status == 'Done' || status == 'Hoàn thành';
  }

  bool isCurrent(String? status) {
    return status == 'InProgress' || status == 'Đang thực hiện';
  }

  void _showPhaseProgressDetail(
    BuildContext context,
    String orderID,
    String offerPhaseID,
    String phaseName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PhaseProgressDetailSheet(
        orderID: orderID,
        offerPhaseID: offerPhaseID,
        phaseName: phaseName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderDetail['order'] ?? {};
    final offerPhases = (widget.orderDetail['offerPhases'] ?? []) as List;
    final offer = widget.orderDetail['offer'] ?? {};

    final maxPhase = offerPhases
        .map((e) => e['phase'] ?? 0)
        .fold<int>(0, (prev, el) => el > prev ? el : prev);

    // Sort phases by phase number (largest first)
    final sortedPhases = List.from(offerPhases);
    sortedPhases.sort((a, b) {
      final phaseA = a['phase'] ?? 0;
      final phaseB = b['phase'] ?? 0;
      return phaseB.compareTo(phaseA); // Descending order
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ đơn hàng'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offer['sampleImage'] != null &&
                        offer['sampleImage'].toString().isNotEmpty) ...[
                      GestureDetector(
                        onTap: () =>
                            _showImagePreview(offer['sampleImage'], context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            offer['sampleImage'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Đơn hàng#${(order['orderID'] ?? '').toString().length > 8 ? (order['orderID'] ?? '').toString().substring(0, 8) + '...' : (order['orderID'] ?? '')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBgColor(
                                    (order['orderStatus'] ?? '').toString(),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  kOrderStatusViMap[(order['orderStatus'] ?? '')
                                          .toString()
                                          .trim()] ??
                                      ((order['orderStatus'] ?? '')
                                              .toString()
                                              .trim()
                                              .isEmpty
                                          ? '---'
                                          : (order['orderStatus'] ?? '')
                                                .toString()),
                                  style: TextStyle(
                                    color: _statusTextColor(
                                      (order['orderStatus'] ?? '').toString(),
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order['customerName'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.brush,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order['designerName'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                formatCurrency(order['totalPrice'] ?? 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hoàn thành: ${formatDate(order['deadlineAt'])}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Các giai đoạn thực hiện (${offerPhases.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            if (offerPhases.isEmpty)
              Center(
                child: Text(
                  'Chưa có giai đoạn nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            if (offerPhases.isNotEmpty)
              FixedTimeline.tileBuilder(
                builder: TimelineTileBuilder.connectedFromStyle(
                  contentsAlign: ContentsAlign.alternating,
                  oppositeContentsBuilder: (context, index) {
                    final phase = sortedPhases[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              phase['startDate'] != null &&
                                  phase['endDate'] != null
                              ? Colors.blue[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                phase['startDate'] != null &&
                                    phase['endDate'] != null
                                ? Colors.blue[200]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child:
                            phase['startDate'] != null &&
                                phase['endDate'] != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Từ:  ${formatDate(phase['startDate'])}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Đến:  ${formatDate(phase['endDate'])}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Chưa có thời gian',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    );
                  },
                  contentsBuilder: (context, index) {
                    final phase = sortedPhases[index];
                    final phaseValue = phase['phase'] ?? 0;
                    final current = phaseValue == maxPhase;
                    final done = phaseValue < maxPhase;
                    // final phaseNumber = phase['phase'] ?? (index + 1);
                    final phaseId = phase['offerPhaseID'] ?? '';

                    return Card(
                      elevation: 3,
                      color: current
                          ? Colors.blue[600]
                          : done
                          ? Colors.grey[100]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: done
                              ? Colors.grey[300]!
                              : current
                              ? Colors.blue[100]!
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      shadowColor: current
                          ? Colors.blue[100]
                          : Colors.grey[200],
                      child: InkWell(
                        onTap: () => _showPhaseProgressDetail(
                          context,
                          order['orderID'] ?? '',
                          phaseId,
                          phase['phaseName'] ?? '',
                        ),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      phase['phaseName'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: current
                                            ? Colors.white
                                            : done
                                            ? Colors.grey[700]
                                            : Colors.blue[800],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if ((phase['offerPhaseStatus'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    PhaseStatusBadge(
                                      phaseStatus: phase['offerPhaseStatus'],
                                      fontSize: 9,
                                      iconSize: 12,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                    ),
                                ],
                              ),
                              if ((phase['phaseDescription'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  (phase['phaseDescription'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: current
                                        ? Colors.white70
                                        : done
                                        ? Colors.grey[600]
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                formatCurrency(phase['offerPhasePrice'] ?? 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: current
                                      ? Colors.white
                                      : done
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  connectorStyleBuilder: (context, index) =>
                      ConnectorStyle.solidLine,
                  indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
                  itemCount: sortedPhases.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PhaseProgressDetailSheet extends StatefulWidget {
  final String orderID;
  final String offerPhaseID;
  final String phaseName;
  const PhaseProgressDetailSheet({
    Key? key,
    required this.orderID,
    required this.offerPhaseID,
    required this.phaseName,
  }) : super(key: key);

  @override
  State<PhaseProgressDetailSheet> createState() =>
      _PhaseProgressDetailSheetState();
}

class _PhaseProgressDetailSheetState extends State<PhaseProgressDetailSheet> {
  bool isLoading = true;
  String? error;
  List<dynamic> progressData = [];

  String mapProgressStepTypeToVietnamese(String? stepType) {
    switch (stepType) {
      case 'NewDesign':
        return 'Thiết kế mới';
      case 'Rework':
        return 'Làm lại';
      default:
        return stepType ?? '';
    }
  }



  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ProgressService.getProgressDetail(
        orderID: widget.orderID,
        offerPhaseID: widget.offerPhaseID,
      );
      setState(() {
        progressData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String formatDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) return '---';
    try {
      final date = DateTime.parse(dateString.toString());
      // Convert UTC to UTC+7 (Vietnam timezone)
      final vietnamTime = date.add(const Duration(hours: 7));
      return '${vietnamTime.day}/${vietnamTime.month}/${vietnamTime.year}';
    } catch (e) {
      return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timeline, color: Colors.blue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chi tiết tiến độ: ${widget.phaseName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                    ? Center(
                        child: Text(
                          'Lỗi tải dữ liệu: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : progressData.isEmpty
                    ? const EmptyOrderWidget(message: 'Chưa có tiến độ nào')
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: progressData.length,
                        itemBuilder: (context, idx) {
                          final progressItem = progressData[idx];
                          final progressStep =
                              progressItem['progressStep'] ?? {};
                          final progressImages =
                              (progressItem['progressImages'] ?? []) as List;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step Header
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          progressStep['stepTitle'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if ((progressStep['progressStepType'] ??
                                              '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                progressStep['progressStepType'] ==
                                                    'Rework'
                                                ? Colors.purple[50]
                                                : Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color:
                                                  progressStep['progressStepType'] ==
                                                      'Rework'
                                                  ? Colors.purple[200]!
                                                  : Colors.green[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            mapProgressStepTypeToVietnamese(
                                              progressStep['progressStepType'],
                                            ),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  progressStep['progressStepType'] ==
                                                      'Rework'
                                                  ? Colors.purple[700]
                                                  : Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Bước ${progressStep['stepNumber']?.toString() ?? ''}',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Description
                                  if ((progressStep['description'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      progressStep['description'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],

                                  // Customer Approval Status
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final approval =
                                          progressStep['isApprovedByCustomer'];
                                      // Determine label, icon and color based on approval state
                                      String label;
                                      IconData iconData;
                                      Color iconColor;
                                      Color textColor;

                                      if (approval == true) {
                                        label = 'Đồng ý';
                                        iconData = Icons.check_circle;
                                        iconColor = Colors.green;
                                        textColor = Colors.green[700]!;
                                      } else if (approval == false) {
                                        label = 'Từ chối';
                                        iconData = Icons.cancel;
                                        iconColor = Colors.red;
                                        textColor = Colors.red[700]!;
                                      } else {
                                        label = 'Chờ xem xét';
                                        iconData = Icons.pending;
                                        iconColor = Colors.orange;
                                        textColor = Colors.orange[700]!;
                                      }

                                      return Row(
                                        children: [
                                          Icon(
                                            iconData,
                                            size: 16,
                                            color: iconColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Khách hàng: $label',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  // Review Buttons
                                  const SizedBox(height: 12),
                                  const SizedBox.shrink(),

                                  // Customer Note
                                  if ((progressStep['customerNote'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange[200]!,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ghi chú khách hàng:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            progressStep['customerNote'] ?? '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Images Section
                                  if (progressImages.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Hình ảnh (${progressImages.length})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isSixImages =
                                            progressImages.length == 6;
                                        final imageWidth =
                                            progressImages.length == 1
                                            ? constraints.maxWidth * 0.4
                                            : isSixImages
                                            ? (constraints.maxWidth - 16) / 3
                                            : (constraints.maxWidth - 16) /
                                                  progressImages.length;
                                        final imageHeight =
                                            progressImages.length == 1
                                            ? 120.0
                                            : 80.0;

                                        return Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: progressImages.map<Widget>((
                                            image,
                                          ) {
                                            return Container(
                                              width: imageWidth,
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _showImagePreview(
                                                          image['imageUrl'] ??
                                                              '',
                                                          context,
                                                        ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        image['imageUrl'] ?? '',
                                                        width: imageWidth,
                                                        height: imageHeight,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              width: imageWidth,
                                                              height:
                                                                  imageHeight,
                                                              color: Colors
                                                                  .grey[200],
                                                              child: const Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  if ((image['description'] ??
                                                          '')
                                                      .toString()
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      image['description'] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.grey[600],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],

                                  // Timestamps
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      Icon(
                                        Icons.update,
                                        size: 12,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cập nhật: ${formatDate(progressStep['updateAt'])}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Bottom action button (create/view review)
                                  const SizedBox(height: 12),
                                  Builder(
                                    builder: (context) {
                                      final approval =
                                          progressStep['isApprovedByCustomer'];
                                      final progressStepID =
                                          progressStep['progressStepID'] ?? '';
                                      final stepTitle =
                                          progressStep['stepTitle'] ?? '';

                                      if (approval == null) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateReviewScreen(
                                                            progressStepID:
                                                                progressStepID,
                                                            stepTitle:
                                                                stepTitle,
                                                          ),
                                                    ),
                                                  );
                                              if (result == true) {
                                                _fetchProgress();
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.rate_review,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Tạo đánh giá',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange[600],
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              minimumSize:
                                                  const Size.fromHeight(48),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewReviewScreen(
                                                        progressStepID:
                                                            progressStepID,
                                                        stepTitle: stepTitle,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.visibility,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Xem đánh giá',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[600],
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              minimumSize:
                                                  const Size.fromHeight(48),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
