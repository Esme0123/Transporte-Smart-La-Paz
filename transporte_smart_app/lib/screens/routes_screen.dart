import 'package:flutter/material.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, // Importante para el fondo
      body: Center(
        child: Text("Pantalla Cámara", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}