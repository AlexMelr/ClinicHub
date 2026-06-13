import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page.dart';
import 'screens/herbs_page.dart';
import 'screens/patients_page.dart';
import 'screens/visits_page.dart';
import 'screens/prescriptions_page.dart';
import 'screens/stock_page.dart';

void main() => runApp(const ClinicHubApp());

class ClinicHubApp extends StatelessWidget {
  const ClinicHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF236A57);
    return MaterialApp(
      title: 'ClinicHub 中医诊所',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          surface: const Color(0xFFF7FAF6),
          surfaceContainerLowest: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF6),
        visualDensity: VisualDensity.standard,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(color: Color(0xFF14231F), fontSize: 20, fontWeight: FontWeight.w800),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E8E3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: seed, width: 1.4)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: seed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: seed),
          selectedLabelTextStyle: TextStyle(color: seed, fontWeight: FontWeight.w800),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFF65746E)),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _destinations = const [
    _ShellDestination(Icons.home_outlined, Icons.home, '首页'),
    _ShellDestination(Icons.spa_outlined, Icons.spa, '药材'),
    _ShellDestination(Icons.people_outline, Icons.people, '患者'),
    _ShellDestination(Icons.event_note_outlined, Icons.event_note, '就诊'),
    _ShellDestination(Icons.receipt_long_outlined, Icons.receipt_long, '处方'),
    _ShellDestination(Icons.inventory_2_outlined, Icons.inventory_2, '库存'),
  ];
  final _shortcutKeys = const [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
  ];
  final _pages = const [
    HomePage(),
    HerbsPage(),
    PatientsPage(),
    VisitsPage(),
    PrescriptionsPage(),
    StockPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        for (var i = 0; i < _destinations.length; i++) ...{
          SingleActivator(_shortcutKeys[i], control: true): _SelectPageIntent(i),
          SingleActivator(_shortcutKeys[i], meta: true): _SelectPageIntent(i),
        },
      },
      child: Actions(
        actions: {
          _SelectPageIntent: CallbackAction<_SelectPageIntent>(
            onInvoke: (intent) {
              setState(() => _index = intent.index);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              if (!wide) {
                return Scaffold(
                  body: _pages[_index],
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: [
                      for (final item in _destinations)
                        NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label),
                    ],
                  ),
                );
              }

              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      extended: constraints.maxWidth >= 1180,
                      minExtendedWidth: 168,
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      labelType: constraints.maxWidth >= 1180 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                      leading: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 18, 0, 24),
                        child: _BrandMark(),
                      ),
                      destinations: [
                        for (var i = 0; i < _destinations.length; i++)
                          NavigationRailDestination(
                            icon: Icon(_destinations[i].icon),
                            selectedIcon: Icon(_destinations[i].selectedIcon),
                            label: Text('${_destinations[i].label}  ${i + 1}'),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _pages[_index]),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectPageIntent extends Intent {
  final int index;

  const _SelectPageIntent(this.index);
}

class _ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ShellDestination(this.icon, this.selectedIcon, this.label);
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ClinicHub',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.local_hospital, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
