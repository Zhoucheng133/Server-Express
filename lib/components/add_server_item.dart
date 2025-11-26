import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddServerItem extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enableCorrect;
  final bool obscureText;
  final bool numberOnly;

  const AddServerItem({super.key, required this.label, required this.controller, this.enableCorrect=true, this.obscureText=false, this.numberOnly=false, this.hint=""});

  @override
  State<AddServerItem> createState() => _AddServerItemState();
}

class _AddServerItemState extends State<AddServerItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.label)
        ),
        const SizedBox(height: 5,),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            hint: Text(
              widget.hint,
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                color: Colors.grey
              ),
            ),
          ),
          style: GoogleFonts.notoSansSc(
            fontSize: 14
          ),
          autocorrect: widget.enableCorrect,
          enableSuggestions: widget.enableCorrect,
          obscureText: widget.obscureText,
          keyboardType: widget.numberOnly ? TextInputType.number : null,
          inputFormatters: widget.numberOnly ? [  
            FilteringTextInputFormatter.digitsOnly, 
          ] : null,  
        )
      ],
    );
  }
}