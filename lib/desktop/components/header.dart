import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_express/desktop/components/server_list_buttons.dart';

class TitleBar extends StatefulWidget {

  final String title;

  const TitleBar({super.key, required this.title});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: GoogleFonts.notoSansSc(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            Expanded(
              child: Container(),
            ),
            ServerListButtons()
          ],
        ),
        Divider(
          thickness: 2,
        )
      ],
    );
  }
}