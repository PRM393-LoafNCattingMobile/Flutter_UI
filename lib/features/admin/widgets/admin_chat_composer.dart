import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';

class AdminChatComposer extends StatelessWidget {
  const AdminChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: CafeCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: AppStrings.adminChatComposerHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send),
              label: const Text(AppStrings.adminSendButton),
            ),
          ],
        ),
      ),
    );
  }
}
