import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ViewReviewScreen extends StatefulWidget {
  final String progressStepID;
  final String stepTitle;

  const ViewReviewScreen({
    Key? key,
    required this.progressStepID,
    required this.stepTitle,
  }) : super(key: key);

  @override
  State<ViewReviewScreen> createState() => _ViewReviewScreenState();
}

class _ViewReviewScreenState extends State<ViewReviewScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _reviewData;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ProgressService.getReviewDetail(
        progressStepID: widget.progressStepID,
      );
      setState(() {
        // API returns a list with the review data in the first item
        _reviewData = data.isNotEmpty ? data.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) return '---';
    try {
      final date = DateTime.parse(dateString.toString());
      // Convert UTC to UTC+7 (Vietnam timezone)
      final vietnamTime = date.add(const Duration(hours: 7));
      return '${vietnamTime.day}/${vietnamTime.month}/${vietnamTime.year} ${vietnamTime.hour}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '---';
    }
  }

  // Helpers for scoring logic
  num _getQualityScore(Map<String, dynamic> data) {
    final dynamic raw = data['qualityScore'];
    if (raw == null) return 0;
    if (raw is num) return raw;
    final parsed = num.tryParse(raw.toString());
    return parsed ?? 0;
  }

  int _criteriaPoints(Map<String, dynamic> data) {
    int points = 0;
    if (data['isDesignAccurate'] == true) points += 5;
    if (data['isMaterialCorrect'] == true) points += 5;
    if (data['isColorCorrect'] == true) points += 5;
    if (data['isFunctionalityMet'] == true) points += 5;
    return points;
  }

  num _totalScore(Map<String, dynamic> data) {
    return _getQualityScore(data) + _criteriaPoints(data);
  }

  bool _isPassComputed(Map<String, dynamic> data) {
    return _totalScore(data) >= 25;
  }

  int _qualityStars(num qualityScore) {
    // Every 2 points = 1 star; clamp 0..5
    final stars = (qualityScore / 2).floor();
    if (stars < 0) return 0;
    if (stars > 5) return 5;
    return stars;
  }

  Widget _buildCriteriaItem(String title, bool value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Text(
              value ? 'Đạt' : 'Không đạt',
              style: TextStyle(
                fontSize: 12,
                color: value ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375).clamp(0.85, 1.1).toDouble();
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá: ${widget.stepTitle}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi tải dữ liệu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReview,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _reviewData == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có đánh giá',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bước này chưa có đánh giá nào',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Summary card
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber[600],
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tổng quan đánh giá',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Builder(
                                      builder: (_) {
                                        final total = _totalScore(_reviewData!);
                                        final pass = _isPassComputed(_reviewData!);
                                        final borderColor = pass ? Colors.green[600]! : Colors.red[600]!;
                                        final textColor = pass ? Colors.green[700]! : Colors.red[700]!;
                                        return Column(
                                          children: [
                                            Container(
                                              width: 110,
                                              height: 110,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: borderColor, width: 4),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${total}',
                                                style: TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tổng điểm',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Criteria card
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Tiêu chí đánh giá',
                                        style: TextStyle(
                                          fontSize: 14 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatDate(_reviewData!['createdAt']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Quality score row
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Điểm chất lượng chung',
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(5, (index) {
                                            final stars = _qualityStars(_getQualityScore(_reviewData!));
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2),
                                              child: Icon(
                                                index < stars ? Icons.star : Icons.star_border,
                                                size: 18,
                                                color: Colors.amber[600],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Criteria items with chips
                                  _buildCriteriaItem(
                                    'Thiết kế chính xác',
                                    _reviewData!['isDesignAccurate'] == true,
                                    Icons.design_services,
                                  ),
                                  _buildCriteriaItem(
                                    'Chất liệu đúng yêu cầu',
                                    _reviewData!['isMaterialCorrect'] == true,
                                    Icons.inventory,
                                  ),
                                  _buildCriteriaItem(
                                    'Màu sắc chính xác',
                                    _reviewData!['isColorCorrect'] == true,
                                    Icons.palette,
                                  ),
                                  _buildCriteriaItem(
                                    'Chức năng đáp ứng',
                                    _reviewData!['isFunctionalityMet'] == true,
                                    Icons.check_circle,
                                  ),

                                  if ((_reviewData!['customerComment'] ?? '').toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.orange[200]!),
                                      ),
                                      child: Text(
                                        _reviewData!['customerComment'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.orange[800],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
