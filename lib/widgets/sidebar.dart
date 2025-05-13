import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final bool expanded;
  final List<Map<String, dynamic>> navItems;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggle;
  final bool isSmallScreen;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.expanded,
    required this.navItems,
    required this.onItemSelected,
    required this.onToggle,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? 240 : 80,
      color: const Color(0xFF1A237E),
      child: Column(
        children: [
          // Logo/App name
          Container(
            height: 80,
            alignment: Alignment.center,
            child: expanded
                ? const Text(
                    'YASUI POS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )
                : const Icon(
                    Icons.point_of_sale,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    title: expanded
                        ? Text(
                            item['label'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          )
                        : null,
                    minLeadingWidth: 0,
                    onTap: () => onItemSelected(index),
                  ),
                );
              },
            ),
          ),
          // Toggle sidebar expansion
          Container(
            margin: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                if (!isSmallScreen || !expanded) {
                  onToggle();
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
