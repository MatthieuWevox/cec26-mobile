import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'companies/companies_screen.dart';
import 'meetings/meetings_screen.dart';
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
    PrivateHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: const Border(top: BorderSide(color: AppTheme.dividerColor)),
          boxShadow: AppTheme.navShadow,
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper_rounded),
                label: 'Actualités',
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Réunions',
              ),
              const NavigationDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment_rounded),
                label: 'Annuaire',
              ),
              NavigationDestination(
                icon: Icon(
                  isLoggedIn
                      ? Icons.person_outline
                      : Icons.lock_outline_rounded,
                ),
                selectedIcon: Icon(
                  isLoggedIn ? Icons.person_rounded : Icons.lock_rounded,
                ),
                label: isLoggedIn ? 'Mon espace' : 'Connexion',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
