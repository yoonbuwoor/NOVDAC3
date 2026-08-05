import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';
import 'drobot_home_screen.dart';
import 'drone_catalog_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';
import 'simulator_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  void _openAcademy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearnScreen(
          isDark: widget.isDark,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  void _openMissions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionsScreen(
          isDark: widget.isDark,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final pages = <Widget>[
      HomeScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onOpenAcademy: () => _openAcademy(context),
        onOpenLab: () => _goTo(2),
        onOpenMissions: () => _openMissions(context),
        onOpenDrobot: () => _goTo(1),
        onOpenDrones: () => _goTo(3),
      ),
      DrobotHomeScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      SimulatorScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      DroneCatalogScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      ProfileScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
    ];

    const destinations = <_Destination>[
      _Destination('Accueil', Icons.home_outlined, Icons.home_rounded),
      _Destination('Drobot', Icons.smart_toy_outlined, Icons.smart_toy_rounded),
      _Destination('Simulateur', Icons.route_outlined, Icons.route_rounded),
      _Destination('Drones', Icons.flight_outlined, Icons.flight_rounded),
      _Destination('Profil', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        return Scaffold(
          extendBody: true,
          body: SafeArea(
            bottom: wide,
            child: Row(
              children: [
                if (wide)
                  _Sidebar(
                    selectedIndex: _index,
                    destinations: destinations,
                    learnerName: controller.learnerName,
                    xp: controller.xp,
                    onSelected: _goTo,
                  ),
                Expanded(child: IndexedStack(index: _index, children: pages)),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : _BottomBar(
                  selectedIndex: _index,
                  destinations: destinations,
                  onSelected: _goTo,
                ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.learnerName,
    required this.xp,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_Destination> destinations;
  final String learnerName;
  final int xp;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 240,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xF20A1018) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(.08) : const Color(0xFFE0E9EE),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 92,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: orange.withOpacity(.22)),
            ),
            child: Image.asset('assets/images/logo_full.webp', fit: BoxFit.contain),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < destinations.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _SideItem(
                destination: destinations[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orange.withOpacity(.15), violet.withOpacity(.08)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: orange.withOpacity(.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: orange),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        learnerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '$xp XP • Novateur221',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? orange.withOpacity(.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Row(
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: selected ? orange : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                destination.label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: destinations
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
