import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class ImageComparisonScreen extends StatefulWidget {
  final File? myImage;
  final String? myImageLink;
  final List<String> diseaseImageUrls;
  final int initialIndex;

  const ImageComparisonScreen({
    super.key,
    required this.myImage,
    this.myImageLink,
    required this.diseaseImageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageComparisonScreen> createState() => _ImageComparisonScreenState();
}

class _ImageComparisonScreenState extends State<ImageComparisonScreen> {
  late CarouselSliderController _carouselController;
  late int _currentImageIndex;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = widget.initialIndex;
    _carouselController = CarouselSliderController();
    print("my image link: ${widget.myImageLink}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final centerY = constraints.maxHeight / 2;

            return Stack(
              children: [
                Column(
                  children: [
                    // Top half - User's image
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child:
                            widget.myImageLink != null &&
                                widget.myImageLink!.isNotEmpty
                            ? Image.network(
                                widget.myImageLink!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64.sp,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : widget.myImage != null
                            ? Image.file(widget.myImage!, fit: BoxFit.contain)
                            : Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64.sp,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    Container(height: 2.sp, color: AppColors.white),
                    // Bottom half - Disease reference images carousel
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              carouselController: _carouselController,
                              itemCount: widget.diseaseImageUrls.length,
                              itemBuilder: (context, index, realIndex) {
                                return Image.network(
                                  widget.diseaseImageUrls[index],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 64.sp,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                );
                              },
                              options: CarouselOptions(
                                height: double.infinity,
                                viewportFraction: 1.0,
                                autoPlay: true,
                                initialPage: widget.initialIndex,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                              ),
                            ),
                            // Page indicators
                            if (widget.diseaseImageUrls.length > 1)
                              Positioned(
                                bottom: 16.sp,
                                left: 0.sp,
                                right: 0.sp,
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.sp,
                                      vertical: 6.sp,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(
                                        20.sp,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        widget.diseaseImageUrls.length,
                                        (index) => Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 3.sp,
                                          ),
                                          width: _currentImageIndex == index
                                              ? 24.sp
                                              : 8.sp,
                                          height: 8.sp,
                                          decoration: BoxDecoration(
                                            color: _currentImageIndex == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(
                                              4.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Label for user's image (top)
                Positioned(
                  bottom: centerY + 8.sp,
                  right: 16.sp,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Text(
                      'Ảnh của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Label for reference images (bottom)
                Positioned(
                  top: centerY + 8.sp,
                  right: 16.sp,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Text(
                      'Ảnh tham khảo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 16.sp,
                  left: 16.sp,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8.sp),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}