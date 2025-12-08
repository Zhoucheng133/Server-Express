import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingItem extends StatefulWidget {

  final String label;
  final Widget child;
  final bool enabled;

  const SettingItem({super.key, required this.label, required this.child, this.enabled=true});

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: GoogleFonts.notoSansSc(
                color: widget.enabled ? null : Colors.grey,
              ),
            )
          ),
          widget.child
        ],
      ),
    );
  }
}