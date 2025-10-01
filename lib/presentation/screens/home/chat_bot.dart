import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [
    Message(
      content:
          "Xin chào, tôi là Bích - trợ lý ảo của bạn. Bạn cần giúp gì không?",
      isMe: false,
    ),
  ];
  bool isLoading = false; // Thêm biến trạng thái loading

  void sendMessage(String message) async {}

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BasicAppbar(
        title: 'Trợ lý ảo Bích',
        actions: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: AppColors.primary_700),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10.sp,
          right: 10.sp,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Nhập tin nhắn...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.text_color_50,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.sp),
                borderSide: BorderSide(
                  color: AppColors.text_color_50,
                  width: 1.sp,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.sp),
                borderSide: BorderSide(
                  color: AppColors.primary_main,
                  width: 1.sp,
                ),
              ),
              prefixIcon: IconButton(
                icon: SvgPicture.asset(
                  AppVectors.gallery,
                  width: 24.sp,
                  height: 24.sp,
                ),
                onPressed: () {},
              ),
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  AppVectors.send,
                  width: 24.sp,
                  height: 24.sp,
                ),
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    sendMessage(messageController.text);
                    messageController.clear();
                  }
                },
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
        child: ListView.builder(
          itemCount: messages.length,
          controller: _scrollController,
          itemBuilder: (context, index) {
            return _messageCard(
              isMe: messages[index].isMe,
              message: messages[index].content,
            );
          },
        ),
      ),
    );
  }
}

class Message {
  final String content;
  final bool isMe;

  Message({required this.content, required this.isMe});
}

class _messageCard extends StatelessWidget {
  final bool isMe;
  final String message;

  const _messageCard({required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: isMe
              ? EdgeInsets.only(top: 5.sp, bottom: 5.sp, left: 50.sp)
              : EdgeInsets.only(top: 5.sp, bottom: 5.sp, right: 50.sp),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.sp,
                    vertical: 10.sp,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary_400 : Color(0xFFECE6F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.sp),
                      topRight: Radius.circular(15.sp),
                      bottomLeft: isMe
                          ? Radius.circular(15.sp)
                          : Radius.circular(3.sp),
                      bottomRight: isMe
                          ? Radius.circular(3.sp)
                          : Radius.circular(15.sp),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 14.sp,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
