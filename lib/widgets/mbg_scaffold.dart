import 'package:flutter/material.dart';
import 'background_decoration.dart';

class MbgScaffold extends StatelessWidget {
  final Widget body;
  final bool showDecoration;
  final Color backgroundColor;
  
  // 1. Tambahkan variabel untuk floatingActionButton
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const MbgScaffold({
    super.key, 
    required this.body, 
    this.showDecoration = true,
    this.backgroundColor = Colors.white,
    // 2. Masukkan ke dalam constructor
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // 3. Teruskan parameter ke Scaffold asli
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          if (showDecoration) const BlueCircleDecoration(),
          SafeArea(child: body),
        ],
      ),
    );
  }
}