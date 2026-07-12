import 'package:flutter/material.dart';

class EvegahLogo extends StatelessWidget {
  final double height;
  
  const EvegahLogo({
    super.key,
    this.height = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/Evegah_login_page_logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
