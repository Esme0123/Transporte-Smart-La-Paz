import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transporte_smart_app/screens/login_screen.dart';

class ResultScreen extends StatefulWidget {
  final AppRoute route;
  final List<String> favoriteRoutes;
  final Function(String) onToggleFavorite;
  final Function(AppRoute, bool) onGoToMap;
  final VoidCallback onClose;

  const ResultScreen({
    super.key,
    required this.route,
    required this.favoriteRoutes,
    required this.onToggleFavorite,
    required this.onGoToMap,
    required this.onClose,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _selectedTab = 'ida';
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.speak("Ruta encontrada. Línea ${widget.route.lineNumber}");
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currentStops = widget.route.stops[_selectedTab] ?? [];
    final bool isFavorite = widget.favoriteRoutes.contains(widget.route.lineNumber);
    final bool isReturn = _selectedTab == 'vuelta';

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onGoToMap(widget.route, isReturn);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.map, color: Colors.black),
        label: const Text("VER EN MAPA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              expandedHeight: 80.0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                onPressed: widget.onClose,
              ),
              actions: [
                // --- BOTÓN DE FAVORITOS EN DETALLE ---
                IconButton(
                  icon: Icon(
                    isFavorite ? LucideIcons.star : LucideIcons.star,
                    fill: isFavorite ? 1.0 : 0.0,
                    color: isFavorite ? AppColors.star : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    // 1. Verificar Login
                    final user = FirebaseAuth.instance.currentUser;
                    
                    if (user == null) {
                      // 2. Alerta Invitado
                       showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text("Inicia Sesión", style: TextStyle(color: AppColors.textPrimary)),
                            content: const Text("Debes registrarte para guardar favoritos.", style: TextStyle(color: AppColors.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                },
                                child: const Text("Ir al Login", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                    } else {
                      // 3. Guardar (Aquí usamos la función que nos pasa el padre)
                      widget.onToggleFavorite(widget.route.lineNumber);
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                title: Text("Línea ${widget.route.lineNumber}", style: const TextStyle(color: AppColors.textPrimary)),
              ),
            ),

            // ... (Resto del código idéntico)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.route.routeName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text("Destino: ${widget.route.destination}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
                      ],
                    ),
                    const SizedBox(height: 24),
                     Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildTabButton("ida", "Ida"),
                          _buildTabButton("vuelta", "Vuelta"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
             if (currentStops.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("No hay información de paradas.", style: TextStyle(color: AppColors.textSecondary))),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stopName = currentStops[index];
                    final isFirst = index == 0;
                    final isLast = index == currentStops.length - 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Column(
                                children: [
                                  Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : AppColors.primary.withOpacity(0.3))),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(color: isFirst || isLast ? AppColors.secondary : AppColors.primary, width: 2),
                                    ),
                                  ),
                                  Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : AppColors.primary.withOpacity(0.3))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                                child: Text(stopName, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: currentStops.length,
                ),
              ),
             const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

   Widget _buildTabButton(String key, String label) {
    final bool isActive = _selectedTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}