import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/diary/widget/navigation.dart';

/// Ví dụ sử dụng CustomNavigationBar
class NavigationExampleScreen extends StatelessWidget {
  const NavigationExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Ví dụ 1: Navigation với 3 nút chức năng cơ bản
          CustomNavigationBar(
            title: "Nhật ký",
            actions: [
              CommonNavigationActions.add(
                onPressed: () => _showSnackBar(context, "Thêm mới"),
              ),
              CommonNavigationActions.search(
                onPressed: () => _showSnackBar(context, "Tìm kiếm"),
              ),
              CommonNavigationActions.menu(
                onPressed: () => _showSnackBar(context, "Menu"),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Ví dụ 2: Navigation với custom colors
          CustomNavigationBar(
            title: "Chi tiết ngày",
            backgroundColor: Colors.blue.shade50,
            textColor: Colors.blue.shade800,
            iconColor: Colors.blue.shade600,
            actions: [
              CommonNavigationActions.edit(
                onPressed: () => _showSnackBar(context, "Chỉnh sửa"),
              ),
              CommonNavigationActions.share(
                onPressed: () => _showSnackBar(context, "Chia sẻ"),
              ),
              CommonNavigationActions.delete(
                onPressed: () => _showSnackBar(context, "Xóa"),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Ví dụ 3: Navigation không có nút back
          CustomNavigationBar(
            title: "Trang chủ",
            showBackButton: false,
            actions: [
              CommonNavigationActions.refresh(
                onPressed: () => _showSnackBar(context, "Làm mới"),
              ),
              CommonNavigationActions.search(
                onPressed: () => _showSnackBar(context, "Tìm kiếm"),
              ),
              CommonNavigationActions.menu(
                onPressed: () => _showSnackBar(context, "Menu"),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Ví dụ 4: Navigation với custom actions
          CustomNavigationBar(
            title: "Tùy chỉnh",
            actions: [
              NavigationAction.custom(
                child: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _showSnackBar(context, "Yêu thích"),
                backgroundColor: Colors.red.shade50,
                borderColor: Colors.red.shade200,
              ),
              NavigationAction.custom(
                child: const Icon(Icons.bookmark, color: Colors.orange),
                onPressed: () => _showSnackBar(context, "Đánh dấu"),
                backgroundColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade200,
              ),
              NavigationAction.custom(
                child: const Icon(Icons.download, color: Colors.green),
                onPressed: () => _showSnackBar(context, "Tải xuống"),
                backgroundColor: Colors.green.shade50,
                borderColor: Colors.green.shade200,
              ),
            ],
          ),
          
          const Spacer(),
          
          // Nút để test navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationExampleScreen(),
                  ),
                );
              },
              child: const Text("Test Navigation"),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Widget để demo cách tích hợp CustomNavigationBar vào Diary screen
class DiaryWithCustomNavigation extends StatelessWidget {
  const DiaryWithCustomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomNavigationBar(
            title: "Nhật ký ${DateTime.now().year}",
            actions: [
              CommonNavigationActions.add(
                onPressed: () => _showAddNewModal(context),
              ),
              CommonNavigationActions.search(
                onPressed: () => _showSearchModal(context),
              ),
              CommonNavigationActions.menu(
                onPressed: () => _showMenuModal(context),
              ),
            ],
          ),
          
          // Nội dung chính của diary
          const Expanded(
            child: Center(
              child: Text(
                "Nội dung diary sẽ được hiển thị ở đây",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Center(
          child: Text("Modal thêm mới"),
        ),
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tìm kiếm"),
        content: const TextField(
          decoration: InputDecoration(
            hintText: "Nhập từ khóa tìm kiếm...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tìm"),
          ),
        ],
      ),
    );
  }

  void _showMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Cài đặt"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Trợ giúp"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Thông tin"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
