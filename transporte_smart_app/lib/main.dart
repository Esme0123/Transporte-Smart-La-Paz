import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte Smart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable para guardar nuestra base de datos (rutas) en memoria
  Map<String, dynamic>? _rutasDb;

  // --- PASO 1: Cargamos la base de datos al iniciar la app ---
  @override
  void initState() {
    super.initState();
    cargarBaseDeDatos();
  }

  // Esta función lee el archivo assets/rutas.json
  Future<void> cargarBaseDeDatos() async {
    try {
      // 1. Lee el contenido del archivo como un String
      final String data = await rootBundle.loadString('assets/rutas.json');
      
      // 2. Convierte el String (JSON) a un Mapa de Dart
      final Map<String, dynamic> jsonMapa = jsonDecode(data);
      
      setState(() {
        _rutasDb = jsonMapa;
      });
      print("¡Base de datos cargada! Contiene: ${_rutasDb!.keys.toList()}");

    } catch (e) {
      print("Error al cargar la base de datos: $e");
    }
  }

  // --- PASO 2: Función de prueba para mostrar una ruta ---
  void funcionDePrueba(String numero) {
    if (_rutasDb == null) {
      print("La base de datos no está cargada todavía.");
      return;
    }

    if (_rutasDb!.containsKey(numero)) {
      var ruta = _rutasDb![numero];
      print("--- RUTA ENCONTRADA: $numero ---");
      print("Nombre: ${ruta['nombre']}");
      
      // Obtenemos el objeto de paradas
      var paradasObj = ruta['paradas'];

      // Imprimimos la IDA
      print("\n  --- Paradas de IDA ---");
      (paradasObj['ida'] as List).forEach((parada) {
        print("  - $parada");
      });

      // Imprimimos la VUELTA
      print("\n  --- Paradas de VUELTA ---");
      (paradasObj['vuelta'] as List).forEach((parada) {
        print("  - $parada");
      });

    } else {
      print("--- RUTA $numero NO ENCONTRADA ---");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Base de Datos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Un botón para probar la ruta "273"
            ElevatedButton(
              onPressed: () {
                print("\n--- Botón 273 presionado ---");
                funcionDePrueba("273");
              },
              child: const Text('Probar Ruta "273"'),
            ),
            
            // Un botón para probar la ruta "212"
            ElevatedButton(
              onPressed: () {
                print("\n--- Botón 212 presionado ---");
                funcionDePrueba("212");
              },
              child: const Text('Probar Ruta "212"'),
            ),

            // Un botón para probar una ruta que no existe
            ElevatedButton(
              onPressed: () {
                print("\n--- Botón 999 presionado ---");
                funcionDePrueba("999");
              },
              child: const Text('Probar Ruta "999" (Error)'),
            ),
          ],
        ),
      ),
    );
  }
}