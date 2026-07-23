import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSubmitted,
    required this.enabled,
    required this.isSending,
  });

  final Future<void> Function(String message) onSubmitted;
  final bool enabled;
  final bool isSending;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = widget.enabled && !widget.isSending;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        style: const TextStyle(
          fontFamily: 'Brix Sans',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFF182B49),
          height: 1.25,
        ),
        onSubmitted: canSend ? (_) => _submit() : null,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Talk with UC San Diego Assistant...',
          hintStyle: const TextStyle(
            fontFamily: 'Brix Sans',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8C8C8C),
            height: 1.25,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          filled: true,
          fillColor: Colors.white,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: canSend ? _submit : null,
              icon: Opacity(
                opacity: canSend ? 1 : 0.45,
                child: SvgPicture.asset(
                  'assets/images/tgpt/send-message.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
          border: _BORDER,
          enabledBorder: _BORDER,
          focusedBorder: _BORDER,
          disabledBorder: _BORDER,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final String message = _controller.text.trim();
    if (message.isEmpty) return;

    _controller.clear();
    await widget.onSubmitted(message);
  }

  static const OutlineInputBorder _BORDER = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: Color(0xFFB1B5BB),
      width: 1.25,
    ),
  );
}
