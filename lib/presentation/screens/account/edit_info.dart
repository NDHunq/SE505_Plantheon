import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:toastification/toastification.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'Nam';
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _nameController.text = 'Nguyễn Văn A';
    _addressController.text = '123 Đường ABC, Quận 1, TP.HCM';
    _selectedDate = DateTime(1990, 1, 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BasicDialog(
          title: 'Chọn ảnh đại diện',
          content: '',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gallery Button
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
                icon: Icon(Icons.photo_library, color: Colors.white),
                label: Text(
                  'Chọn từ thư viện',
                  style: AppTextStyles.s16Medium(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary_main,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  minimumSize: Size(double.infinity, 44.sp),
                ),
              ),
              SizedBox(height: 12.sp),
              // Camera Button
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
                icon: Icon(Icons.photo_camera, color: Colors.white),
                label: Text(
                  'Chụp ảnh',
                  style: AppTextStyles.s16Medium(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary_600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  minimumSize: Size(double.infinity, 44.sp),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary_main,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveUserInfo() {
    if (_formKey.currentState!.validate()) {
      // Handle save logic here
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          'Cập nhật thông tin thành công!',
          style: AppTextStyles.s16Medium(color: Colors.white),
        ),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: "Chỉnh sửa thông tin"),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120.sp,
                      height: 120.sp,
                      child: _selectedImage == null
                          ? Container(
                              height: 52.sp,
                              width: 52.sp,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary_200,
                                  width: 2.sp,
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/WREN_EVANS_-_VIETINBANK_2024_-_P2.jpg/250px-WREN_EVANS_-_VIETINBANK_2024_-_P2.jpg',
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36.sp,
                          height: 36.sp,
                          decoration: BoxDecoration(
                            color: AppColors.primary_main,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.sp,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6.sp,
                                offset: Offset(0, 2.sp),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Full Name Field
              _buildInputField(
                label: 'Họ và tên',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender Field
              _buildSectionTitle('Giới tính'),
              SizedBox(height: 8.sp),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.sp),
                  border: Border.all(color: AppColors.primary_200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Nam', style: AppTextStyles.s16Regular()),
                        value: 'Nam',
                        groupValue: _selectedGender,
                        activeColor: AppColors.primary_main,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Nữ', style: AppTextStyles.s16Regular()),
                        value: 'Nữ',
                        groupValue: _selectedGender,
                        activeColor: AppColors.primary_main,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),

              // Date of Birth Field
              _buildSectionTitle('Ngày sinh'),
              SizedBox(height: 8.sp),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: AppColors.primary_200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary_main,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.sp),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTextStyles.s16Regular(
                          color: Colors.grey[800],
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary_main,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.sp),

              // Address Field
              _buildInputField(
                label: 'Địa chỉ',
                controller: _addressController,
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.sp),

              // Save Button
              ElevatedButton(
                onPressed: _saveUserInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary_main,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  elevation: 2.sp,
                ),
                child: Text(
                  'Cập nhật thông tin',
                  style: AppTextStyles.s16SemiBold(),
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
      style: AppTextStyles.s16SemiBold(color: Colors.grey[800]),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        SizedBox(height: 8.sp),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.s16Regular(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary_main, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: AppColors.primary_200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: AppColors.primary_200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(
                color: AppColors.primary_main,
                width: 2.sp,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.sp),
              borderSide: BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(12.sp),
            hintStyle: AppTextStyles.s16Regular(
              color: AppColors.text_color_100,
            ),
          ),
        ),
      ],
    );
  }
}
