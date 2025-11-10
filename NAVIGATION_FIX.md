# Navigation Fix - GlobalKey Duplication Error

## Problem

When navigating to the cart screen via bottom navigation, the app threw this error:

```
EXCEPTION CAUGHT BY WIDGETS LIBRARY
Assertion failed: !keyReservation.contains(key) is not true
Another exception was thrown: A GlobalKey was used multiple times inside one widget's child list.
```

## Root Cause

The issue was in `lib/shared/main_scaffold.dart` in the `_onItemTapped` method:

**BEFORE (❌ Wrong):**
```dart
void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      GoRouter.of(context).push(AppRouter.home);  // ❌ Using push()
      break;
    case 2:
      GoRouter.of(context).push(AppRouter.cart);  // ❌ Using push()
      break;
    // ...
  }
}
```

### Why This Failed

- `context.push()` **adds** a new route to the navigation stack
- Bottom navigation should **replace** the current route, not stack them
- Repeatedly tapping bottom nav items created multiple duplicate routes
- This caused GoRouter to generate duplicate GlobalKeys for widgets
- Flutter detected the duplicate keys and threw an assertion error

## Solution

Changed navigation method from `push()` to `go()`:

**AFTER (✅ Correct):**
```dart
void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go(AppRouter.home);  // ✅ Using go()
      break;
    case 2:
      context.go(AppRouter.cart);  // ✅ Using go()
      break;
    // ...
  }
}
```

Also added cart route to `_calculateSelectedIndex`:

```dart
static int _calculateSelectedIndex(String location) {
  switch (location) {
    case '/home':
      return 0;
    case '/search':
      return 1;
    case '/cart':      // ✅ Added cart case
      return 2;
    case '/orders':
      return 3;
    default:
      return 0;
  }
}
```

## Key Differences: push() vs go()

### `context.push(route)`
- Adds route to navigation stack
- Maintains previous route in memory
- Shows back button
- Use for: Product details, nested screens, modals

### `context.go(route)`
- Replaces current route
- Clears previous route from stack
- No back button needed
- Use for: Bottom navigation, tab switching, main sections

## Best Practices

### ✅ Use `go()` for:
- Bottom navigation bar items
- Tab switching
- Main app sections
- Resetting navigation state

### ✅ Use `push()` for:
- Product detail screens
- Checkout flow
- Settings screens
- Nested navigation
- Any screen that should show a back button

### Example Flow

```dart
// Main sections - use go()
context.go('/home');
context.go('/cart');
context.go('/search');

// Nested screens - use push()
context.push('/store/123');
context.push('/product/456');
context.push('/checkout');
```

## Verification

After the fix, navigation works correctly:

1. ✅ Tapping cart icon in bottom nav opens cart screen
2. ✅ No GlobalKey duplication errors
3. ✅ Bottom nav highlights correct tab
4. ✅ Can switch between tabs smoothly
5. ✅ Cart badge shows correct item count

## Related Files Modified

- `lib/shared/main_scaffold.dart` - Changed `push()` to `go()` in bottom navigation
- `lib/shared/main_scaffold.dart` - Added `/cart` case to `_calculateSelectedIndex()`
- `lib/features/stores/screens/product_detail_screen.dart` - Changed `push()` to `go()` in SnackBar action

## Common Mistake: SnackBar Actions

Another place where this error commonly occurs is in SnackBar actions:

**BEFORE (❌ Wrong):**
```dart
SnackBar(
  content: Text('Product added to cart'),
  action: SnackBarAction(
    label: 'Ver Carrito',
    onPressed: () => context.push('/cart'),  // ❌ Wrong!
  ),
)
```

**AFTER (✅ Correct):**
```dart
SnackBar(
  content: Text('Product added to cart'),
  action: SnackBarAction(
    label: 'Ver Carrito',
    onPressed: () => context.go('/cart'),  // ✅ Correct!
  ),
)
```

When navigating to main app sections (home, cart, search, orders) from anywhere in the app, always use `context.go()` to avoid navigation stack conflicts.

## Testing Checklist

- [x] Cart screen opens without errors
- [x] Bottom navigation highlights correct tab
- [x] Can switch between Home, Search, Cart, Orders
- [x] Cart badge updates correctly
- [x] No navigation stack buildup
- [x] Back button behavior correct
- [x] SnackBar "Ver Carrito" action works without errors
