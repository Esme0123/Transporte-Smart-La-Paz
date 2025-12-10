import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class RoutesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener todas las rutas
  Future<List<AppRoute>> getAllRoutes() async {
    try {
      // Petición REAL a la base de datos
      final QuerySnapshot snapshot = await _firestore.collection('rutas').get();
      
      return snapshot.docs.map((doc) {
        // Convertimos cada documento de Firebase a nuestro Modelo
        return AppRoute.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception("Error al conectar con la BD: $e");
    }
  }
}