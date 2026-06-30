import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';

/// Thanh lọc theo trạng thái dùng chung cho màn Orders và Reservations.
/// `selectedId == null` nghĩa là "Tất cả trạng thái".
class AdminStatusFilterBar extends StatelessWidget {
  const AdminStatusFilterBar({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<LookupItem> options;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DropdownButtonFormField<int?>(
        initialValue: selectedId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: AppStrings.adminFilterByStatusLabel,
          prefixIcon: Icon(Icons.filter_list),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text(AppStrings.adminFilterAllStatuses),
          ),
          ...options.map(
            (option) => DropdownMenuItem<int?>(
              value: option.id,
              child: Text(option.name),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Định dạng ngày giờ ngắn gọn dd/MM/yyyy HH:mm cho danh sách admin/staff.
String formatAdminDateTime(DateTime dateTime) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(dateTime.day)}/${two(dateTime.month)}/${dateTime.year} '
      '${two(dateTime.hour)}:${two(dateTime.minute)}';
}
