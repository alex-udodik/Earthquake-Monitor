// sidebar.dart
import 'package:flutter/material.dart';

class CollapsibleSidebar extends StatefulWidget {
  final bool isCollapsed;
  final Function(bool) onToggle;

  CollapsibleSidebar({
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  _CollapsibleSidebarState createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: widget.isCollapsed ? 80 : 250,
      color: Colors.blueGrey[900],
      child: Column(
        children: [
          SizedBox(height: 20),
          widget.isCollapsed
              ? IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => widget.onToggle(!widget.isCollapsed),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sidebar Header',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
          Divider(color: Colors.white54),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: widget.isCollapsed
                ? null
                : Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle navigation
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: widget.isCollapsed
                ? null
                : Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle navigation
            },
          ),
        ],
      ),
    );
  }
}
