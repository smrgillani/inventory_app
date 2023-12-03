import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onClicked,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(29, 194, 95, 1),
      minimumSize: const Size.fromHeight(50),
    ),
    onPressed: onClicked,
    child: buildContent(),
  );

  Widget buildContent() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 16),
      Text(
        text,
        style: TextStyle(fontSize: 22, color: color),
      ),
    ],
  );
}