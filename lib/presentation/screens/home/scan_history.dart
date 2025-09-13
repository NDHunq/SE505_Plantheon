import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/history_card.dart';

class ScanHistory extends StatefulWidget {
  const ScanHistory({super.key});

  @override
  State<ScanHistory> createState() => _ScanHistoryState();
}

class _ScanHistoryState extends State<ScanHistory> {
  final List<Map<String, dynamic>> _historyList = [
    {'title': 'Cây trồng 1', 'dateTime': '20/10/2023 14:30', 'isSuccess': true},
    {
      'title': 'Cây trồng 2',
      'dateTime': '21/10/2023 10:00',
      'isSuccess': false,
    },
    {'title': 'Cây trồng 3', 'dateTime': '22/10/2023 09:00', 'isSuccess': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Lịch sử quét bệnh',
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BasicDialog(
                  title: "Xóa lịch sử quét bệnh",
                  content:
                      "Bạn có chắc chắn muốn xóa tất cả lịch sử quét bệnh?",
                  onConfirm: () {
                    setState(() {
                      _historyList.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
            icon: SvgPicture.asset(AppVectors.trash, width: 24, height: 24),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          itemCount: _historyList.length,
          separatorBuilder: (context, index) => Divider(
            height: 16,
            color: AppColors.text_color_100,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final item = _historyList[index];
            return Dismissible(
              key: ValueKey(item['dateTime']),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                setState(() {
                  _historyList.removeAt(index);
                });
              },
              child: HistoryCard(
                title: item['title'],
                dateTime: item['dateTime'],
                isSuccess: item['isSuccess'],
              ),
            );
          },
        ),
      ),
    );
  }
}
