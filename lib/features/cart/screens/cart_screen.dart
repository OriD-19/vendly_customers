import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/cart_item.dart';
import '../models/cart.dart';

/// Cart screen displaying cart items, order summary, and checkout functionality
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Cart _cart;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  /// Initialize cart with hard-coded sample data
  void _initializeCart() {
    _cart = Cart(
      items: [
        const CartItem(
          id: '1',
          productId: 'product_1',
          name: 'Camiseta Clásica',
          price: 45.00,
          quantity: 1,
          size: 'M',
          imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200&h=200&fit=crop&crop=center',
        ),
        const CartItem(
          id: '2',
          productId: 'product_2',
          name: 'Jeans Ajustados',
          price: 60.00,
          quantity: 1,
          size: 'S',
          imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop&crop=center',
        ),
        const CartItem(
          id: '3',
          productId: 'product_3',
          name: 'Zapatos Deportivos',
          price: 15.00,
          quantity: 2,
          size: '8',
          imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop&crop=center',
        ),
      ],
    );
  }

  /// Update item quantity
  void _updateItemQuantity(String itemId, int newQuantity) {
    setState(() {
      _cart = _cart.updateItemQuantity(itemId, newQuantity);
    });
  }

  /// Remove item from cart
  void _removeItem(String itemId) {
    setState(() {
      _cart = _cart.removeItem(itemId);
    });
  }

  /// Handle checkout action
  void _handleCheckout() {
    // Navigate to checkout screen with current cart
    context.push('/checkout', extra: _cart);
  }

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
      ),
      body: _cart.isEmpty ? _buildEmptyCart() : _buildCartContent(),
    );
  }

  /// Build empty cart state
  Widget _buildEmptyCart() {
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
  Widget _buildCartContent() {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cart.items.length,
            itemBuilder: (context, index) {
              final item = _cart.items[index];
              return _CartItemCard(
                item: item,
                onQuantityChanged: (newQuantity) => 
                    _updateItemQuantity(item.id, newQuantity),
                onRemove: () => _removeItem(item.id),
              );
            },
          ),
        ),
        
        // Order summary and checkout
        _buildOrderSummary(),
      ],
    );
  }

  /// Build order summary section
  Widget _buildOrderSummary() {
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
          
          _buildSummaryRow('Subtotal', '\$${_cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Envío', '\$${_cart.shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Impuestos', '\$${_cart.taxAmount.toStringAsFixed(2)}'),
          
          const Divider(height: 24),
          
          _buildSummaryRow(
            'Total', 
            '\$${_cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          
          const SizedBox(height: 24),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleCheckout,
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
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

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
                  onPressed: () => onQuantityChanged(item.quantity - 1),
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
                  onPressed: () => onQuantityChanged(item.quantity + 1),
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