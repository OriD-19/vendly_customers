import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Orders screen - Shows user's order history and active orders
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedidos',
          style: AppTypography.h3,
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            const TabBar(
              tabs: [
                Tab(text: 'Activos'),
                Tab(text: 'Historial'),
              ],
            ),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Active Orders Tab
                  _ActiveOrdersTab(),
                  
                  // Order History Tab
                  _OrderHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OrderCard(
          orderId: '#12345',
          storeName: 'Pizza Palace',
          status: 'En preparación',
          statusColor: AppColors.warning,
          items: ['Pizza Margherita x1', 'Coca Cola x2'],
          total: '\$25.99',
          estimatedTime: '25 min',
        ),
        
        const SizedBox(height: 16),
        
        _OrderCard(
          orderId: '#12344',
          storeName: 'Farmacia Central',
          status: 'En camino',
          statusColor: AppColors.info,
          items: ['Ibuprofeno x1', 'Vitamina C x1'],
          total: '\$15.50',
          estimatedTime: '10 min',
        ),
      ],
    );
  }
}

class _OrderHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OrderCard(
          orderId: '#12343',
          storeName: 'Super Market',
          status: 'Entregado',
          statusColor: AppColors.success,
          items: ['Leche x2', 'Pan integral x1', 'Huevos x12'],
          total: '\$18.75',
          deliveredDate: 'Ayer, 3:30 PM',
        ),
        
        const SizedBox(height: 16),
        
        _OrderCard(
          orderId: '#12342',
          storeName: 'Fashion Store',
          status: 'Entregado',
          statusColor: AppColors.success,
          items: ['Camiseta azul x1', 'Jeans x1'],
          total: '\$45.00',
          deliveredDate: '15 Mar, 11:15 AM',
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.statusColor,
    required this.items,
    required this.total,
    this.estimatedTime,
    this.deliveredDate,
  });

  final String orderId;
  final String storeName;
  final String status;
  final Color statusColor;
  final List<String> items;
  final String total;
  final String? estimatedTime;
  final String? deliveredDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      storeName,
                      style: AppTypography.h4,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Items
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $item',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: $total',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (estimatedTime != null)
                  Text(
                    'Tiempo estimado: $estimatedTime',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else if (deliveredDate != null)
                  Text(
                    deliveredDate!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            
            // Action buttons for active orders
            if (estimatedTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Rastrear pedido'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Contactar tienda'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}