import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../redux/app_state.dart';
import '../redux/auth_actions.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import '../widgets/order_status_row.dart';

import '../screens/delivery_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? userReputation;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load both user profile and reputation data
      final profile = await UserService.getUserProfile();
      final reputation = await UserService.getUserReputation();

      setState(() {
        userProfile = profile;
        userReputation = reputation;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getLevelText(int? level) {
    return level?.toString() ?? '0';
  }

  Color _getLevelColor(int? level) {
    switch (level) {
      case 1:
        return Colors.orange[700]!; // Level 1
      case 2:
        return Colors.grey[400]!; // Level 2
      case 3:
        return Colors.amber[600]!; // Level 3
      case 4:
        return Colors.blue[300]!; // Level 4
      case 5:
        return Colors.cyan[300]!; // Level 5
      default:
        return Colors.orange[700]!;
    }
  }

  String _translateRole(String? role) {
    switch (role) {
      case 'Customer':
        return 'Khách hàng';
      case 'Freelancer':
        return 'Freelancer';
      case 'Admin':
        return 'Quản trị viên';
      case 'Staff':
        return 'Nhân viên';
      case 'Designer':
        return 'Thiết kế';
      default:
        return role ?? 'Không xác định';
    }
  }

  String _translateGender(String? gender) {
    switch (gender) {
      case 'Male':
        return 'Nam';
      case 'Female':
        return 'Nữ';
      case 'Other':
        return 'Khác';
      default:
        return gender ?? 'Không xác định';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Không xác định';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Không xác định';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Clear token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userInfo');

    // Clear Redux state
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ClearAuthAction());

    // Navigate to login screen
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ của tôi',
          style: TextStyle(fontSize: isLargeScreen ? 22 : 20),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: isLargeScreen ? 70 : 60,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 16.0 : 8.0,
          vertical: isLargeScreen ? 16.0 : 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header - All in one row
            Card(
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: isLargeScreen ? 28 : 22,
                      backgroundColor: Colors.blue[100],
                      backgroundImage:
                          userProfile?['avatar'] != null &&
                              userProfile!['avatar'].toString().isNotEmpty
                          ? NetworkImage(userProfile!['avatar'])
                          : null,
                      child:
                          userProfile?['avatar'] == null ||
                              userProfile!['avatar'].toString().isEmpty
                          ? Icon(
                              Icons.person,
                              size: isLargeScreen ? 28 : 22,
                              color: Colors.blue,
                            )
                          : null,
                    ),
                    SizedBox(width: isLargeScreen ? 12 : 10),

                    // User info
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            userProfile?['fullName'] ?? 'Đang tải...',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: isLargeScreen ? 12 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 12 : 8,
                              vertical: isLargeScreen ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _translateRole(userProfile?['roleDisplay']),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: isLargeScreen ? 12 : 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reputation stats inline - Compact
                    Row(
                      children: [
                        _buildReputationItem(
                          'Điểm',
                          userReputation?['currentScore']?.toString() ?? '0',
                          Icons.star,
                          Colors.amber,
                          iconSize: isLargeScreen ? 22 : 18,
                          valueSize: isLargeScreen ? 18 : 16,
                          labelSize: isLargeScreen ? 11 : 10,
                        ),
                        SizedBox(width: isLargeScreen ? 20 : 16),
                        _buildReputationItem(
                          'Cấp',
                          _getLevelText(userReputation?['level']),
                          Icons.emoji_events,
                          _getLevelColor(userReputation?['level']),
                          iconSize: isLargeScreen ? 22 : 18,
                          valueSize: isLargeScreen ? 18 : 16,
                          labelSize: isLargeScreen ? 11 : 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // User details grid
            if (userProfile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Each detail on one row
                    Column(
                      children: [
                        _buildDetailCard(
                          Icons.phone,
                          'Số điện thoại',
                          userProfile!['phoneNumber'] ?? 'Không có',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          Icons.email,
                          'Email',
                          userProfile!['email'] ?? 'Không có',
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          Icons.person_outline,
                          'Giới tính',
                          _translateGender(userProfile!['genderDisplay']),
                          Colors.purple,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          Icons.calendar_today,
                          'Ngày tạo',
                          _formatDate(userProfile!['createdAt']),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đơn mua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Đơn mua row
                  OrderStatusRow(
                    // waitingConfirm: 0, // TODO: truyền số thực tế
                    // waitingPickup: 1, // TODO: truyền số thực tế
                    // delivering: 0, // TODO: truyền số thực tế
                    // toReview: 2, // TODO: truyền số thực tế
                    onTap: (status) {
                      // Map status code to Vietnamese display name
                      String initialStatus = 'Tất cả';
                      switch (status) {
                        case 'ReadyToPick':
                          initialStatus = 'Sẵn sàng lấy hàng';
                          break;
                        case 'Picked':
                          initialStatus = 'Đã lấy hàng';
                          break;
                        case 'Delivering':
                          initialStatus = 'Đang giao';
                          break;
                        case 'Delivered':
                          initialStatus = 'Đã giao';
                          break;
                      }

                      // Navigate to DeliveryListScreen with the selected status
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DeliveryListScreen(initialStatus: initialStatus),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    double iconSize = 24,
    double valueSize = 18,
    double labelSize = 12,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: iconSize),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: labelSize, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    double iconSize = 20,
    double labelSize = 12,
    double valueSize = 14,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: iconSize),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 14 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isLargeScreen ? 18 : 16),
          SizedBox(width: isLargeScreen ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 12 : 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 4 : 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
