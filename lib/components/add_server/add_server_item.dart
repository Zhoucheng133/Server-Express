import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddServerItem extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enableCorrect;
  final bool obscureText;
  final bool numberOnly;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;

  const AddServerItem({
    super.key, 
    required this.label, 
    required this.controller, 
    this.enableCorrect=true, 
    this.obscureText=false, 
    this.numberOnly=false, 
    this.hint="",
    this.textInputAction,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
  });

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
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            hint: Text(
              widget.hint,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey
              ),
            ),
          ),
          style: TextStyle(
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