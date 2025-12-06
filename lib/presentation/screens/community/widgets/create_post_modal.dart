import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_event.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_state.dart';
import 'package:se501_plantheon/presentation/bloc/community/community_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/community/community_bloc.dart'
    as community;
import 'package:se501_plantheon/data/repository/post_repository_impl.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';

class CreatePostModal extends StatefulWidget {
  final String? diseaseId;

  const CreatePostModal({super.key, this.diseaseId});

  static void show(BuildContext context, {String? diseaseId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) {
                  final dataSource = DiseaseRemoteDataSourceImpl(
                    client: http.Client(),
                    baseUrl: ApiConstants.diseaseApiUrl,
                  );
                  final repository = DiseaseRepositoryImpl(
                    remoteDataSource: dataSource,
                  );
                  return DiseaseBloc(
                    getDisease: GetDisease(repository: repository),
                  );
                },
              ),
              BlocProvider(
                create: (context) {
                  final dataSource = PostRemoteDataSource(
                    client: http.Client(),
                    tokenStorage:
                        (context.read<AuthBloc>().authRepository
                                as AuthRepositoryImpl)
                            .tokenStorage,
                  );
                  final repository = PostRepositoryImpl(
                    remoteDataSource: dataSource,
                  );
                  return CommunityBloc(postRepository: repository);
                },
              ),
            ],
            child: CreatePostModal(diseaseId: diseaseId),
          ),
        );
      },
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _postController = TextEditingController();

  // Dropdown cho thể loại bài viết
  String _selectedCategory = 'Đời sống';
  final List<String> _categories = [
    'Đời sống',
    'Cây trồng',
    'Chăm sóc',
    'Kinh nghiệm',
    'Thảo luận',
    'Hỏi đáp',
    'Khác',
  ];

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isDiseaseLinked = true;

  @override
  void initState() {
    super.initState();
    if (widget.diseaseId != null) {
      _isDiseaseLinked = true;
      context.read<DiseaseBloc>().add(
        GetDiseaseEvent(diseaseId: widget.diseaseId!),
      );
    } else {
      _isDiseaseLinked = false;
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _createPost() {
    print('CreatePostModal: _createPost called');
    if (_postController.text.trim().isNotEmpty) {
      print('CreatePostModal: Adding CreatePostEvent');
      context.read<CommunityBloc>().add(
        community.CreatePostEvent(
          content: _postController.text,
          imageLink: [], // TODO: Handle image upload if needed
          tags: [_selectedCategory],
          diseaseLink: _isDiseaseLinked ? widget.diseaseId : null,
        ),
      );
    } else {
      print('CreatePostModal: Content is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600.sp, // Increased height to accommodate disease info
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.sp),
          topRight: Radius.circular(20.sp),
        ),
      ),
      child: BlocListener<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is community.CommunityPostCreated) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng bài thành công')),
            );
          } else if (state is community.CommunityError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.message}')));
          }
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.sp,
                    height: 4.sp,
                    margin: EdgeInsets.only(bottom: 16.sp),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.sp),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.s16Regular(
                          color: AppColors.text_color_200,
                        ),
                      ),
                    ),
                    Text('Bài viết mới', style: AppTextStyles.s16Bold()),
                    BlocBuilder<CommunityBloc, CommunityState>(
                      builder: (context, state) {
                        if (state is community.CommunityLoading) {
                          return const CircularProgressIndicator();
                        }
                        return TextButton(
                          onPressed: _createPost,
                          child: Text(
                            'Đăng',
                            style: AppTextStyles.s16Bold(
                              color: AppColors.primary_main,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.sp),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: Colors.green[200],
                      child: Text(
                        'M',
                        style: AppTextStyles.s16Bold(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mot Nguyen', style: AppTextStyles.s16Bold()),
                        Row(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                style: AppTextStyles.s12Regular(
                                  color: Colors.grey[600],
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16.sp,
                                  color: Colors.grey[600],
                                ),
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8.sp),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.sp),

                // Text input
                SizedBox(
                  height: 120.sp,
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Bạn đang nghĩ gì ?',
                      border: InputBorder.none,
                      hintStyle: AppTextStyles.s16Regular(
                        color: AppColors.text_color_100,
                      ),
                    ),
                    style: AppTextStyles.s16Regular(),
                  ),
                ),

                // Disease Link Block
                if (widget.diseaseId != null)
                  if (_isDiseaseLinked)
                    BlocBuilder<DiseaseBloc, DiseaseState>(
                      builder: (context, state) {
                        print('CreatePostModal State: $state');
                        if (state is DiseaseLoading) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.sp),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is DiseaseSuccess) {
                          final disease = state.disease;
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 16.sp),
                                padding: EdgeInsets.all(12.sp),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.sp),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.sp),
                                      child: Image.network(
                                        (disease.imageLink.isNotEmpty)
                                            ? disease.imageLink.first
                                            : 'https://via.placeholder.com/60',
                                        width: 60.sp,
                                        height: 60.sp,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 60.sp,
                                                  height: 60.sp,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.error,
                                                    size: 24.sp,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 12.sp),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            disease.name,
                                            style: AppTextStyles.s14Bold(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.sp),
                                          Text(
                                            'Đang thắc mắc về bệnh này',
                                            style: AppTextStyles.s12Regular(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 4.sp,
                                right: 4.sp,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isDiseaseLinked = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (state is DiseaseError) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.sp),
                            padding: EdgeInsets.all(12.sp),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12.sp),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: AppTextStyles.s14Regular(
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isDiseaseLinked = true;
                              });
                            },
                            icon: Icon(
                              Icons.link,
                              size: 20.sp,
                              color: AppColors.primary_main,
                            ),
                            label: Text(
                              'Liên kết với Scan Solution',
                              style: AppTextStyles.s14Bold(
                                color: AppColors.primary_main,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),
                              backgroundColor: AppColors.primary_main
                                  .withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                SizedBox(height: 16.sp),

                // Image selection area
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 120.sp,
                    maxHeight: _selectedImages.isEmpty ? 120.sp : 300.sp,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: _selectedImages.isEmpty
                      ? InkWell(
                          onTap: _pickImages,
                          child: SizedBox(
                            height: 120.sp,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60.sp,
                                  height: 60.sp,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(12.sp),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 30.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                Text(
                                  'Thêm ảnh',
                                  style: AppTextStyles.s14Regular(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with image count and add more button
                            Padding(
                              padding: EdgeInsets.all(12.sp),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedImages.length} ảnh đã chọn',
                                    style: AppTextStyles.s14Regular(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _pickImages,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.sp,
                                        vertical: 6.sp,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary_main
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          16.sp,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 16.sp,
                                            color: AppColors.primary_main,
                                          ),
                                          SizedBox(width: 4.sp),
                                          Text(
                                            'Thêm ảnh',
                                            style: AppTextStyles.s12Regular(
                                              color: AppColors.primary_main,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Images grid
                            SizedBox(
                              height: 200.sp,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.sp,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8.sp,
                                        mainAxisSpacing: 8.sp,
                                        childAspectRatio: 1,
                                      ),
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.sp,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(
                                                  _selectedImages[index].path,
                                                ),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4.sp,
                                          right: 4.sp,
                                          child: InkWell(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: EdgeInsets.all(2.sp),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 16.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 12.sp),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
