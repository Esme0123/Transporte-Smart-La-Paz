import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

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