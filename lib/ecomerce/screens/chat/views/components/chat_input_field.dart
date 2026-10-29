import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../constants.dart';
import '../../controllers/chat_controller.dart';

class ChatInputField extends StatefulWidget {
  final ChatController controller;

  const ChatInputField({super.key, required this.controller});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasNow = widget.controller.textController.text.trim().isNotEmpty;
    if (hasNow != _hasText) {
      setState(() {
        _hasText = hasNow;
      });
    }
  }

  void _openAttachmentPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E28) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Share attachment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : blackColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOption(
                      icon: Icons.camera_alt_rounded,
                      color: const Color(0xFF00C853),
                      label: "Camera",
                      onTap: () {
                        Navigator.pop(ctx);
                        widget.controller.pickAndSendImage(ImageSource.camera);
                      },
                    ),
                    _buildOption(
                      icon: Icons.photo_library_rounded,
                      color: const Color(0xFF2979FF),
                      label: "Gallery",
                      onTap: () {
                        Navigator.pop(ctx);
                        widget.controller.pickAndSendImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgInput = isDark ? const Color(0xFF232330) : const Color(0xFFF3F4F8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191924) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment Button
            IconButton(
              onPressed: () => _openAttachmentPicker(context),
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: isDark ? Colors.white70 : primaryColor,
                size: 26,
              ),
              tooltip: "Attach photo",
            ),

            // Text Input Field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: widget.controller.textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isDark ? Colors.white : blackColor,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : blackColor40,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) {
                    if (_hasText) {
                      widget.controller.sendMessage();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send Button
            Material(
              color: _hasText ? primaryColor : (isDark ? Colors.white12 : Colors.black12),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _hasText
                    ? () {
                        widget.controller.sendMessage();
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: _hasText ? Colors.white : (isDark ? Colors.white30 : blackColor40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
