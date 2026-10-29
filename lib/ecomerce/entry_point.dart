import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/ecomerce/screens/checkout/views/cart_screen.dart';
import 'package:vlr/ecomerce/screens/home/views/home_screen.dart';
import 'package:vlr/ecomerce/screens/instant_delivery/Presention/screen/instant_product_.dart';
import 'package:vlr/ecomerce/screens/profile/views/profile_screen.dart';
import 'package:vlr/ecomerce/route/router.dart' as router;

import 'components/mini_cart_bar.dart';
import 'constants.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_navigatorKey.currentState?.canPop() ?? false) {
          _navigatorKey.currentState!.pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/' || settings.name == null) {
            return MaterialPageRoute(
              builder: (_) => const _EntryPointHome(),
              settings: settings,
            );
          }
          return router.generateRoute(settings);
        },
      ),
    );
  }
}

class _EntryPointHome extends StatefulWidget {
  const _EntryPointHome();

  @override
  State<_EntryPointHome> createState() => _EntryPointHomeState();
}

class _EntryPointHomeState extends State<_EntryPointHome> {
  final List _pages = const [
    HomeScreen(),
    InstantProduct(),
    CartScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                (Theme.of(context).brightness == Brightness.dark
                    ? whileColor40
                    : blackColor40),
            BlendMode.srcIn),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageTransitionSwitcher(
              duration: defaultDuration,
              transitionBuilder: (child, animation, secondAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondAnimation,
                  child: child,
                );
              },
              child: _pages[_currentIndex],
            ),
          ),
          // Show mini cart bar only on Home tab (not Instant Delivery/Cart/Profile)
          if (_currentIndex == 0) const MiniCartBar(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index != _currentIndex) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xFF101015),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedFontSize: 12,
              selectedItemColor: primaryColor,
              unselectedItemColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? whileColor40
                      : blackColor40,
              items: [
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Shop.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Shop.svg", color: primaryColor),
                  label: "Shop",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Delivery.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Delivery.svg", color: primaryColor),
                  label: "Instant Delivery",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Bag.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Bag.svg", color: primaryColor),
                  label: "Cart",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Profile.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Profile.svg", color: primaryColor),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
