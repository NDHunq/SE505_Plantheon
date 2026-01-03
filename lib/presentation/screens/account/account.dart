import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/contact.dart';
import 'package:se501_plantheon/presentation/screens/account/my_post.dart';
import 'package:se501_plantheon/presentation/screens/account/complaint_history.dart';
import 'package:se501_plantheon/presentation/screens/account/widgets/setting_list_item.dart';
import 'package:se501_plantheon/presentation/screens/account/widgets/setting_title_item.dart';
import 'package:se501_plantheon/presentation/screens/authentication/signin.dart';
import 'package:se501_plantheon/presentation/screens/home/scan_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_event.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_provider.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_state.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_event.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:toastification/toastification.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      child: Scaffold(
        appBar: BasicAppbar(title: "Tài khoản", leading: SizedBox()),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.sp,
              children: [
                const _profileCard(),
                PersonalSetting(),
                HelpingSetting(),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BasicDialog(
                        title: 'Xác nhận đăng xuất',
                        content: 'Bạn có chắc chắn muốn đăng xuất?',
                        confirmText: 'Đăng xuất',
                        cancelText: 'Huỷ',
                        onConfirm: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AuthBloc>().add(const LogoutRequested());
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const SignInPage(),
                            ),
                            (route) => false,
                          );
                        },
                        onCancel: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE6F3F1),
                      borderRadius: BorderRadius.circular(12.0.sp),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
                      child: SettingListItem(
                        leading: SizedBox(),
                        text: "Đăng xuất",
                        action: SvgPicture.asset(
                          AppVectors.logout,
                          width: 20.sp,
                          height: 20.sp,
                          color: AppColors.primary_700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _profileCard extends StatefulWidget {
  const _profileCard();

  @override
  State<_profileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_profileCard> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String? _editedAvatar;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return _profileSkeleton();
        }

        if (state is UserError) {
          return _profileSkeleton(
            title: 'Không tải được thông tin',
            subtitle: 'Thử lại sau',
          );
        }

        if (state is UserLoaded || state is UserUpdating) {
          final user = state is UserLoaded
              ? state.user
              : (state as UserUpdating).user;
          _syncUserToFields(user);

          final roleText = user.role.toLowerCase() == 'admin'
              ? 'Quản trị viên'
              : 'Thành viên Plantheon';
          final avatarUrl = _editedAvatar ?? user.avatar;
          final avatar = avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : const AssetImage('assets/images/plants.jpg') as ImageProvider;

          final saving = state is UserUpdating;

          return _profileLayout(
            name: _nameController.text.isNotEmpty
                ? _nameController.text
                : (user.fullName.isNotEmpty ? user.fullName : user.username),
            roleText: roleText,
            avatar: avatar,
            context: context,
            isEditing: _isEditing,
            isSaving: saving,
          );
        }

        return _profileSkeleton();
      },
    );
  }

  Widget _profileLayout({
    required String name,
    required String roleText,
    required ImageProvider avatar,
    required BuildContext context,
    required bool isEditing,
    required bool isSaving,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.sp,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary_200.withOpacity(0.3),
          width: 1.sp,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            Container(
              height: 56.sp,
              width: 56.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary_200, width: 1.sp),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                      : avatar,
                ),
              ),
              child: isEditing
                  ? Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppVectors.camera,
                            width: 16.sp,
                            height: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                spacing: 6.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing
                      ? TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.sp,
                              vertical: 8.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            hintText: 'Nhập tên hiển thị',
                          ),
                          style: AppTextStyles.s16Bold(color: Colors.grey[800]),
                        )
                      : Text(
                          name,
                          style: AppTextStyles.s16Bold(
                            color: Colors.grey[800],
                          ).copyWith(letterSpacing: 0.5.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary_50,
                      borderRadius: BorderRadius.circular(20.sp),
                      border: Border.all(
                        color: AppColors.primary_200,
                        width: 1.sp,
                      ),
                    ),
                    child: Text(
                      roleText,
                      style: AppTextStyles.s12Medium(
                        color: AppColors.primary_700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isEditing) ...[
              IconButton(
                icon: isSaving
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const LoadingIndicator(),
                      )
                    : SvgPicture.asset(
                        AppVectors.file,
                        width: 22.sp,
                        height: 22.sp,
                        color: AppColors.primary_600,
                      ),
                onPressed: isSaving ? null : _saveProfile,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.red),
                onPressed: isSaving ? null : _cancelEdit,
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: SvgPicture.asset(
                  AppVectors.userEdit,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_main,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileSkeleton({String? title, String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(
          color: AppColors.primary_200.withOpacity(0.3),
          width: 1.sp,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            Container(
              height: 52.sp,
              width: 52.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.text_color_50,
              ),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: Column(
                spacing: 8.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Đang tải...',
                    style: AppTextStyles.s16Bold(color: Colors.grey[600]),
                  ),
                  Text(
                    subtitle ?? 'Vui lòng chờ',
                    style: AppTextStyles.s12Medium(
                      color: AppColors.text_color_300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.sp),
          ],
        ),
      ),
    );
  }

  void _syncUserToFields(user) {
    if (!_isEditing) {
      _nameController.text = user.fullName.isNotEmpty
          ? user.fullName
          : user.username;
      _editedAvatar = user.avatar;
    }
  }

  void _saveProfile() {
    final bloc = context.read<UserBloc>();
    () async {
      try {
        String? newAvatarUrl = _editedAvatar;
        // upload if picked new bytes
        if (_avatarBytes != null) {
          final state = bloc.state;
          String userId = 'user';
          if (state is UserLoaded) {
            userId = state.user.id;
          } else if (state is UserUpdating) {
            userId = state.user.id;
          }
          final fileName =
              'avatars/$userId-${DateTime.now().millisecondsSinceEpoch}.png';
          newAvatarUrl = await SupabaseService.uploadFileFromBytes(
            bucketName: 'public',
            fileBytes: _avatarBytes!,
            fileName: fileName,
          );
        }

        bloc.add(
          UpdateProfileEvent(
            fullName: _nameController.text.trim(),
            avatar: newAvatarUrl,
          ),
        );
        setState(() {
          _isEditing = false;
          _avatarBytes = null;
          _editedAvatar = newAvatarUrl;
        });
      } catch (e) {
        if (mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            title: Text('Không thể lưu: $e'),
            alignment: Alignment.bottomCenter,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      }
    }();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editedAvatar = null;
      _avatarBytes = null;
    });
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (dialogContext) => BasicDialog(
        title: 'Chọn ảnh đại diện',
        content: '',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _pickImage(ImageSource.camera);
              },
              icon: SvgPicture.asset(
                AppVectors.camera,
                width: 20.sp,
                height: 20.sp,
                color: Colors.white,
              ),
              label: Text('Chụp ảnh'),
            ),
            SizedBox(height: 8.sp),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _pickImage(ImageSource.gallery);
              },
              icon: SvgPicture.asset(
                AppVectors.gallery,
                width: 20.sp,
                height: 20.sp,
                color: Colors.white,
              ),
              label: const Text('Chọn từ thư viện'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
        _editedAvatar = null;
      });
    } catch (e) {
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text('Không thể chọn ảnh: $e'),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }
}

class PersonalSetting extends StatefulWidget {
  const PersonalSetting({super.key});

  @override
  _PersonalSettingState createState() => _PersonalSettingState();
}

class _PersonalSettingState extends State<PersonalSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE6F3F1),
        borderRadius: BorderRadius.circular(12.0.sp),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingTitleItem(text: "Cá nhân"),
            Divider(height: 1.sp, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MyPost(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.report,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Bài viết của tôi",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1.sp, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ScanHistory(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.history,
                  width: 19.sp,
                  height: 19.sp,
                  color: AppColors.primary_700,
                ),
                text: "Lịch sử quét bệnh",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpingSetting extends StatefulWidget {
  const HelpingSetting({super.key});

  @override
  State<HelpingSetting> createState() => _HelpingSettingState();
}

class _HelpingSettingState extends State<HelpingSetting> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }


  void _showDeleteAccountDialog() {
    _passwordController.clear();
    
    // Capture the parent context that has access to UserBloc
    final parentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<UserBloc, UserState>(
        bloc: parentContext.read<UserBloc>(),
        listener: (context, state) {
          if (state is UserDeleted) {
            // Close dialog
            Navigator.of(dialogContext).pop();

            // Logout and navigate to login
            parentContext.read<AuthBloc>().add(const LogoutRequested());
            Navigator.of(parentContext).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => const SignInPage(),
              ),
              (route) => false,
            );

            // Show success message
            toastification.show(
              context: parentContext,
              type: ToastificationType.success,
              title: Text('Tài khoản đã được xóa thành công'),
              alignment: Alignment.bottomCenter,
              autoCloseDuration: const Duration(seconds: 3),
            );
          } else if (state is UserError) {
            // Show error toast
            toastification.show(
              context: parentContext,
              type: ToastificationType.error,
              title: Text(state.message),
              alignment: Alignment.bottomCenter,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          bloc: parentContext.read<UserBloc>(),
          builder: (context, state) {
            final isDeleting = state is UserDeleting;

            return BasicDialog(
              title: 'Xác nhận xóa tài khoản',
              content:
                  'Hành động này sẽ xóa vĩnh viễn tài khoản và tất cả dữ liệu của bạn. Vui lòng nhập mật khẩu để xác nhận.',
              confirmText: isDeleting ? 'Đang xóa...' : 'Xóa tài khoản',
              cancelText: 'Hủy',
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                enabled: !isDeleting,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              onConfirm: isDeleting
                  ? null
                  : () {
                      final password = _passwordController.text.trim();
                      if (password.isEmpty) {
                        toastification.show(
                          context: parentContext,
                          type: ToastificationType.warning,
                          title: Text('Vui lòng nhập mật khẩu'),
                          alignment: Alignment.bottomCenter,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                        return;
                      }

                      // Dispatch delete account event
                      parentContext.read<UserBloc>().add(
                        DeleteAccountEvent(password: password),
                      );
                    },
              onCancel: isDeleting
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE6F3F1),
        borderRadius: BorderRadius.circular(12.0.sp),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingTitleItem(text: "Hỗ trợ"),
            Divider(height: 1.sp, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Contact(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.phone,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Liên hệ",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1.sp, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const ComplaintHistory(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.postReport,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Báo cáo",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1.sp, color: AppColors.white),
            GestureDetector(
              onTap: _showDeleteAccountDialog,
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.trash,
                  width: 20.sp,
                  height: 20.sp,
                  color: Colors.red[700],
                ),
                text: "Xóa tài khoản",
                action: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  size: 20.sp,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
