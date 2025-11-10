import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/cart/providers/cart_bloc.dart';
import '../features/cart/providers/cart_event.dart';
import '../features/cart/providers/cart_state.dart';

/// Example widget demonstrating CartBloc usage patterns
class CartUsageExample extends StatelessWidget {
  const CartUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Usage Examples'),
        actions: [
          // Example 1: Display cart badge
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  // Navigate to cart
                },
                icon: Badge(
                  isLabelVisible: state.itemCount > 0,
                  label: Text('${state.itemCount}'),
                  child: const Icon(Icons.shopping_cart),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Example 2: Add to cart button
          ElevatedButton(
            onPressed: () {
              context.read<CartBloc>().add(
                    const AddToCart(
                      productId: '123',
                      name: 'Example Product',
                      price: 29.99,
                      imageUrl: 'https://example.com/image.jpg',
                      size: 'M',
                      quantity: 1,
                    ),
                  );
            },
            child: const Text('Add to Cart'),
          ),

          // Example 3: Display cart items
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.isEmpty) {
                  return const Center(child: Text('Cart is empty'));
                }

                return ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return ListTile(
                      leading: Image.network(item.imageUrl),
                      title: Text(item.name),
                      subtitle: Text('\$${item.price} x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrement quantity
                          IconButton(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    DecrementItemQuantity(item.id),
                                  );
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text('${item.quantity}'),
                          // Increment quantity
                          IconButton(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    IncrementItemQuantity(item.id),
                                  );
                            },
                            icon: const Icon(Icons.add),
                          ),
                          // Remove item
                          IconButton(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    RemoveFromCart(item.id),
                                  );
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Example 4: Display cart summary
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('\$${state.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text(
                          '\$${state.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Example 5: Clear cart button
          ElevatedButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCart());
            },
            child: const Text('Clear Cart'),
          ),

          // Example 6: Listen to errors
          BlocConsumer<CartBloc, CartState>(
            listener: (context, state) {
              if (state.error != null && state.error!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
            builder: (context, state) {
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

/// Example: Custom widget that displays cart item count
class CartItemCountWidget extends StatelessWidget {
  const CartItemCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Text('Items in cart: ${state.itemCount}');
      },
    );
  }
}

/// Example: Custom widget for quick add-to-cart
class QuickAddToCartButton extends StatelessWidget {
  const QuickAddToCartButton({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  final String productId;
  final String productName;
  final double price;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      onPressed: () {
        context.read<CartBloc>().add(
              AddToCart(
                productId: productId,
                name: productName,
                price: price,
                imageUrl: imageUrl,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName added to cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
