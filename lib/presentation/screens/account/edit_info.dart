import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BasicAppbar(title: "Chỉnh sửa thông tin"),
      body: Center(child: Text("Edit Info Screen")),
    );
  }
}
