import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';

/// Bottom sheet chọn trạng thái mới từ danh sách lookup. Trả về id đã chọn,
/// hoặc null khi người dùng đóng mà không chọn.
Future<int?> showStatusPicker(
  BuildContext context, {
  required String title,
  required List<LookupItem> options,
  String? currentName,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
          ),
          ...options.map(
            (option) => ListTile(
              title: Text(option.name),
              trailing: option.name == currentName
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => Navigator.pop(sheetContext, option.id),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
