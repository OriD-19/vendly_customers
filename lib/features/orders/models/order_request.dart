/// Order creation request model
class CreateOrderRequest {
  const CreateOrderRequest({
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.products,
  });

  final String shippingAddress;
  final String shippingCity;
  final String shippingPostalCode;
  final String shippingCountry;
  final List<OrderProductItem> products;

  Map<String, dynamic> toJson() {
    return {
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_postal_code': shippingPostalCode,
      'shipping_country': shippingCountry,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

/// Individual product item in order
class OrderProductItem {
  const OrderProductItem({
    required this.productId,
    required this.quantity,
  });

  final int productId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

/// Order creation response
class OrderResponse {
  const OrderResponse({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  final int orderId;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
