import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_required.dart';
import '../models/cart_item.dart';
import '../providers/cart_bloc.dart';
import '../providers/cart_state.dart';
import '../providers/cart_event.dart';

/// Cart screen displaying cart items, order summary, and checkout functionality
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aliceBlue,
      appBar: AppBar(
        backgroundColor: AppColors.aliceBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.russianViolet,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mi Carrito',
          style: AppTypography.h2.copyWith(
            color: AppColors.russianViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.russianViolet,
                ),
                onPressed: () => _showClearCartDialog(context),
                tooltip: 'Vaciar carrito',
              );
            },
          ),
        ],
      ),
      body: AuthRequired(
        message: 'Inicia sesión para ver tu carrito de compras',
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state.error != null && state.error!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isEmpty) {
              return _buildEmptyCart(context);
            }

            return _buildCartContent(context, state);
          },
        ),
      ),
    );
  }

  /// Show dialog to confirm clearing cart
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '¿Vaciar carrito?',
          style: AppTypography.h3,
        ),
        content: Text(
          'Se eliminarán todos los productos del carrito',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCart());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  /// Handle checkout action
  void _handleCheckout(BuildContext context, CartState state) {
    // Navigate to checkout screen with current cart
    context.push('/checkout', extra: state.cart);
  }

  /// Build empty cart state
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.mauve.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: AppTypography.h2.copyWith(
              color: AppColors.russianViolet,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunos productos para comenzar',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.russianViolet.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.persianIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: const Text('Explorar Productos'),
          ),
        ],
      ),
    );
  }

  /// Build cart content with items and summary
  Widget _buildCartContent(BuildContext context, CartState state) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _CartItemCard(item: item);
            },
          ),
        ),
        
        // Order summary and checkout
        _buildOrderSummary(context, state),
      ],
    );
  }

  /// Build order summary section
  Widget _buildOrderSummary(BuildContext context, CartState state) {
    final cart = state.cart;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Resumen del Pedido',
            style: AppTypography.h3.copyWith(
              color: AppColors.russianViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Envío', '\$${cart.shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Impuestos', '\$${cart.taxAmount.toStringAsFixed(2)}'),
          
          const Divider(height: 24),
          
          _buildSummaryRow(
            'Total', 
            '\$${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          
          const SizedBox(height: 24),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheckout(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persianIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                elevation: 0,
              ),
              child: Text(
                'Proceder al Pago',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary row widget
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTypography.h4 : AppTypography.bodyMedium).copyWith(
            color: isTotal ? AppColors.russianViolet : AppColors.russianViolet.withOpacity(0.8),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: (isTotal ? AppTypography.h4 : AppTypography.bodyMedium).copyWith(
            color: AppColors.russianViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Cart item card widget
class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
  });

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                color: AppColors.aliceBlue,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.aliceBlue,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.mauve,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.russianViolet,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.size != null)
                    Text(
                      'Talla ${item.size}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mauve,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.russianViolet,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity controls
            Row(
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  onPressed: () => context.read<CartBloc>().add(
                    DecrementItemQuantity(item.id),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    item.quantity.toString(),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.russianViolet,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add,
                  onPressed: () => context.read<CartBloc>().add(
                    IncrementItemQuantity(item.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity control button widget
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.persianIndigo,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}