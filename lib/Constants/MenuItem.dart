import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  final String img; // Image path
  final String title; // Title
  final bool line; // Whether to display the line
  final VoidCallback onTap; // Whether to display the line

  // Constructor accepting img, title, and line
  MenuItem(
      {required this.img,
      required this.title,
      this.line = true, // Default value for line is true
      required this.onTap});

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/${widget.img}", // Using img from parent
                  height: 20, // Adjust the height as needed
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title, // Using title from parent
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          widget.line // Show line if 'line' is true
              ? Container(
                  height: 2, // Height of the line
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey, // Start color
                        Colors.white, // End color
                      ],
                      begin: Alignment.centerLeft, // Gradient start
                      end: Alignment.centerRight, // Gradient end
                    ),
                  ),
                )
              : Container(), // Empty container when line is false
        ],
      ),
    );
  }
}
