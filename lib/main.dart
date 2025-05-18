import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'screens/dashboard_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/amc_screen.dart';
import 'screens/db_inspector_screen.dart';
import 'services/database_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.database;
  
  runApp(const YasuiPosApp());
}

class YasuiPosApp extends StatelessWidget {
  const YasuiPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yasui POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 2;
  bool _sidebarExpanded = true;

  // Navigation items with icons and labels
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.dashboard_rounded,
      'label': 'Dashboard',
      'screen': DashboardScreen(),
    },
    {
      'icon': Icons.store_rounded,
      'label': 'Shop',
      'screen': ShopScreen(),
    },
    {
      'icon': Icons.inventory_rounded,
      'label': 'Inventory',
      'screen': InventoryScreen(),
    },
    {
      'icon': Icons.people_alt_rounded,
      'label': 'Customers',
      'screen': CustomersScreen(),
    },
    {
      'icon': Icons.event_repeat_rounded,
      'label': 'AMC',
      'screen': AMCScreen(),
    },
    {
      'icon': Icons.storage,
      'label': 'DB Inspector',
      'screen': DBInspectorScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    // Automatically collapse sidebar on small screens
    if (isSmallScreen && _sidebarExpanded) {
      _sidebarExpanded = false;
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            expanded: _sidebarExpanded,
            navItems: _navItems,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            onToggle: () {
              setState(() {
                _sidebarExpanded = !_sidebarExpanded;
              });
            },
            isSmallScreen: isSmallScreen,
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current page title
                      Text(
                        _navItems[_selectedIndex]['label'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // User info and actions
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                            tooltip: 'Notifications',
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {},
                            tooltip: 'Settings',
                          ),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF1A237E),
                            child: Text(
                              'JD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton(
                            child: const Row(
                              children: [
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'profile',
                                child: Text('Profile'),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Text('Logout'),
                              ),
                            ],
                            onSelected: (value) {
                              // Handle menu selection
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content area
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _navItems[_selectedIndex]['screen'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
