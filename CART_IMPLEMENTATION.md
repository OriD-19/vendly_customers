# Shopping Cart Implementation with Bloc

This document explains the shopping cart implementation using the Bloc state management pattern.

## Overview

The shopping cart is implemented using **flutter_bloc** for state management with local persistence via **SharedPreferences**. The cart state is globally accessible throughout the app and automatically persists changes to local storage.

## Architecture

### 📁 File Structure

```
lib/features/cart/
├── models/
│   ├── cart.dart              # Cart model with business logic
│   └── cart_item.dart         # Individual cart item model
├── providers/
│   ├── cart_bloc.dart         # Cart BLoC (Business Logic Component)
│   ├── cart_event.dart        # Cart events (actions)
│   ├── cart_state.dart        # Cart state
│   └── cart_provider.dart     # Barrel file for exports
└── screens/
    └── cart_screen.dart       # Cart UI
```

## Components

### 1. CartBloc (`cart_bloc.dart`)

The main business logic component that handles all cart operations.

**Responsibilities:**
- Managing cart items (add, update, remove, clear)
- Persisting cart to local storage
- Loading cart from storage on app start
- Handling quantity increments/decrements
- Automatic deduplication (same product + size)

**Key Methods:**
- `_onAddToCart` - Adds item or updates quantity if already exists
- `_onUpdateCartItemQuantity` - Updates item quantity (removes if ≤ 0)
- `_onIncrementItemQuantity` - Increases quantity by 1
- `_onDecrementItemQuantity` - Decreases quantity by 1 (removes if reaches 0)
- `_onRemoveFromCart` - Removes item completely
- `_onClearCart` - Empties entire cart
- `_onLoadCart` - Loads cart from SharedPreferences
- `_saveCart` - Persists cart to SharedPreferences

### 2. CartEvent (`cart_event.dart`)

Events that trigger state changes in the CartBloc.

**Available Events:**

```dart
// Add product to cart
AddToCart(
  productId: '123',
  name: 'Product Name',
  price: 29.99,
  imageUrl: 'https://...',
  size: 'M',        // Optional
  quantity: 1,      // Default: 1
)

// Update item quantity directly
UpdateCartItemQuantity(
  itemId: 'uuid-...',
  quantity: 3,
)

// Increment quantity by 1
IncrementItemQuantity('uuid-...')

// Decrement quantity by 1 (removes if reaches 0)
DecrementItemQuantity('uuid-...')

// Remove item completely
RemoveFromCart('uuid-...')

// Clear entire cart
ClearCart()

// Load cart from storage (called on app start)
LoadCart()
```

### 3. CartState (`cart_state.dart`)

Immutable state representing the current cart.

**Properties:**
- `items` - List of CartItem objects
- `isLoading` - Loading indicator
- `error` - Error message (if any)

**Computed Properties:**
- `cart` - Cart object with business logic
- `isEmpty` - True if no items
- `itemCount` - Total quantity of all items
- `subtotal` - Sum of (price × quantity) for all items
- `total` - Subtotal + shipping + tax

### 4. CartItem Model (`cart_item.dart`)

Represents a single product in the cart.

**Properties:**
- `id` - Unique identifier (UUID)
- `productId` - Reference to product
- `name` - Product name
- `price` - Unit price
- `quantity` - Number of items
- `imageUrl` - Product image
- `size` - Optional size variant
- `color` - Optional color variant

**Methods:**
- `totalPrice` - Returns `price × quantity`
- `copyWith()` - Creates copy with updated fields
- `toJson()` / `fromJson()` - Serialization for storage

## Usage Examples

### 1. Adding Product to Cart

```dart
// In ProductDetailScreen
ElevatedButton(
  onPressed: () {
    context.read<CartBloc>().add(
      AddToCart(
        productId: product.id.toString(),
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        size: selectedSize,  // Optional
      ),
    );
  },
  child: Text('Agregar al Carrito'),
)
```

### 2. Displaying Cart Items

```dart
// In CartScreen
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    if (state.isEmpty) {
      return EmptyCartWidget();
    }
    
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return CartItemCard(item: item);
      },
    );
  },
)
```

### 3. Updating Quantity

```dart
// Increment
IconButton(
  onPressed: () {
    context.read<CartBloc>().add(
      IncrementItemQuantity(item.id),
    );
  },
  icon: Icon(Icons.add),
)

// Decrement
IconButton(
  onPressed: () {
    context.read<CartBloc>().add(
      DecrementItemQuantity(item.id),
    );
  },
  icon: Icon(Icons.remove),
)
```

### 4. Showing Cart Badge

```dart
// In BottomNavigationBar
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    return BottomNavigationBarItem(
      icon: state.itemCount > 0
          ? Badge(
              label: Text('${state.itemCount}'),
              child: Icon(Icons.shopping_cart),
            )
          : Icon(Icons.shopping_cart),
      label: 'Carrito',
    );
  },
)
```

### 5. Listening to Errors

```dart
BlocConsumer<CartBloc, CartState>(
  listener: (context, state) {
    if (state.error != null && state.error!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  },
  builder: (context, state) {
    return YourWidget();
  },
)
```

## Features

### ✅ Automatic Deduplication
When adding a product that already exists (same `productId` and `size`), the quantity is incremented instead of creating a duplicate entry.

### ✅ Persistent Storage
Cart is automatically saved to SharedPreferences after every change and loaded on app start.

### ✅ Smart Quantity Management
- Incrementing/decrementing updates quantity
- Decrementing to 0 removes the item
- Negative quantities are prevented

### ✅ Global Access
Cart state is provided at the app root level, accessible from any screen using:
```dart
context.read<CartBloc>()  // To dispatch events
context.watch<CartBloc>() // To listen to state changes
```

### ✅ Error Handling
All operations are wrapped in try-catch blocks with user-friendly error messages in Spanish.

## Integration Points

### App Initialization (`main.dart`)
```dart
BlocProvider(
  create: (context) => CartBloc()..add(const LoadCart()),
  child: MaterialApp.router(...),
)
```

### Product Detail Screen
- "Agregar al Carrito" button dispatches `AddToCart` event
- Shows SnackBar with "Ver Carrito" action

### Cart Screen
- Displays all cart items
- Quantity controls (+ / -)
- Remove item functionality
- Clear cart button in AppBar
- Order summary with totals
- Checkout button

### Main Navigation
- Cart badge shows total item count
- Badge only visible when cart has items

## Future Enhancements

### 🚀 Possible Additions
1. **Cart Size Limits** - Prevent adding more than X items
2. **Stock Validation** - Check product availability before adding
3. **Discount Codes** - Apply promo codes to cart total
4. **Wishlist Integration** - Move items between cart and wishlist
5. **Recently Removed** - Undo remove action
6. **Cart Expiry** - Auto-clear after X days
7. **Multi-Currency** - Support different currencies
8. **Sync with Backend** - Persist cart to server for logged-in users

## Testing

### Unit Tests
```dart
test('should add item to empty cart', () {
  final bloc = CartBloc();
  bloc.add(AddToCart(
    productId: '1',
    name: 'Test Product',
    price: 10.0,
    imageUrl: 'test.jpg',
  ));
  
  expect(bloc.state.items.length, 1);
  expect(bloc.state.itemCount, 1);
});
```

### Widget Tests
```dart
testWidgets('should display cart items', (tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => CartBloc(),
      child: MaterialApp(home: CartScreen()),
    ),
  );
  
  expect(find.byType(CartItemCard), findsWidgets);
});
```

## Troubleshooting

### Cart not persisting between app restarts
- Check SharedPreferences permissions
- Verify `LoadCart()` event is dispatched in `main.dart`
- Check for JSON serialization errors

### Items duplicating instead of updating quantity
- Ensure `productId` and `size` match exactly
- Check equality comparison in `_onAddToCart`

### State not updating in UI
- Use `BlocBuilder` or `BlocConsumer` instead of `BlocListener`
- Verify widget is wrapped in `BlocProvider`
- Check that events are being dispatched correctly

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  shared_preferences: ^2.4.13
  uuid: ^4.5.1
```

## Summary

The shopping cart implementation provides:
- ✅ Clean separation of concerns (BLoC pattern)
- ✅ Persistent storage
- ✅ Global state management
- ✅ Automatic deduplication
- ✅ Error handling
- ✅ Type-safe operations
- ✅ Reactive UI updates
- ✅ Spanish localization

This architecture makes it easy to maintain, test, and extend the cart functionality as the app grows.
