import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D1565).withAlpha(18),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper_rounded),
              label: 'Actualités',
            ),
            const NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event_rounded),
              label: 'Réunions',
            ),
            const NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business_rounded),
              label: 'Entreprises',
            ),
            const NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Membres',
            ),
            NavigationDestination(
              icon: auth.isLoggedIn
                  ? const Icon(Icons.person_outline_rounded)
                  : const Icon(Icons.lock_outline_rounded),
              selectedIcon: auth.isLoggedIn
                  ? const Icon(Icons.person_rounded)
                  : const Icon(Icons.lock_rounded),
              label: auth.isLoggedIn ? 'Mon espace' : 'Connexion',
            ),
          ],
        ),
      ),
    );
  }
}
