import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const GradientBackground({
    super.key,
    required this.child,
    this.showBlobs = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 3.0,
              colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            ),
          ),
        ),
        if (showBlobs) ...[
          Positioned(top: -10, right: -20, child: SvgPicture.asset('assets/images/blobs/login/top-right.svg')),
          Positioned(top: 0, left: 0, child: SvgPicture.asset('assets/images/blobs/login/top-left.svg')),
          Positioned(bottom: 0, left: 0, child: SvgPicture.asset('assets/images/blobs/login/bottom-left.svg')),
          Positioned(bottom: 0, right: 0, child: SvgPicture.asset('assets/images/blobs/login/bottom-right.svg')),
          Positioned(top: MediaQuery.of(context).size.height * 0.41, left: 0, child: SvgPicture.asset('assets/images/blobs/login/center-left.svg')),
        ],
        child,
      ],
    );
  }
}
