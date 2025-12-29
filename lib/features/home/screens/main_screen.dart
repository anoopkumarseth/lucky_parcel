import 'package:flutter/material.dart';
import 'package:lucky_parcel/common/widgets/side_bar.dart';
import 'package:lucky_parcel/common/widgets/top_nav.dart';
import 'package:lucky_parcel/features/home/screens/welcome_screen.dart';
import 'package:lucky_parcel/features/home/widgets/bottom_nav_option_2.dart';
import 'package:lucky_parcel/features/orders/screens/orders_screen.dart';
import 'package:lucky_parcel/features/profile/screens/profile_screen.dart';
import 'package:lucky_parcel/features/rewards/screens/points_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lucky Draw screen is not yet available.')),
      );
    }
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMenuItemTapped(int index) {
    Navigator.pop(context); // Close the drawer
    _onItemTapped(index);
  }

  static const List<Widget> _widgetOptions = <Widget>[
    WelcomeScreen(),
    OrdersScreen(),
    Center(child: Text('Lucky Draw Screen - Coming Soon')),
    PointsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: TopNav(scaffoldKey: _scaffoldKey),
      drawer: SideBar(onMenuItemTapped: _onMenuItemTapped),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavOption2(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}
