import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Custom style hook to control icon sizes
class _BottomNavStyle extends StyleHook {
  @override
  double get activeIconSize => 40.0; // Keep active and inactive sizes the same for a consistent look

  @override
  double get iconSize => 40.0; // Set the default (inactive) icon size to be larger

  @override
  double get activeIconMargin => 10.0;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    // This is required to be implemented, but we can make it invisible.
    return TextStyle(fontSize: 0, color: color);
  }
}

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNav({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // List of icons
    final List<String> icons = [
      'assets/icons/home.svg',
      'assets/icons/orders.svg',
      'assets/icons/lucky_draw.svg',
      'assets/icons/wallet.svg',
      'assets/icons/user-lg.svg',
    ];

    return StyleProvider(
      style: _BottomNavStyle(),
      child: ConvexAppBar(
        backgroundColor: Colors.white,
        style: TabStyle.fixedCircle,
        height: 70,
        initialActiveIndex: selectedIndex,
        onTap: onItemTapped,
        color: Colors.grey,
        activeColor: primaryColor,
        items: [
          TabItem(
            icon: SvgPicture.asset(icons[0],
                colorFilter: ColorFilter.mode(
                    selectedIndex == 0 ? primaryColor : Colors.grey,
                    BlendMode.srcIn)),
          ),
          TabItem(
            icon: SvgPicture.asset(icons[1],
                colorFilter: ColorFilter.mode(
                    selectedIndex == 1 ? primaryColor : Colors.grey,
                    BlendMode.srcIn)),
          ),
          TabItem(
            icon: SvgPicture.asset(icons[2],
                colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn)),
          ),
          TabItem(
            icon: SvgPicture.asset(icons[3],
                colorFilter: ColorFilter.mode(
                    selectedIndex == 3 ? primaryColor : Colors.grey,
                    BlendMode.srcIn)),
          ),
          TabItem(
            icon: SvgPicture.asset(icons[4],
                colorFilter: ColorFilter.mode(
                    selectedIndex == 4 ? primaryColor : Colors.grey,
                    BlendMode.srcIn)),
          ),
        ],
      ),
    );
  }
}
