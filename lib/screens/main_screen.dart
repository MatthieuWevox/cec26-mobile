import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
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

  static const _iconList = <IconData>[
    Icons.newspaper_rounded,
    Icons.event_rounded,
    Icons.business_rounded,
    Icons.person_rounded,
  ];

  static const _labels = <String>[
    'Actualités',
    'Réunions',
    'Entreprises',
    'Mon espace',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Dynamically update the last icon & label based on auth state
    final icons = List<IconData>.from(_iconList);
    final labels = List<String>.from(_labels);
    if (!auth.isLoggedIn) {
      icons[3] = Icons.lock_rounded;
      labels[3] = 'Connexion';
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: icons.length,
        leftCornerRadius: 10,
        rightCornerRadius: 10,
        tabBuilder: (int index, bool isActive) {
          final color =
              isActive ? AppTheme.accentColor : Colors.white;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[index], size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                labels[index],
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        },
        activeIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        gapLocation: GapLocation.none,
        backgroundColor: AppTheme.primaryColor,
        shadow: const BoxShadow(
          offset: Offset(0, -1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.black12,
        ),
        height: 64,
      ),
    );
  }
}
