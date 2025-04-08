import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onScheduledTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onHistoryTap;
  final String activeScreen;
  final int unreadNotificationCount;

  const BottomNavBar({
    Key? key,
    this.onHomeTap = _defaultCallback,
    this.onScheduledTap = _defaultCallback,
    this.onNotificationTap = _defaultCallback,
    this.onHistoryTap = _defaultCallback,
    this.activeScreen = "home",
    this.unreadNotificationCount = 0,
  }) : super(key: key);

  static void _defaultCallback() {}

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.transparent,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffA558E0), Color(0xff5A307A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: "Home",
                    iconColor:
                        (activeScreen == "home") ? Colors.amber : Colors.white,
                    onTap: onHomeTap,
                  ),
                  const SizedBox(width: 10),
                  _buildNavItem(
                    icon: Icons.schedule,
                    label: "Scheduled Tasks",
                    iconColor: (activeScreen == "scheduled")
                        ? Colors.amber
                        : Colors.white,
                    onTap: onScheduledTap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildNotificationNavItem(
                    icon: Icons.notifications,
                    label: "Notifications",
                    iconColor: (activeScreen == "notifications")
                        ? Colors.amber
                        : Colors.white,
                    onTap: onNotificationTap,
                    count: unreadNotificationCount,
                  ),
                  const SizedBox(width: 10),
                  _buildNavItem(
                    icon: Icons.history,
                    label: "History",
                    iconColor: (activeScreen == "history")
                        ? Colors.amber
                        : Colors.white,
                    onTap: onHistoryTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 30),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNotificationNavItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    required int count,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 30),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
