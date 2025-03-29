import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final bool hasCompletedTasks;
  final VoidCallback onTrashClick;

  BottomNavBar({required this.hasCompletedTasks, required this.onTrashClick});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.transparent,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffA558E0), Color(0xff5A307A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildNavItem(Icons.home, "Home", Colors.amber),
                  SizedBox(width: 30),
                  _buildNavItem(Icons.refresh, "Refresh", Colors.white),
                ],
              ),
            ),
            SizedBox(width: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildNavItem(
                      Icons.notifications, "Notifications", Colors.white),
                  SizedBox(width: 30),
                  _buildTrashIcon(), // Trash icon with disable logic
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashIcon() {
    return GestureDetector(
      onTap: hasCompletedTasks
          ? onTrashClick
          : null, // Only clickable if hasCompletedTasks is true
      child: Opacity(
        opacity: hasCompletedTasks ? 1.0 : 0.4, // Dim it when disabled
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 30),
            Text("Trash", style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 30),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
