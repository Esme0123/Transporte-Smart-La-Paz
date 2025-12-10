import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class RoutesRepository {
  // Aquí se hace la conexión. 'rutas' es el nombre de la colección en tu Firebase.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener todas las rutas
  Future<List<AppRoute>> getAllRoutes() async {
    try {
      // Petición REAL a la nube
      final QuerySnapshot snapshot = await _firestore.collection('rutas').get();
      
      // Convertimos los documentos de Firebase a objetos Dart (AppRoute)
      return snapshot.docs.map((doc) {
        return AppRoute.fromFirestore(doc.id as Map<String, dynamic>, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error Firebase: $e");
      return []; // Retorna lista vacía si falla para no romper la app
    }
  }
}