// import 'package:flutter/material.dart';

// class BottomNavBar extends StatelessWidget {
//   final VoidCallback onHomeTap;
//   final VoidCallback onRefreshTap;
//   final VoidCallback onNotificationTap;
//   final VoidCallback onHistoryTap;

//   const BottomNavBar({
//     Key? key,
//     this.onHomeTap = _defaultCallback,
//     this.onRefreshTap = _defaultCallback,
//     this.onNotificationTap = _defaultCallback,
//     this.onHistoryTap = _defaultCallback,
//   }) : super(key: key);

//   static void _defaultCallback() {}

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       shape: const CircularNotchedRectangle(),
//       notchMargin: 8.0,
//       color: Colors.transparent,
//       child: Container(
//         height: 60,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xffA558E0), Color(0xff5A307A)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Left side icons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Row(
//                 children: [
//                   _buildNavItem(Icons.home, "Home", Colors.amber, onHomeTap),
//                   const SizedBox(width: 30),
//                   _buildNavItem(
//                       Icons.refresh, "Refresh", Colors.white, onRefreshTap),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 50),
//             // Right side icons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Row(
//                 children: [
//                   _buildNavItem(Icons.notifications, "Notifications",
//                       Colors.white, onNotificationTap),
//                   const SizedBox(width: 30),
//                   _buildNavItem(
//                       Icons.delete, "History", Colors.white, onHistoryTap),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(
//       IconData icon, String label, Color iconColor, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: iconColor, size: 30),
//           Text(label,
//               style: const TextStyle(color: Colors.white, fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onHistoryTap;

  // We'll add a parameter to indicate which screen is active
  final String activeScreen;
  // possible values: "home", "history", "notifications", etc.

  const BottomNavBar({
    Key? key,
    this.onHomeTap = _defaultCallback,
    this.onRefreshTap = _defaultCallback,
    this.onNotificationTap = _defaultCallback,
    this.onHistoryTap = _defaultCallback,
    this.activeScreen = "home", // default to home
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: "Home",
                    // If activeScreen == "home", highlight with amber, else white
                    iconColor:
                        (activeScreen == "home") ? Colors.amber : Colors.white,
                    onTap: onHomeTap,
                  ),
                  const SizedBox(width: 30),
                  _buildNavItem(
                    icon: Icons.refresh,
                    label: "Refresh",
                    iconColor: (activeScreen == "refresh")
                        ? Colors.amber
                        : Colors.white,
                    onTap: onRefreshTap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 50),
            // Right side icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Icons.notifications,
                    label: "Notifications",
                    iconColor: (activeScreen == "notifications")
                        ? Colors.amber
                        : Colors.white,
                    onTap: onNotificationTap,
                  ),
                  const SizedBox(width: 30),
                  _buildNavItem(
                    icon: Icons.delete,
                    label: "History",
                    // highlight if activeScreen == "history"
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
}
