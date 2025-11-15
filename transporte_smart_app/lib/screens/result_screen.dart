import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';

class ResultScreen extends StatefulWidget {
  // Recibirá la ruta que queremos mostrar
  final AppRoute route;

  const ResultScreen({super.key, required this.route});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  // 'ida' o 'vuelta'
  String _selectedTab = 'ida';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Fondo bg-[#1C1917]
      body: CustomScrollView(
        slivers: [
          // --- 1. Encabezado (con botón de cerrar) ---
          SliverAppBar(
            backgroundColor: Colors.transparent,
            pinned: true,
            leading: IconButton(
              icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Botón de Favorito
              IconButton(
                icon: Icon(LucideIcons.star, color: AppColors.star),
                onPressed: () {
                  // Lógica para guardar favorito
                },
              ),
            ],
          ),

          // --- 2. Tarjeta principal de la Ruta (Traducción de tu tarjeta) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Línea detectada",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildRouteHeader(widget.route),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // --- 3. Pestañas de "Ida" y "Vuelta" ---
          SliverPersistentHeader(
            delegate: _StopsHeaderDelegate(
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),
            pinned: true, // Se queda pegado arriba
          ),

          // --- 4. Lista de Paradas (ListView) ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Muestra la lista de 'ida' o 'vuelta' según la pestaña
                final stops = widget.route.stops[_selectedTab] ?? [];
                final stopName = stops[index];
                final isFirst = index == 0;
                final isLast = index == stops.length - 1;

                return _StopRowItem(
                  stopName: stopName,
                  isFirst: isFirst,
                  isLast: isLast,
                );
              },
              // Cuenta la cantidad de paradas en la pestaña seleccionada
              childCount: (widget.route.stops[_selectedTab] ?? []).length,
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta principal (Traducción de tu 'RouteItem' de RoutesScreen)
  Widget _buildRouteHeader(AppRoute route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5), // Un poco más oscuro
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
                    style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  route.routeName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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

// --- WIDGET PARA LA LISTA DE PARADAS (Traducción de tu 'StopRow') ---
class _StopRowItem extends StatelessWidget {
  final String stopName;
  final bool isFirst;
  final bool isLast;

  const _StopRowItem({
    required this.stopName,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          // --- El círculo y las líneas de la línea de tiempo ---
          SizedBox(
            width: 24, // Ancho fijo para alinear
            child: Column(
              children: [
                // Línea superior (invisible si es el primero)
                Container(
                  width: 2,
                  height: 12,
                  color: isFirst ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                ),
                // Círculo
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.3),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                // Línea inferior (invisible si es el último)
                Container(
                  width: 2,
                  height: 12,
                  color: isLast ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Nombre de la parada
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0), // Alinear con el círculo
              child: Text(
                stopName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PARA LAS PESTAÑAS "IDA" Y "VUELTA" ---
class _StopsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  _StopsHeaderDelegate({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface, // Fondo para que tape el scroll
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