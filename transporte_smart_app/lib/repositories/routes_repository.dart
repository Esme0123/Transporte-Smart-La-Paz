import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class RoutesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppRoute>> getAllRoutes() async {
    try {
      print("Consultando Firebase...");
      final QuerySnapshot snapshot = await _firestore.collection('rutas').get();
      
      print("Documentos encontrados: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        // Aseguramos que data() sea tratado como Map<String, dynamic>
        // Si data() falla, pasamos un mapa vacío para que no crashee
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return AppRoute.fromFirestore(data);
      }).toList();
      
    } catch (e) {
      print("ERROR CRÍTICO EN REPOSITORIO: $e");
      // Retornamos lista vacía en vez de lanzar error para que la UI no se ponga roja
      return []; 
    }
  }
}