import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class DropdownButtonMenu extends StatefulWidget {
  const DropdownButtonMenu({
    super.key,
    required this.title,
    required this.list,
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final String title;
  final List<String> list;
  final String? value;
  final bool showError;
  final Function(String?) onChanged;

  @override
  State<DropdownButtonMenu> createState() => _DropdownButtonMenuState();
}

class _DropdownButtonMenuState extends State<DropdownButtonMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.showError ? Colors.red : Colors.grey,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownMenu<String>(
            initialSelection: widget.value,
            requestFocusOnTap: true,
            enableSearch: true,
            enableFilter: true,
            label: Text(widget.title),
            textStyle: TextStyle(fontSize: 22),
            onSelected: widget.onChanged,
            dropdownMenuEntries: widget.list.map((e) {
              return DropdownMenuEntry(
                value: e,
                label: e,
                style: MenuItemButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              '${widget.title} が入力されていません。',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }
}

class NavigateButton extends StatefulWidget{
  const NavigateButton({super.key, required this.title, required this.next ,required this.buttonColor, required this.textColor});
  final String title;
  final Widget next;
  final Color buttonColor;
  final Color textColor;

  @override
  State<NavigateButton> createState() => _NavigateButtonState();
}
class _NavigateButtonState extends State<NavigateButton> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:ElevatedButton(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(widget.buttonColor as Color?)),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => widget.next),
            );

          },
          child: FittedBox(child: Text( widget.title,style: TextStyle(color: widget.textColor as Color?, fontSize:30 ),))
      ),
    );
  }
}