import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({super.key}); // ✅ Used super.key

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/logo.svg', // 🔹 Your circular logo (NO rotation)
        width: 100,
        height: 100,
      ),
    );
  }
}
