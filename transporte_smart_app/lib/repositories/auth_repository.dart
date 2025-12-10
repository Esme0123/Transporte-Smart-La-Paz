import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual (o null si no hay sesión)
  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios de sesión (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar Sesión
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception(e.toString()); // Manejo de errores simple
    }
  }

  // Registrarse
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Cerrar Sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}