import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, 
      body: Center(
        child: Text("Pantalla Cámara", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}