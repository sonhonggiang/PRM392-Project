import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'tabs/home_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/favorite_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    ExploreTab(),
    FavoriteTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _currentIndex == 0 ? AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào 👋', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
            Text(user.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.indigo)),
          ],
        ),
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Text('🔔', style: TextStyle(fontSize: 20)),
              onPressed: () {},
            ),
          const SizedBox(width: 8),
        ],
      ) : AppBar(
        title: Text(
          _currentIndex == 1 ? 'Khám phá' : _currentIndex == 2 ? 'Yêu thích' : 'Hồ sơ cá nhân',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo),
        ),
      ),
      body: _tabs[_currentIndex],
      floatingActionButton: user.role == UserRole.creator || user.role == UserRole.admin 
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: AppTheme.teal,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tạo mẫu mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ) 
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.white,
        indicatorColor: AppTheme.indigoLight.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
          NavigationDestination(icon: Text('📚', style: TextStyle(fontSize: 20)), label: 'Khám phá'),
          NavigationDestination(icon: Text('⭐', style: TextStyle(fontSize: 20)), label: 'Yêu thích'),
          NavigationDestination(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Hồ sơ'),
        ],
      ),
    );
  }

}
