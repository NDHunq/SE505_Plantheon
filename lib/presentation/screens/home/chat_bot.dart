import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
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
          left: 10,
          right: 10,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Nhập tin nhắn...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.text_color_50,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.text_color_50,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.primary_main,
                  width: 1,
                ),
              ),
              prefixIcon: IconButton(
                icon: SvgPicture.asset(
                  AppVectors.gallery,
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
              suffixIcon: IconButton(
                icon: SvgPicture.asset(AppVectors.send, width: 24, height: 24),
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    sendMessage(messageController.text);
                    messageController.clear();
                  }
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 0,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              ? const EdgeInsets.only(top: 5, bottom: 5, left: 50)
              : const EdgeInsets.only(top: 5, bottom: 5, right: 50),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary_400 : Color(0xFFECE6F0),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: isMe
                          ? const Radius.circular(15)
                          : const Radius.circular(3),
                      bottomRight: isMe
                          ? const Radius.circular(3)
                          : const Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 14,
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
