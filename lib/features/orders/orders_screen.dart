import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/auth_required.dart';
import 'models/order.dart';
import 'providers/orders_provider.dart';

/// Orders screen - Shows user's order history and active orders
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Pedidos', style: AppTypography.h3)),
      body: AuthRequired(
        message: 'Inicia sesión para ver tus pedidos',
        child: DefaultTabController(
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
                child: ordersState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ordersState.error != null && ordersState.error!.isNotEmpty
                        ? _buildErrorView(context, ref, ordersState.error!)
                        : TabBarView(
                            children: [
                              // Active Orders Tab
                              _ActiveOrdersTab(
                                orders: ordersState.activeOrders,
                              ),

                              // Order History Tab
                              _OrderHistoryTab(
                                orders: ordersState.completedOrders,
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(ordersProvider.notifier).retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrdersTab extends ConsumerWidget {
  const _ActiveOrdersTab({
    required this.orders,
  });

  final List<Order> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes pedidos activos',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus pedidos en proceso aparecerán aquí',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < orders.length - 1 ? 16 : 0),
            child: _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderHistoryTab extends ConsumerWidget {
  const _OrderHistoryTab({
    required this.orders,
  });

  final List<Order> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes historial de pedidos',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus pedidos completados aparecerán aquí',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < orders.length - 1 ? 16 : 0),
            child: _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
  });

  final Order order;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'shipped':
        return AppColors.mauve;
      case 'delivered':
        return AppColors.success;
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('¿Estás seguro de que quieres cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(ordersProvider.notifier).cancelOrder(order.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido cancelado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(ordersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al cancelar el pedido'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsModal(order: order),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final isCanceling = ordersState.isCancelingOrder && 
                        ordersState.cancelingOrderId == order.id;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.itemCount} ${order.itemCount == 1 ? "artículo" : "artículos"}',
                        style: AppTypography.h4,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: AppTypography.labelSmall.copyWith(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (order.products.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Products
              ...order.products.take(3).map((product) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.productName} x${product.quantity}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        product.formattedLineTotal,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              if (order.products.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${order.products.length - 3} más',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      order.formattedTotal,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  order.formattedDate,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Shipping address for active orders
            if (order.isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.fullAddress,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Action buttons for active orders
            if (order.isActive && !isCanceling) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showOrderDetails(context, order),
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Ver detalles'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelOrder(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ] else if (isCanceling) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ] else ...[
              // Details button for completed/canceled orders
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showOrderDetails(context, order),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Ver detalles'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modal showing detailed order information
class _OrderDetailsModal extends StatelessWidget {
  const _OrderDetailsModal({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del pedido',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${order.orderNumber}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Status
                  _buildSection(
                    'Estado del pedido',
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.statusText,
                        style: AppTypography.bodyLarge.copyWith(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Information
                  _buildSection(
                    'Información del pedido',
                    Column(
                      children: [
                        _buildInfoRow('Fecha', order.formattedDate),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Artículos',
                          '${order.itemCount} ${order.itemCount == 1 ? "artículo" : "artículos"}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shipping Address
                  _buildSection(
                    'Dirección de envío',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: AppColors.mauve,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.shippingAddress,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(
                            '${order.shippingCity}, ${order.shippingPostalCode}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(
                            order.shippingCountry,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Products
                  _buildSection(
                    'Productos (${order.products.length})',
                    Column(
                      children: order.products.map((product) {
                        return _ProductItem(product: product);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSection(
                    'Resumen',
                    Column(
                      children: [
                        _buildInfoRow('Subtotal', order.formattedTotal),
                        const SizedBox(height: 8),
                        _buildInfoRow('Envío', '\$0.00'),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTypography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              order.formattedTotal,
                              style: AppTypography.h3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mauve,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'shipped':
        return AppColors.mauve;
      case 'delivered':
        return AppColors.success;
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Product item widget for order details
class _ProductItem extends StatelessWidget {
  const _ProductItem({required this.product});

  final OrderProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.borderColor,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.borderColor,
                    child: Icon(
                      Icons.shopping_bag,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.shortDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.shortDescription!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Cantidad: ${product.quantity}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.formattedUnitPrice,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Price
          Text(
            product.formattedLineTotal,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.mauve,
            ),
          ),
        ],
      ),
    );
  }
}
