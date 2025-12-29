import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

// Custom style hook to control icon sizes
class _BottomNavStyle extends StyleHook {
  @override
  double get activeIconSize => 40.0;

  @override
  double get iconSize => 40.0;

  @override
  double get activeIconMargin => 5.0;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 0, color: color);
  }
}

class BottomNavOption2 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavOption2({super.key, required this.selectedIndex, required this.onItemTapped});

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
        color: Colors.white, // Set default color to white to avoid blue overlay on inactive Lucky Draw
        activeColor: Colors.white, // Set active color (circle background) to white to "remove" the wrapper
        items: icons.asMap().entries.map((entry) {
          int idx = entry.key;
          String path = entry.value;
          return TabItem(
            icon: _AnimatedIcon(
              iconPath: path,
              isSelected: selectedIndex == idx,
              color: primaryColor,
              size: idx == 2 ? 80.0 : 40.0, // Lucky Draw (index 2) gets size 70, others 40
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  final String iconPath;
  final bool isSelected;
  final Color color;
  final double size;

  const _AnimatedIcon({
    super.key,
    required this.iconPath,
    required this.isSelected,
    required this.color,
    this.size = 40.0,
  });

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.15), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value,
            child: Transform.scale(
              scale: widget.isSelected ? 1.01 : 1.0,
              child: child,
            ),
          );
        },
        child: widget.isSelected
            ? Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Shadow
                  Transform.translate(
                    offset: const Offset(0, 3),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: SvgPicture.asset(
                        widget.iconPath,
                        width: widget.size,
                        height: widget.size,
                        colorFilter: ColorFilter.mode(
                          widget.color.withOpacity(0.3),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  // Icon
                  SvgPicture.asset(
                    widget.iconPath,
                    width: widget.size,
                    height: widget.size,
                    colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
                  ),
                ],
              )
            : Center(
                child: SvgPicture.asset(
                  widget.iconPath,
                  width: widget.size,
                  height: widget.size,
                  colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
                ),
              ),
      ),
    );
  }
}
