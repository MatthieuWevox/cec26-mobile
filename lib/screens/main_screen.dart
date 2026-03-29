import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'companies/companies_screen.dart';
import 'meetings/meetings_screen.dart';
import 'members/members_screen.dart';
import 'news/news_screen.dart';
import 'private/private_home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    NewsScreen(),
    MeetingsScreen(),
    CompaniesScreen(),
    MembersScreen(),
    PrivateHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper_rounded),
            label: 'Actualités',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event_rounded),
            label: 'Réunions',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business_rounded),
            label: 'Entreprises',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Membres',
          ),
          BottomNavigationBarItem(
            icon: auth.isLoggedIn
                ? const Icon(Icons.person_outline_rounded)
                : const Icon(Icons.lock_outline_rounded),
            activeIcon: auth.isLoggedIn
                ? const Icon(Icons.person_rounded)
                : const Icon(Icons.lock_rounded),
            label: auth.isLoggedIn ? 'Mon espace' : 'Connexion',
          ),
        ],
      ),
    );
  }
}
