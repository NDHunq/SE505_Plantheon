import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  const BasicAppbar({Key? key, this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title ?? 'Trợ lý ảo Bích',
        style: const TextStyle(
          color: AppColors.primary_700,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/vectors/arrow_back.svg',
          width: 28,
          height: 28,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: (actions?.isNotEmpty ?? false) ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
