import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OfferCardWidget extends StatelessWidget {
  final Map<String, dynamic> offer;
  final Function(String) onImageTap;

  const OfferCardWidget({
    super.key,
    required this.offer,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = offer['offerStatus'] == 'Accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAccepted
            ? const Color(
                0xFFF0F9FF,
              ) // Light blue background for accepted offers
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF6366F1) // Blue border for accepted offers
              : const Color(0xFFE5E7EB),
          width: isAccepted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isAccepted
                        ? const Color(0xFF6366F1)
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    offer['avatar'] ?? 'assets/images/logo_hinh.png',
                  ),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offer['fullName'] ?? 'Người dùng',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (isAccepted) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF6366F1),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDateTime(offer['createdAt'] ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _buildOfferStatusBadge(offer['offerStatus'] ?? ''),
            ],
          ),

          // Price information
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceInfo(
                  'Giá ban đầu',
                  '${offer['initPrice']?.toStringAsFixed(0) ?? '0'} đ',
                  Colors.grey[600]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceInfo(
                  'Giá chốt',
                  '${offer['finalPrice']?.toStringAsFixed(0) ?? '0'} đ',
                  const Color(0xFF6366F1),
                ),
              ),
            ],
          ),

          // Deposit price if available
          if (offer['designerDepositPrice'] != null &&
              offer['designerDepositPrice'] > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPriceInfo(
                    'Đặt cọc',
                    '${offer['designerDepositPrice']?.toStringAsFixed(0) ?? '0'} đ',
                    Colors.orange[600]!,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(), // Empty space for alignment
                ),
              ],
            ),
          ],

          // Deadline information
          if (offer['deadlineEndAt'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Hạn hoàn thành: ${_formatDate(offer['deadlineEndAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Note/Description
          if (offer['note'] != null && offer['note'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ghi chú từ nhà thiết kế',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer['note'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Sample image if available
          if (offer['sampleImage'] != null &&
              offer['sampleImage'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Mẫu thiết kế',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onImageTap(offer['sampleImage']),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: offer['sampleImage'],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'accepted':
        badgeColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        statusText = 'Đã chấp nhận';
        break;
      case 'pending':
        badgeColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        statusText = 'Đang chờ';
        break;
      case 'rejected':
        badgeColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        statusText = 'Đã từ chối';
        break;
      case 'dealing':
        badgeColor = Colors.yellow[50]!;
        textColor = Colors.yellow[700]!;
        statusText = 'Đang giao dịch';
        break;
      default:
        badgeColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        statusText = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.parse(dateStr).add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  String _formatDateTime(String dateStr) {
    final dt = DateTime.parse(dateStr).add(const Duration(hours: 7));
    return DateFormat('HH:mm dd/MM/yyyy').format(dt);
  }
}
