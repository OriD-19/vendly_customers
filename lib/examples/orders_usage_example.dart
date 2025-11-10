import 'package:flutter/material.dart';
import '../features/orders/models/order.dart';
import '../features/orders/services/orders_service.dart';

/// Example demonstrating how to use the OrdersService to fetch and display orders
void main() {
  runApp(const OrdersExampleApp());
}

class OrdersExampleApp extends StatelessWidget {
  const OrdersExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orders Service Example',
      home: const OrdersListExample(),
    );
  }
}

/// Example 1: Fetching all orders
class OrdersListExample extends StatefulWidget {
  const OrdersListExample({super.key});

  @override
  State<OrdersListExample> createState() => _OrdersListExampleState();
}

class _OrdersListExampleState extends State<OrdersListExample> {
  final OrdersService _ordersService = OrdersService();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _ordersService.getOrders();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _orders = result.orders!;
        } else {
          _error = result.error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('No tienes pedidos'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return OrderListItem(order: order);
                      },
                    ),
    );
  }
}

/// Example 2: Order list item widget
class OrderListItem extends StatelessWidget {
  const OrderListItem({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Pedido #${order.orderNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${order.statusText}'),
            Text('Total: ${order.formattedTotal}'),
            Text('Fecha: ${order.formattedDate}'),
            if (order.products.isNotEmpty)
              Text('${order.itemCount} artículos'),
          ],
        ),
        trailing: Icon(_getStatusIcon(order.status)),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailExample(orderId: order.id),
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

/// Example 3: Fetching a single order by ID
class OrderDetailExample extends StatefulWidget {
  const OrderDetailExample({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailExample> createState() => _OrderDetailExampleState();
}

class _OrderDetailExampleState extends State<OrderDetailExample> {
  final OrdersService _ordersService = OrdersService();
  Order? _order;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _ordersService.getOrder(widget.orderId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _order = result.order!;
        } else {
          _error = result.error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${_order?.orderNumber ?? widget.orderId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _order == null
                  ? const Center(child: Text('Pedido no encontrado'))
                  : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status
          _buildSection(
            'Estado',
            Text(
              _order!.statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Order Info
          _buildSection(
            'Información del pedido',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Número de pedido', _order!.orderNumber),
                _buildInfoRow('Fecha', _order!.formattedDate),
                _buildInfoRow('Total', _order!.formattedTotal),
                _buildInfoRow('Artículos', '${_order!.itemCount}'),
              ],
            ),
          ),

          // Shipping Address
          _buildSection(
            'Dirección de envío',
            Text(_order!.fullAddress),
          ),

          // Products
          if (_order!.products.isNotEmpty)
            _buildSection(
              'Productos',
              Column(
                children: _order!.products.map((product) {
                  return Card(
                    child: ListTile(
                      title: Text(product.productName),
                      subtitle: Text('Cantidad: ${product.quantity}'),
                      trailing: Text(product.formattedLineTotal),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Cancel button for active orders
          if (_order!.isActive) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Cancelar pedido'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _ordersService.cancelOrder(widget.orderId);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido cancelado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _order = result.order);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error al cancelar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Example 4: Filtering orders by status
class FilteredOrdersExample extends StatelessWidget {
  const FilteredOrdersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrdersResult>(
      future: OrdersService().getOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final result = snapshot.data!;
        if (result.isError) {
          return Text('Error: ${result.error}');
        }

        final orders = result.orders!;
        
        // Filter active orders
        final activeOrders = orders.where((o) => o.isActive).toList();
        
        // Filter completed orders
        final completedOrders = orders.where((o) => o.isCompleted).toList();
        
        // Filter canceled orders
        final canceledOrders = orders.where((o) => o.isCanceled).toList();

        return Column(
          children: [
            Text('Pedidos activos: ${activeOrders.length}'),
            Text('Pedidos completados: ${completedOrders.length}'),
            Text('Pedidos cancelados: ${canceledOrders.length}'),
          ],
        );
      },
    );
  }
}

/// Example 5: Order model helper methods
void orderModelExamples() {
  // Example order data from API
  final orderJson = {
    "id": 123,
    "order_number": "ORD-2025-001",
    "customer_id": 456,
    "total_amount": 45.99,
    "status": "shipped",
    "shipping_address": "Calle Principal 123",
    "shipping_city": "San Salvador",
    "shipping_postal_code": "1101",
    "shipping_country": "El Salvador",
    "created_at": "2025-11-09T10:00:00Z",
    "updated_at": "2025-11-09T12:00:00Z",
    "products": [
      {
        "product_id": 1,
        "product_name": "Laptop",
        "quantity": 1,
        "price": 45.99,
      }
    ]
  };

  // Parse order from JSON
  final order = Order.fromJson(orderJson);

  // Use helper methods
  print('Order Number: ${order.orderNumber}');
  print('Status: ${order.statusText}'); // "En camino"
  print('Is Active: ${order.isActive}'); // true
  print('Is Completed: ${order.isCompleted}'); // false
  print('Formatted Total: ${order.formattedTotal}'); // "$45.99"
  print('Formatted Date: ${order.formattedDate}'); // "Hoy, 10:00"
  print('Full Address: ${order.fullAddress}');
  print('Item Count: ${order.itemCount}'); // 1

  // Access products
  for (final product in order.products) {
    print('Product: ${product.productName}');
    print('Quantity: ${product.quantity}');
    print('Line Total: ${product.formattedLineTotal}');
  }
}
