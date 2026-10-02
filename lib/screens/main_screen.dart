import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../widgets/common_widgets.dart';
import 'companies/companies_screen.dart';
import 'meetings/meetings_screen.dart';
import 'news/news_screen.dart';
import 'private/private_home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _contentController;

  List<Widget> get _screens => [
    NewsScreen(
      onOpenAgenda: () => _selectDestination(1),
      onOpenDirectory: () => _selectDestination(2),
    ),
    const MeetingsScreen(),
    const CompaniesScreen(),
    const PrivateHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.handlePendingNavigation();
    _contentController = AnimationController(
      vsync: this,
      duration: AppTheme.motion,
      value: 1,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _selectDestination(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _contentController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final keyboardIsOpen = MediaQuery.viewInsetsOf(context).bottom > 24;
    final curved = CurvedAnimation(
      parent: _contentController,
      curve: AppTheme.motionCurve,
    );

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: CecBackground(
        child: FadeTransition(
          opacity: reduceMotion
              ? const AlwaysStoppedAnimation(1)
              : Tween<double>(begin: 0.82, end: 1).animate(curved),
          child: ScaleTransition(
            scale: reduceMotion
                ? const AlwaysStoppedAnimation(1)
                : Tween<double>(begin: 0.992, end: 1).animate(curved),
            alignment: Alignment.center,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : AppTheme.motionFast,
        switchInCurve: AppTheme.motionCurve,
        switchOutCurve: Curves.easeInCubic,
        child: keyboardIsOpen
            ? const SizedBox.shrink(key: ValueKey('keyboard-navigation-hidden'))
            : SafeArea(
                key: const ValueKey('floating-navigation'),
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: _FloatingGlassNavigation(
                  selectedIndex: _currentIndex,
                  isLoggedIn: isLoggedIn,
                  onSelected: _selectDestination,
                ),
              ),
      ),
    );
  }
}

class _FloatingGlassNavigation extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final ValueChanged<int> onSelected;

  const _FloatingGlassNavigation({
    required this.selectedIndex,
    required this.isLoggedIn,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = <_DestinationData>[
      const _DestinationData(
        label: 'Le Club',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      const _DestinationData(
        label: 'Agenda',
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
      ),
      const _DestinationData(
        label: 'Annuaire',
        icon: Icons.apartment_outlined,
        selectedIcon: Icons.apartment_rounded,
      ),
      _DestinationData(
        label: isLoggedIn ? 'Mon espace' : 'Connexion',
        icon: isLoggedIn
            ? Icons.person_outline_rounded
            : Icons.lock_outline_rounded,
        selectedIcon: isLoggedIn ? Icons.person_rounded : Icons.lock_rounded,
      ),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CecGlassPanel(
          key: const Key('main-navigation-panel'),
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          color: Colors.white.withAlpha(212),
          borderRadius: BorderRadius.circular(AppTheme.navigationRadius),
          blur: 22,
          boxShadow: AppTheme.navShadow,
          border: Border.all(color: Colors.white.withAlpha(210), width: 1),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _NavigationItem(
                      data: destinations[index],
                      selected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final _DestinationData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : AppTheme.motion;

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: duration,
              curve: AppTheme.motionCurve,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppTheme.primaryColor : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.08 : 1,
                    duration: duration,
                    curve: AppTheme.motionCurve,
                    child: Icon(
                      selected ? data.selectedIcon : data.icon,
                      size: 21,
                      color: selected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 10,
                      height: 1.15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _DestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
