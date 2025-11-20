import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';

class ResultScreen extends StatefulWidget {
  // --- PARÁMETROS REQUERIDOS ---
  final AppRoute route;
  final List<String> favoriteRoutes;
  final Function(String) onToggleFavorite;
  final VoidCallback onClose; // Función para cerrar

  const ResultScreen({
    super.key,
    required this.route,
    required this.favoriteRoutes,
    required this.onToggleFavorite,
    required this.onClose,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'ida';

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = widget.favoriteRoutes.contains(widget.route.lineNumber);

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Encabezado (con botones actualizados) ---
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: IconButton(
                  icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
                  onPressed: widget.onClose,
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.star,
                      color: isFavorite ? AppColors.star : AppColors.textInactive,
                    ),
                    onPressed: () {
                      // Llama a la función para (des)marcar
                      widget.onToggleFavorite(widget.route.lineNumber);
                    },
                  ),
                ],
              ),

              // --- Tarjeta principal de la Ruta (Sin cambios) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Línea detectada", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRouteHeader(widget.route),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // --- Pestañas de "Ida" y "Vuelta" (Sin cambios) ---
              SliverPersistentHeader(
                delegate: _StopsHeaderDelegate(
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                ),
                pinned: true,
              ),

              // --- Lista de Paradas (Sin cambios) ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stops = widget.route.stops[_selectedTab] ?? [];
                    final stopName = stops[index];
                    final isFirst = index == 0;
                    final isLast = index == stops.length - 1;
                    return _StopRowItem(stopName: stopName, isFirst: isFirst, isLast: isLast);
                  },
                  childCount: (widget.route.stops[_selectedTab] ?? []).length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120), // Espacio para el botón flotante
              ),
            ],
          ),

          // --- Botón flotante "Ver en Mapa" (Sin cambios) ---
          _buildViewMapButton(context),
        ],
      ),
    );
  }

  // --- WIDGETS INTERNOS ---

  // _buildViewMapButton 
  Widget _buildViewMapButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: GestureDetector(
            onTap: () {
              // Acción del mapa
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.map, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Ver en mapa",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // _buildRouteHeader (Sin cambios)
  Widget _buildRouteHeader(AppRoute route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.bus, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    route.lineNumber,
                    style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  route.routeName,
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// _StopRowItem (Sin cambios)
class _StopRowItem extends StatelessWidget {
  final String stopName;
  final bool isFirst;
  final bool isLast;

  const _StopRowItem({required this.stopName, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(width: 2, height: 12, color: isFirst ? Colors.transparent : AppColors.primary.withOpacity(0.3)),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.3),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                Container(width: 2, height: 12, color: isLast ? Colors.transparent : AppColors.primary.withOpacity(0.3)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(stopName, style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  _StopsHeaderDelegate({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          _buildTab('ida', 'Paradas de Ida'),
          const SizedBox(width: 16),
          _buildTab('vuelta', 'Paradas de Vuelta'),
        ],
      ),
    );
  }

  Widget _buildTab(String tabKey, String title) {
    final bool isActive = selectedTab == tabKey;
    return GestureDetector(
      onTap: () => onTabSelected(tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.background : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72.0;
  @override
  double get minExtent => 72.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}