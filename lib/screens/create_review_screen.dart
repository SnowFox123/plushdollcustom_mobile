import 'package:flutter/material.dart';
import '../models/progress_review.dart';
import '../services/progress_service.dart';

class CreateReviewScreen extends StatefulWidget {
  final String progressStepID;
  final String stepTitle;

  const CreateReviewScreen({
    Key? key,
    required this.progressStepID,
    required this.stepTitle,
  }) : super(key: key);

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  int _qualityScore = 0;
  bool _isDesignAccurate = false;
  bool _isMaterialCorrect = false;
  bool _isColorCorrect = false;
  bool _isFunctionalityMet = false;
  
  bool _isSubmitting = false;

  int _qualityStars(int qualityScore) {
    final stars = (qualityScore / 2).floor();
    if (stars < 0) return 0;
    if (stars > 5) return 5;
    return stars;
  }

  int _criteriaPoints() {
    int points = 0;
    if (_isDesignAccurate) points += 5;
    if (_isMaterialCorrect) points += 5;
    if (_isColorCorrect) points += 5;
    if (_isFunctionalityMet) points += 5;
    return points;
  }

  int _totalScore() {
    // qualityScore is 0..10; add 5 for each true criterion
    return _qualityScore + _criteriaPoints();
  }

  bool _isPass() {
    return _totalScore() >= 25;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = ProgressReview(
        progressStepID: widget.progressStepID,
        qualityScore: _qualityScore,
        isDesignAccurate: _isDesignAccurate,
        isMaterialCorrect: _isMaterialCorrect,
        isColorCorrect: _isColorCorrect,
        isFunctionalityMet: _isFunctionalityMet,
        customerComment: _commentController.text.trim(),
      );

      await ProgressService.postProgressReview(
        progressStepID: review.progressStepID,
        qualityScore: review.qualityScore,
        isDesignAccurate: review.isDesignAccurate,
        isMaterialCorrect: review.isMaterialCorrect,
        isColorCorrect: review.isColorCorrect,
        isFunctionalityMet: review.isFunctionalityMet,
        customerComment: review.customerComment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá đã được gửi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quality Score
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điểm chất lượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
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
                              final stars = _qualityStars(_qualityScore);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  index < stars ? Icons.star : Icons.star_border,
                                  size: 20,
                                  color: Colors.amber[600],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _qualityScore.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 5,
                        activeColor: Colors.blue[600],
                        onChanged: (value) {
                          setState(() {
                            _qualityScore = value.round();
                          });
                        },
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$_qualityScore/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (_) {
                          final pass = _isPass();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: pass ? Colors.green[50] : Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: pass ? Colors.green[200]! : Colors.red[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      pass ? Icons.check_circle : Icons.cancel,
                                      size: 16,
                                      color: pass ? Colors.green[700] : Colors.red[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      pass ? 'Đạt' : 'Không đạt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: pass ? Colors.green[700] : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.score,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tổng điểm: ${_totalScore()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rất kém',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Rất tốt',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Criteria Checkboxes
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiêu chí đánh giá',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildCheckboxTile(
                        'Thiết kế chính xác',
                        _isDesignAccurate,
                        (value) => setState(() => _isDesignAccurate = value ?? false),
                        Icons.design_services,
                      ),
                      
                      _buildCheckboxTile(
                        'Chất liệu đúng yêu cầu',
                        _isMaterialCorrect,
                        (value) => setState(() => _isMaterialCorrect = value ?? false),
                        Icons.inventory,
                      ),
                      
                      _buildCheckboxTile(
                        'Màu sắc đúng yêu cầu',
                        _isColorCorrect,
                        (value) => setState(() => _isColorCorrect = value ?? false),
                        Icons.palette,
                      ),
                      
                      _buildCheckboxTile(
                        'Chức năng đáp ứng yêu cầu',
                        _isFunctionalityMet,
                        (value) => setState(() => _isFunctionalityMet = value ?? false),
                        Icons.check_circle,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comment
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhận xét của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập nhận xét của bạn về sản phẩm...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nhận xét';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: _getIconColor(icon),
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
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Color _getIconColor(IconData icon) {
    switch (icon) {
      case Icons.design_services:
        return Colors.blue[600]!;
      case Icons.inventory:
        return Colors.green[600]!;
      case Icons.palette:
        return Colors.orange[600]!;
      case Icons.check_circle:
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
