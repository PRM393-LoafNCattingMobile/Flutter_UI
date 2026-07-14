import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';

class CatDetailScreen extends StatelessWidget {
  const CatDetailScreen({super.key, required this.cat});
  final Cat cat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cat.name)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CafeHeroHeader(
              title: cat.name,
              subtitle:
                  '${cat.breed ?? 'Chưa rõ giống'} - ${cat.genderName ?? 'Chưa rõ'} - ${cat.age ?? '?'} tuổi',
              icon: Icons.pets,
              playful: true,
            ),
            AspectRatio(
              aspectRatio: 16 / 11,
              child: CafeImageFrame(
                imageUrl: cat.picture,
                icon: Icons.pets,
                label: cat.name,
                borderRadius: 20,
              ),
            ),
            const SizedBox(height: 14),
            CafeCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CafeInfoChip(
                      label: cat.statusName,
                      icon: Icons.favorite,
                      color: _statusColor(context, cat.statusName)),
                  const SizedBox(height: 12),
                  Text(
                    cat.description ?? 'Bé mèo này chưa có mô tả.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: loafMuted, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CafeMetricRow(
                icon: Icons.volunteer_activism_outlined,
                label: 'Thân thiện',
                value: '${cat.friendlinessRating ?? '-'} / 5'),
            const SizedBox(height: 10),
            CafeMetricRow(
                icon: Icons.auto_awesome,
                label: 'Đáng yêu',
                value: '${cat.cutenessRating ?? '-'} / 5'),
            const SizedBox(height: 10),
            CafeMetricRow(
                icon: Icons.toys_outlined,
                label: 'Năng động',
                value: '${cat.playfulnessRating ?? '-'} / 5'),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final lower = status.toLowerCase();
    if (lower.contains('đang làm việc')) return loafSuccess;
    if (lower.contains('bị bệnh')) return const Color(0xFF4D6FB8);
    return Theme.of(context).colorScheme.error;
  }
}
