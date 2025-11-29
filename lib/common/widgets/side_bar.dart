import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_parcel/app/routes/app_router.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Anonymous'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Text(user?.email?[0].toUpperCase() ?? 'A'),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('My Orders'),
            onTap: () => Navigator.pushNamed(context, AppRouter.orders),
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('My Points'),
            onTap: () => Navigator.pushNamed(context, AppRouter.points),
          ),
          if (user != null && user.email == 'test@gmail.com')
            ListTile(
              leading: const Icon(Icons.drive_eta_outlined),
              title: const Text('Drivers'),
              onTap: () {
                // This will be handled by the router in the future
                // For now, we will navigate to the drivers screen
                // a different way.
                 Navigator.pushNamed(context, '/drivers');
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // The AuthWrapper will handle navigation
            },
          ),
        ],
      ),
    );
  }
}
