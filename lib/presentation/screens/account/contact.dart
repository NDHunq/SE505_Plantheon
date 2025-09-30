import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: "Liên hệ"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company Info Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary_400, AppColors.primary_600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary_400.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.eco, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CÔNG TY TNHH PLANTHEON',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Giải pháp thông minh cho sức khỏe cây trồng',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle('Thông tin liên hệ'),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.location_on,
                        iconColor: Colors.red[600]!,
                        title: 'Địa chỉ',
                        content: '123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.phone,
                        iconColor: Colors.green[600]!,
                        title: 'Điện thoại',
                        content: '(028) 3823 4567',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.email,
                        iconColor: Colors.blue[600]!,
                        title: 'Email',
                        content: 'info@plantheon.com',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.language,
                        iconColor: Colors.purple[600]!,
                        title: 'Website',
                        content: 'www.plantheon.com',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Support Information
              _buildSectionTitle('Thông tin hỗ trợ'),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.support_agent,
                        iconColor: Colors.orange[600]!,
                        title: 'Hotline hỗ trợ',
                        content: '1900 PLANT (1900 75268)',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.email_outlined,
                        iconColor: Colors.teal[600]!,
                        title: 'Email hỗ trợ',
                        content: 'support@plantheon.com',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.schedule,
                        iconColor: Colors.indigo[600]!,
                        title: 'Giờ làm việc',
                        content: 'T2-T6: 8:00 - 17:30, T7: 8:00 - 12:00',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Business Information
              _buildSectionTitle('Thông tin doanh nghiệp'),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.business,
                        iconColor: Colors.brown[600]!,
                        title: 'Mã số thuế',
                        content: '0123456789',
                      ),
                      _buildDivider(),
                      _buildContactItem(
                        icon: Icons.account_balance,
                        iconColor: Colors.cyan[600]!,
                        title: 'Ngân hàng',
                        content: 'Vietcombank - STK: 1234567890',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 0,
      endIndent: 0,
    );
  }
}
