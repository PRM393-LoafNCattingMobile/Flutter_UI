import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/cat_detail_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class CatGalleryScreen extends StatefulWidget {
  const CatGalleryScreen({super.key});

  @override
  State<CatGalleryScreen> createState() => _CatGalleryScreenState();
}

class _CatGalleryScreenState extends State<CatGalleryScreen> {
  final searchController = TextEditingController();
  String selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CatProvider>().load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatProvider>();
    final cats = _filteredCats(provider.cats);
    return Scaffold(
      body: CafeSurface(
        child: Column(
          children: [
            const _CatHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Tìm mèo'),
                onSubmitted: (value) => provider.load(search: value),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CatFilterChip(
                    label: 'Tất cả',
                    icon: Icons.pets,
                    selected: selectedFilter == 'Tất cả',
                    onSelected: () => setState(() => selectedFilter = 'Tất cả'),
                  ),
                  _CatFilterChip(
                    label: 'Đang làm việc',
                    icon: Icons.circle,
                    selected: selectedFilter == 'Đang làm việc',
                    color: loafSuccess,
                    onSelected: () =>
                        setState(() => selectedFilter = 'Đang làm việc'),
                  ),
                  _CatFilterChip(
                    label: 'Bị bệnh',
                    icon: Icons.nightlight_round,
                    selected: selectedFilter == 'Bị bệnh',
                    color: const Color(0xFF4D6FB8),
                    onSelected: () =>
                        setState(() => selectedFilter = 'Bị bệnh'),
                  ),
                  _CatFilterChip(
                    label: 'Xin nghỉ',
                    icon: Icons.favorite,
                    selected: selectedFilter == 'Xin nghỉ',
                    color: Theme.of(context).colorScheme.error,
                    onSelected: () =>
                        setState(() => selectedFilter = 'Xin nghỉ'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cats.isEmpty
                      ? const EmptyView('Không tìm thấy mèo.')
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: .72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: cats.length,
                          itemBuilder: (_, index) => CatCard(cat: cats[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Cat> _filteredCats(List<Cat> cats) {
    final filter = selectedFilter.toLowerCase();
    if (filter == 'tất cả') return cats;
    return cats.where((cat) {
      final status = cat.statusName.toLowerCase();
      if (filter == 'đang làm việc') return status.contains('đang làm việc');
      if (filter == 'bị bệnh') return status.contains('bị bệnh');
      return status.contains('xin nghỉ');
    }).toList();
  }
}

class _CatHeader extends StatelessWidget {
  const _CatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).padding.top + 10, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: loafBrown,
          ),
          Expanded(
            child: Text(
              'Các bé mèo',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: loafBrown,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0x14D2691E),
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.pets, color: loafOrange),
          ),
        ],
      ),
    );
  }
}

class _CatFilterChip extends StatelessWidget {
  const _CatFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
    this.color = loafOrange,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: selected ? Colors.white : color),
        label: Text(label),
        selected: selected,
        selectedColor: color,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class CatCard extends StatelessWidget {
  const CatCard({super.key, required this.cat});
  final Cat cat;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, cat.statusName);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CatDetailScreen(cat: cat))),
      child: CafeCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CafeImageFrame(
                      imageUrl: cat.picture,
                      icon: Icons.pets,
                      label: cat.name,
                      borderRadius: 18,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          color: loafOrange, size: 19),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    cat.breed ?? AppStrings.unknownBreed,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: loafMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  CafeInfoChip(label: cat.statusName, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final lower = status.toLowerCase();
    if (lower.contains('đang làm việc')) return loafSuccess;
    if (lower.contains('bị bệnh')) {
      return const Color(0xFF4D6FB8);
    }
    return Theme.of(context).colorScheme.error;
  }
}
