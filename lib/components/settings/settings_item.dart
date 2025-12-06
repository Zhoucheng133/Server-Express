import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget {

  final String label;
  final Widget child;

  const SettingsItem({super.key, required this.label, required this.child});

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}