import 'package:flutter/material.dart';

/// Model for SubMenu item
class SubMenuItem {
  final String name;
  final VoidCallback onTap;

  SubMenuItem({required this.name, required this.onTap});
}

/// MenuItem widget with optional submenu support
class MenuItem extends StatefulWidget {
  final String img;
  final String title;
  final bool line;
  final VoidCallback onTap;
  final List<SubMenuItem>? subMenus;

  MenuItem({
    required this.img,
    required this.title,
    this.line = true,
    required this.onTap,
    this.subMenus,
  });

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _showSubMenu = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            widget.onTap();
            if (widget.subMenus != null && widget.subMenus!.isNotEmpty) {
              setState(() {
                _showSubMenu = !_showSubMenu;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/${widget.img}",
                  height: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.subMenus != null && widget.subMenus!.isNotEmpty)
                  Icon(
                    _showSubMenu
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
              ],
            ),
          ),
        ),

        if (_showSubMenu && widget.subMenus != null)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.subMenus!
                  .map(
                    (submenu) => GestureDetector(
                  onTap: submenu.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                      submenu.name,
                      style: const TextStyle(fontSize: 14,color: Colors.black),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),

        if (widget.line)
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
      ],
    );
  }
}
