import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';

String catStatusDisplayName(String statusName) {
  final lower = statusName.toLowerCase();
  if (lower.contains('đang làm việc')) return 'Đang ở quán';
  if (lower.contains('bị bệnh')) return 'Đang được chăm sóc';
  if (lower.contains('xin nghỉ')) return 'Đang nghỉ';
  return statusName;
}

Color catStatusColor(BuildContext context, String statusName) {
  final lower = statusName.toLowerCase();
  if (lower.contains('đang làm việc')) return loafSuccess;
  if (lower.contains('bị bệnh')) return const Color(0xFF4D6FB8);
  return Theme.of(context).colorScheme.error;
}
