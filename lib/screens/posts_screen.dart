import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:PlushDollCustom/screens/posts_screen_detail.dart';
import '../widgets/post_status_badge.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String? error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  List<dynamic> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await PostService.getPost();
      setState(() {
        posts = response['items'] ?? [];
        _filteredPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterPosts() {
    setState(() {
      _filteredPosts = posts.where((post) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final fullName = (post['fullName'] ?? '').toString().toLowerCase();

        return _searchQuery.isEmpty ||
            title.contains(_searchQuery.toLowerCase()) ||
            fullName.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(
      dateTimeStr,
    ).toUtc().add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
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
                  alignment: Alignment.center,
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
                            _filterPosts();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterPosts();
                    },
                  ),
                )
              : const Text(
                  'Bài đăng dự án',
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
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi: $error'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchPosts,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    cacheExtent: 500,
                    itemCount: _filteredPosts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return InkWell(
                        onTap: () {
                          showPostDetailModal(context, post['projectPostID']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      (post['originalImages'] != null &&
                                          post['originalImages'].isNotEmpty)
                                      ? post['originalImages'][0]['imageUrl']
                                      : 'assets/images/logo_hinh.png',
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                post['avatar'] ?? '',
                                              ),
                                          backgroundColor: Colors.grey[300],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            post['fullName'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      post['title'] ?? 'Không có tiêu đề',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Giá sản phẩm: ',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _formatCurrency(
                                              post['itemValue'],
                                            ),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),

                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Giá đề xuất: ',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _formatCurrency(
                                              post['suggestedPrice'],
                                            ),
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        PostStatusBadge(
                                          postStatus: post['postStatus'],
                                          fontSize: 10,
                                          iconSize: 12,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 6,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 13,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${DateFormat('dd/MM/yyyy').format(DateTime.parse(post['finishDate']).add(const Duration(hours: 7)))}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
        ),
      ),
    );
  }
}
