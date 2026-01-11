import 'package:flutter/material.dart';

class BlueCircleDecoration extends StatelessWidget {
  const BlueCircleDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -70,
      right: -50,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          // Menggunakan warna accent biru sesuai tema MBG Anda
          color: const Color(0xFF5D9CEC).withAlpha(31),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}