import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/datasources/keyword_activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/data/repository/keyword_activity_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/keyword_activity/get_keyword_activities.dart';
import 'package:se501_plantheon/presentation/screens/scan/activities_suggestion_section.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';

// Đoạn HTML giải pháp khuyến nghị
const String _solutionHtml = '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <h3>Giải pháp phòng trừ</h3>
  <ul>
    <li><strong>Biện pháp canh tác:</strong> Trồng với mật độ phù hợp, tưới nước vào gốc, vệ sinh đồng ruộng, loại bỏ lá bệnh.</li>
    <li><strong>Biện pháp hóa học:</strong> Sử dụng thuốc diệt nấm như <b>Edifenphos 50.0% EC</b>, phun định kỳ 7-10 ngày/lần, luân phiên các loại thuốc để tránh kháng thuốc.</li>
  </ul>
  <p style="background-color: #FFF3CD; padding: 8px; border-radius: 8px; color: #856404;">
    <b>⚠️ Lưu ý:</b> Chọn và áp dụng <b>CHỈ MỘT</b> sản phẩm cho cây trồng của bạn.
  </p>
</div>
''';

class ScanSolution extends StatelessWidget {
  final String diseaseLabel;
  const ScanSolution({super.key, required this.diseaseLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        title: 'Scan Solution',
        actions: [
          Icon(Icons.share_rounded, color: AppColors.primary_main),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Diagnosis Result
            _SectionTitle(
              index: 1,
              title: 'Kết quả chẩn đoán',
              action: TextButton(
                onPressed: () {},
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _DiagnosisCard(),
            const SizedBox(height: 20),
            Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            // 2. Recommended Product
            _SectionTitle(index: 2, title: 'Giải pháp khuyến nghị'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Html(
                data: _solutionHtml,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "h3": Style(
                    color: Color(0xFF388E3C),
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.w600,
                    margin: Margins.only(top: 16, bottom: 8),
                  ),
                  "p": Style(
                    fontSize: FontSize(14),
                    lineHeight: const LineHeight(1.6),
                    margin: Margins.only(bottom: 12),
                    color: Colors.black87,
                  ),
                  "ul": Style(margin: Margins.only(bottom: 12)),
                  "li": Style(
                    fontSize: FontSize(14),
                    lineHeight: const LineHeight(1.5),
                    margin: Margins.only(bottom: 4),
                    color: Colors.black87,
                  ),
                  "strong": Style(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _SectionTitle(index: 3, title: 'Hoạt động gợi ý'),
            const SizedBox(height: 12),
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) {
                    final repository = ActivitiesRepositoryImpl(
                      remoteDataSource: ActivitiesRemoteDataSourceImpl(
                        client: http.Client(),
                      ),
                    );
                    return ActivitiesBloc(
                      getActivitiesByMonth: GetActivitiesByMonth(repository),
                      getActivitiesByDay: GetActivitiesByDay(repository),
                      createActivity: CreateActivity(repository),
                      updateActivity: UpdateActivity(repository),
                      deleteActivity: DeleteActivity(repository),
                    );
                  },
                ),
                BlocProvider(
                  create: (_) {
                    final repository = KeywordActivityRepositoryImpl(
                      remoteDataSource: KeywordActivitiesRemoteDataSourceImpl(
                        client: http.Client(),
                      ),
                    );
                    return KeywordActivitiesBloc(
                      getKeywordActivities: GetKeywordActivities(repository),
                    )..add(
                      FetchKeywordActivities(
                        diseaseId: '006c9e8c-2f71-4608-9134-6b9f3ff9c1e1',
                      ),
                    );
                  },
                ),
              ],
              child: const ActivitiesSuggestionList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int index;
  final String title;
  final Widget? action;
  const _SectionTitle({required this.index, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/plants.jpg',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: const Text(
          'Bệnh đốm nâu hại lúa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Nấm'),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF757575),
        ),
        onTap: () {},
      ),
    );
  }
}

class _ProductDropdown extends StatefulWidget {
  @override
  State<_ProductDropdown> createState() => _ProductDropdownState();
}

class _ProductDropdownState extends State<_ProductDropdown> {
  String value = 'Lúa nước';
  final items = ['Lúa nước', 'Ngô', 'Khoai', 'Cà chua'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => value = v!),
        ),
      ),
    );
  }
}

// class _ProductCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8F9FA),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFE0E0E0)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.sanitizer_rounded,
//                 color: Color(0xFF1976D2),
//                 size: 32,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Thuốc diệt nấm',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Edifenphos 50.0% EC',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right_rounded, color: Color(0xFF757575)),
//           ],
//         ],
//       ),
//     );
//   }
// }
