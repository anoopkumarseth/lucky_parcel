import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucky_parcel/app/routes/app_router.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TopNav({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // We are providing a custom leading widget
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Center(
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset('assets/icons/navbar-icon.svg', width: 44, height: 44),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: SvgPicture.asset(
                'assets/images/LuckyParcel_logo.svg',
                width: 131,
                height: 28,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset('assets/icons/notification.svg', width: 36, height: 36),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.notifications);
          },
        ),
        const SizedBox(width: 16), // Add some padding to the right edge
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
