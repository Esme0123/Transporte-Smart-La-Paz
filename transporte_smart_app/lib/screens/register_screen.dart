import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/repositories/auth_repository.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthRepository _authRepo = AuthRepository();
  bool _isLoading = false;

  void _registerReal() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _authRepo.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      // Si funciona, volvemos atrás 2 veces (al perfil) o hacemos login automático
      if (mounted) {
        Navigator.pop(context); // Cierra registro
        Navigator.pop(context, true); // Cierra login y avisa éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().split(']').last}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Crear Cuenta", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Regístrate para guardar tus rutas", style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 30),
            TextField(controller: _emailCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Correo", filled: true, fillColor: AppColors.surface, prefixIcon: Icon(LucideIcons.mail, color: AppColors.primary))),
            const SizedBox(height: 20),
            TextField(controller: _passCtrl, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Contraseña", filled: true, fillColor: AppColors.surface, prefixIcon: Icon(LucideIcons.lock, color: AppColors.primary))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerReal,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                child: _isLoading ? const CircularProgressIndicator() : const Text("REGISTRARME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}