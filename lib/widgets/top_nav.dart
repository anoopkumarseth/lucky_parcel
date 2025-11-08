import 'package:flutter/material.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TopNav({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: const Text('ParcelApp'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
