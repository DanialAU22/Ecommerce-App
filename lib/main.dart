import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/review_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..initialize(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (_) => ReviewProvider(),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (BuildContext context, ThemeProvider theme, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: theme.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<String> _titles = <String>[
    'Discover',
    'My Cart',
    'Favorites',
    'Account',
  ];

  final List<Widget> _screens = const <Widget>[
    HomeScreen(),
    CartScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      context.read<FavoriteProvider>().loadFavorites();
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Consumer2<CartProvider, FavoriteProvider>(
      builder: (
        BuildContext context,
        CartProvider cartProvider,
        FavoriteProvider favoriteProvider,
        Widget? child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() => _currentIndex = index);
              },
              destinations: <NavigationDestination>[
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Badge.count(
                    isLabelVisible: cartProvider.itemCount > 0,
                    count: cartProvider.itemCount,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge.count(
                    isLabelVisible: cartProvider.itemCount > 0,
                    count: cartProvider.itemCount,
                    child: const Icon(Icons.shopping_cart_rounded),
                  ),
                  label: 'Cart',
                ),
                NavigationDestination(
                  icon: Badge.count(
                    isLabelVisible: favoriteProvider.favorites.isNotEmpty,
                    count: favoriteProvider.favorites.length,
                    child: const Icon(Icons.favorite_border_rounded),
                  ),
                  selectedIcon: Badge.count(
                    isLabelVisible: favoriteProvider.favorites.isNotEmpty,
                    count: favoriteProvider.favorites.length,
                    child: const Icon(Icons.favorite_rounded),
                  ),
                  label: 'Favorites',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
