import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  String _selectedTab = 'ida'; // 'ida' o 'vuelta'
  final FlutterTts flutterTts = FlutterTts(); // Instancia de voz

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Configurar y hablar
  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES"); // Español
    await flutterTts.setPitch(1.0);
    // Leemos la ruta
    _speak();
  }

  Future<void> _speak() async {
    String text = "Ruta encontrada. Línea ${widget.route.lineNumber}, con destino a ${widget.route.destination}";
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // 1. Obtener paradas de forma segura
    final List<String> currentStops = widget.route.stops[_selectedTab] ?? [];
    final bool isFavorite = widget.favoriteRoutes.contains(widget.route.lineNumber);
    final bool isReturn = _selectedTab == 'vuelta';

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Llamamos a la función del padre pasándole si es vuelta o no
          widget.onGoToMap(widget.route, isReturn);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.map, color: Colors.black),
        label: const Text("VER EN MAPA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- 1. Header (Nombre y Destino) ---
            SliverAppBar(
              backgroundColor: AppColors.surface,
              expandedHeight: 80.0, // Altura fija segura
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                onPressed: widget.onClose,
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.volume2, color: AppColors.primary),
                  onPressed: _speak,
                ),
                 IconButton(
                  icon: Icon(
                    isFavorite ? LucideIcons.star : LucideIcons.star,
                    color: isFavorite ? AppColors.star : AppColors.textSecondary,
                  ),
                  onPressed: () => widget.onToggleFavorite(widget.route.lineNumber),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                title: Text(
                  "Línea ${widget.route.lineNumber}",
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            // --- 2. Información Extra ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.route.routeName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Destino: ${widget.route.destination}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- TABS (IDA / VUELTA) ---
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildTabButton("ida", "Ida (Inicio → Fin)"),
                          _buildTabButton("vuelta", "Vuelta (Fin → Inicio)"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Recorrido", 
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. Lista de Paradas (Timeline) ---
            if (currentStops.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text("No hay información de paradas para este tramo.",
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
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
                            // Línea visual
                            SizedBox(
                              width: 30,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isFirst ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(
                                        color: isFirst || isLast ? AppColors.secondary : AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isLast ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Texto
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                                child: Text(
                                  stopName,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
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

             // Espacio extra al final
             const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String key, String label) {
    final bool isActive = _selectedTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = key;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}