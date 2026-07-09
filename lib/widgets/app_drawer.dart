import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onLogout;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accentColor = isDark ? const Color(0xFF8FB8E8) : const Color(0xFF0B1F3A);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF163A5F) : const Color(0xFF0B1F3A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'SpendWise',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your money',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.white70),
                ),
              ],
            ),
          ),
          _buildDestination(context, 0, 'Home Screen', Icons.home, accentColor),
          _buildDestination(context, 1, 'Add Expense', Icons.add, accentColor),
          _buildDestination(context, 2, 'Calendar', Icons.calendar_month, accentColor),
          _buildDestination(context, 3, 'Analytics', Icons.analytics, accentColor),
          _buildDestination(context, 4, 'Budget', Icons.account_balance_wallet, accentColor),
          _buildDestination(context, 5, 'Profile', Icons.person_outline, accentColor),
          const Divider(),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode, color: accentColor),
            title: const Text('Dark Mode'),
            value: isDark,
            activeColor: const Color(0xFF8FB8E8),
            activeTrackColor: const Color(0xFF163A5F),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: accentColor),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              if (onLogout != null) {
                onLogout!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(BuildContext context, int index, String title, IconData icon, Color accentColor) {
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? accentColor : null),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: accentColor.withOpacity(0.16),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          onDestinationSelected(index);
        }
      },
    );
  }

}
