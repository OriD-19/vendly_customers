import 'package:flutter/material.dart';
import '../features/orders/models/order_request.dart';
import '../features/orders/services/order_service.dart';
import '../features/cart/models/cart_item.dart';

/// Example demonstrating how to create an order using OrderService
class OrderCreationExample extends StatelessWidget {
  const OrderCreationExample({super.key});

  /// Example: Create order from cart items
  Future<void> createOrderExample(List<CartItem> cartItems) async {
    // 1. Convert cart items to order products
    final orderProducts = cartItems.map((item) {
      return OrderProductItem(
        productId: int.tryParse(item.productId) ?? 0,
        quantity: item.quantity,
      );
    }).toList();

    // 2. Create order request with shipping details
    final orderRequest = CreateOrderRequest(
      shippingAddress: 'Calle Principal 123, Colonia Centro',
      shippingCity: 'San Salvador',
      shippingPostalCode: '01101',
      shippingCountry: 'El Salvador',
      products: orderProducts,
    );

    // 3. Submit order to API
    final result = await OrderService.createOrder(orderRequest);

    // 4. Handle result
    if (result.success && result.order != null) {
      print('✅ Order created successfully!');
      print('Order Number: ${result.order!.orderNumber}');
      print('Total Amount: \$${result.order!.totalAmount}');
      print('Status: ${result.order!.status}');
      print('Created: ${result.order!.createdAt}');
    } else {
      print('❌ Order creation failed');
      print('Error: ${result.error}');
    }
  }

  /// Example: Create order with manual product list
  Future<void> createOrderWithProducts() async {
    final orderRequest = CreateOrderRequest(
      shippingAddress: '456 Market Street',
      shippingCity: 'Santa Ana',
      shippingPostalCode: '02101',
      shippingCountry: 'El Salvador',
      products: [
        const OrderProductItem(productId: 1, quantity: 2),
        const OrderProductItem(productId: 5, quantity: 1),
        const OrderProductItem(productId: 12, quantity: 3),
      ],
    );

    final result = await OrderService.createOrder(orderRequest);

    if (result.success) {
      // Navigate to confirmation or show success message
    } else {
      // Show error to user
    }
  }

  /// Example: Full checkout flow in a widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Creation Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Simulate cart items
            final cartItems = [
              const CartItem(
                id: '1',
                productId: '1',
                name: 'Product 1',
                price: 29.99,
                quantity: 2,
                imageUrl: 'https://example.com/image.jpg',
              ),
              const CartItem(
                id: '2',
                productId: '5',
                name: 'Product 2',
                price: 49.99,
                quantity: 1,
                imageUrl: 'https://example.com/image.jpg',
              ),
            ];

            // Create order
            await createOrderExample(cartItems);
          },
          child: const Text('Create Order'),
        ),
      ),
    );
  }
}

/// Example: Order creation with error handling in UI
class OrderCreationWithUI extends StatefulWidget {
  const OrderCreationWithUI({super.key, required this.cartItems});

  final List<CartItem> cartItems;

  @override
  State<OrderCreationWithUI> createState() => _OrderCreationWithUIState();
}

class _OrderCreationWithUIState extends State<OrderCreationWithUI> {
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _processOrder({
    required String address,
    required String city,
    required String postalCode,
  }) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Prepare order products
      final orderProducts = widget.cartItems.map((item) {
        return OrderProductItem(
          productId: int.tryParse(item.productId) ?? 0,
          quantity: item.quantity,
        );
      }).toList();

      // Create request
      final request = CreateOrderRequest(
        shippingAddress: address,
        shippingCity: city,
        shippingPostalCode: postalCode,
        shippingCountry: 'El Salvador',
        products: orderProducts,
      );

      // Submit order
      final result = await OrderService.createOrder(request);

      if (!mounted) return;

      if (result.success && result.order != null) {
        // Success! Navigate to confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pedido creado: ${result.order!.orderNumber}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Error - show message
        setState(() {
          _errorMessage = result.error ?? 'Error al crear el pedido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => _processOrder(
                        address: 'Calle 123',
                        city: 'San Salvador',
                        postalCode: '01101',
                      ),
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Confirmar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
