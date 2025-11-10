/// Order model representing a customer order
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.createdAt,
    required this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
    this.canceledAt,
    required this.products,
  });

  final int id;
  final String orderNumber;
  final int customerId;
  final double totalAmount;
  final String status; // pending, confirmed, shipped, delivered, canceled
  final String shippingAddress;
  final String shippingCity;
  final String shippingPostalCode;
  final String shippingCountry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? canceledAt;
  final List<OrderProduct> products;

  /// Check if order is active (pending, confirmed, or shipped)
  bool get isActive {
    return status == 'pending' || 
           status == 'confirmed' || 
           status == 'processing' ||
           status == 'shipped';
  }

  /// Check if order is completed (delivered)
  bool get isCompleted {
    return status == 'delivered';
  }

  /// Check if order is canceled
  bool get isCanceled {
    return status == 'canceled';
  }

  /// Get formatted status text in Spanish
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'processing':
        return 'En preparación';
      case 'shipped':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'canceled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  /// Get formatted created date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Hoy, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${createdAt.day} ${months[createdAt.month - 1]}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Get full shipping address
  String get fullAddress {
    return '$shippingAddress, $shippingCity, $shippingPostalCode, $shippingCountry';
  }

  /// Get total items count
  int get itemCount {
    return products.fold(0, (sum, product) => sum + product.quantity);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'] ?? '',
      shippingCity: json['shipping_city'] ?? '',
      shippingPostalCode: json['shipping_postal_code'] ?? '',
      shippingCountry: json['shipping_country'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      canceledAt: json['canceled_at'] != null
          ? DateTime.parse(json['canceled_at'])
          : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => OrderProduct.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Product within an order
class OrderProduct {
  const OrderProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.shortDescription,
  });

  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? shortDescription;

  /// Get formatted line total
  String get formattedLineTotal => '\$${(price * quantity).toStringAsFixed(2)}';

  /// Get formatted unit price
  String get formattedUnitPrice => '\$${price.toStringAsFixed(2)}';

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    // Handle nested product object from API response
    final productData = json['product'] as Map<String, dynamic>?;
    
    // Extract product name (prioritize nested product.name)
    String productName = 'Producto';
    if (productData != null && productData['name'] != null) {
      productName = productData['name'] as String;
    } else if (json['product_name'] != null) {
      productName = json['product_name'] as String;
    } else if (json['name'] != null) {
      productName = json['name'] as String;
    }
    
    // Extract price (prioritize unit_price from order item)
    double price = 0.0;
    if (json['unit_price'] != null) {
      price = (json['unit_price'] is int) 
          ? (json['unit_price'] as int).toDouble() 
          : (json['unit_price'] as double);
    } else if (productData != null && productData['price'] != null) {
      price = (productData['price'] is int)
          ? (productData['price'] as int).toDouble()
          : (productData['price'] as double);
    } else if (json['price'] != null) {
      price = (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as double);
    }
    
    // Extract image URL from nested product.images array
    String? imageUrl;
    if (productData != null && productData['images'] != null) {
      final images = productData['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images[0] as Map<String, dynamic>?;
        imageUrl = firstImage?['image_url'] as String?;
      }
    }
    // Fallback to direct image_url field
    imageUrl ??= json['image_url'] as String?;
    imageUrl ??= json['imageUrl'] as String?;
    
    // Extract short description
    String? shortDescription;
    if (productData != null) {
      shortDescription = productData['short_description'] as String?;
    }

    return OrderProduct(
      productId: json['product_id'] ?? productData?['id'] ?? 0,
      productName: productName,
      quantity: json['quantity'] ?? 1,
      price: price,
      imageUrl: imageUrl,
      shortDescription: shortDescription,
    );
  }
}
