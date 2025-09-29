import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';

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
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 14,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[50],
                        child: Icon(
                          Icons.person,
                          size: 44,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Thành viên Plantheon',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.blue[700]),
                        title: Text(
                          'nguyenvana@example.com',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text('Email', style: TextStyle(fontSize: 13)),
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.green[700]),
                        title: Text(
                          '0123 456 789',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Số điện thoại',
                          style: TextStyle(fontSize: 13),
                        ),
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.red[700],
                        ),
                        title: Text(
                          '123 Đường ABC, Quận 1, TP.HCM',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Địa chỉ',
                          style: TextStyle(fontSize: 13),
                        ),
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Thông tin hỗ trợ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.blue[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Colors.blue[700],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hotline: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text('1900 1234', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.blue[700],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Email hỗ trợ: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'support@plantheon.com',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.web, color: Colors.blue[700], size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Website: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'www.plantheon.com',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
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
}
