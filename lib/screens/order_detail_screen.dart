import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../services/progress_service.dart';
import '../widgets/empty_order_widget.dart';

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
      case 'Redesign':
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
        return 'Yêu cầu chỉnh sửa';
      case 'Done':
        return 'Hoàn thành';
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
          fontSize: 18,
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
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
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
                      const SizedBox(width: 12),
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
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  order['orderStatus'] == 'InProgress'
                                      ? 'Đang thực hiện'
                                      : order['orderStatus'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
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
                                style: const TextStyle(fontSize: 14),
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
                                style: const TextStyle(fontSize: 14),
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
                                  fontSize: 15,
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
                                  fontSize: 14,
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
                fontSize: 16,
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
                    final phaseValue = phase['phase'] ?? 0;
                    final current = phaseValue == maxPhase;
                    final done = phaseValue < maxPhase;

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
                    final phaseNumber = phase['phase'] ?? (index + 1);
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
                                        fontSize: 17,
                                        color: current
                                            ? Colors.white
                                            : done
                                            ? Colors.grey[700]
                                            : Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                  if ((phase['offerPhaseStatus'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: current
                                            ? Colors.white
                                            : done
                                            ? Colors.grey[200]
                                            : Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        mapPhaseStatusToVietnamese(
                                          phase['offerPhaseStatus'],
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: current
                                              ? Colors.blue[600]
                                              : done
                                              ? Colors.grey[700]
                                              : Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                    fontSize: 15,
                                    color: current
                                        ? Colors.white70
                                        : done
                                        ? Colors.grey[600]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                formatCurrency(phase['offerPhasePrice'] ?? 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
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
      case 'Redesign':
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
                        fontSize: 18,
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
                                            fontSize: 16,
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
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            mapProgressStepTypeToVietnamese(
                                              progressStep['progressStepType'],
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[700],
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
                                            fontSize: 12,
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
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],

                                  // Customer Approval Status
                                  if (progressStep['isApprovedByCustomer'] !=
                                      null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          progressStep['isApprovedByCustomer'] ==
                                                  true
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          size: 16,
                                          color:
                                              progressStep['isApprovedByCustomer'] ==
                                                  true
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Khách hàng: ${progressStep['isApprovedByCustomer'] == true ? 'Đã duyệt' : 'Chờ duyệt'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                progressStep['isApprovedByCustomer'] ==
                                                    true
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

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
                                              fontSize: 12,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            progressStep['customerNote'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
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
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final imageWidth =
                                            progressImages.length == 1
                                            ? constraints.maxWidth * 0.6
                                            : (constraints.maxWidth - 16) /
                                                  progressImages.length;
                                        final imageHeight =
                                            progressImages.length == 1
                                            ? 200.0
                                            : 120.0;

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
                                                        fontSize: 11,
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
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
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
