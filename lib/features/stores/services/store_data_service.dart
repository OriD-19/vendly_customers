import '../models/store.dart';
import '../models/product.dart';
import '../models/promotion.dart';

/// Mock data service for stores and products
class StoreDataService {
  /// Get all available stores with mock data
  static List<Store> getAllStores() {
    return [
      // Pizza Palace
      Store(
        id: '1',
        name: 'Pizza Palace',
        description:
            'Las mejores pizzas artesanales de la ciudad con ingredientes frescos y masa tradicional italiana.',
        category: 'Comida',
        logoUrl: 'assets/images/stores/pizza_palace_logo.png',
        bannerUrl: 'assets/images/stores/pizza_palace_banner.png',
        rating: 4.8,
        reviewCount: 234,
        address: 'Av. Principal 123, Centro',
        phone: '+1 234-567-8900',
        email: 'info@pizzapalace.com',
        hours: const StoreHours(
          monday: '11:00 AM - 11:00 PM',
          tuesday: '11:00 AM - 11:00 PM',
          wednesday: '11:00 AM - 11:00 PM',
          thursday: '11:00 AM - 11:00 PM',
          friday: '11:00 AM - 12:00 AM',
          saturday: '11:00 AM - 12:00 AM',
          sunday: '12:00 PM - 10:00 PM',
        ),
        featuredProducts: [
          Product(
            id: '1_1',
            name: 'Pizza Margherita Artesanal',
            description: 'Auténtica pizza italiana con salsa de tomate casera, mozzarella fresca di bufala y hojas de albahaca fresca. Masa fermentada 24 horas para una textura perfecta.',
            price: 18.99,
            imageUrl: 'assets/images/products/pizza_margherita.png',
            additionalImages: [
              'assets/images/products/pizza_margherita_2.png',
              'assets/images/products/pizza_margherita_3.png',
            ],
            category: 'Pizza',
            stock: 25,
            tags: ['Popular', 'Vegetariana', 'Artesanal'],
            rating: 4.5,
            reviewCount: 120,
            seller: ProductSeller(
              id: 'pizzapalace_seller',
              name: 'Pizza Palace Co.',
              avatar: 'assets/images/sellers/pizza_palace_avatar.png',
              rating: 4.8,
              reviewCount: 250,
            ),
            reviews: [
              ProductReview(
                id: 'review_1_1',
                userName: 'Carlos Martínez',
                userAvatar: 'assets/images/users/carlos.png',
                rating: 5.0,
                comment: '¡Esta pizza es fantástica! La masa está perfecta y los ingredientes son de gran calidad. Definitivamente la mejor margherita que he probado.',
                date: DateTime.now().subtract(const Duration(days: 7)),
              ),
              ProductReview(
                id: 'review_1_2',
                userName: 'María González',
                userAvatar: 'assets/images/users/maria.png',
                rating: 4.0,
                comment: 'Muy buena pizza, pero el tiempo de entrega fue un poco más largo de lo esperado. Aún así, el sabor vale la pena.',
                date: DateTime.now().subtract(const Duration(days: 14)),
              ),
            ],
          ),
          Product(
            id: '1_2',
            name: 'Pizza Pepperoni Premium',
            description: 'Pizza con salsa de tomate, mozzarella de alta calidad y pepperoni premium importado. Una combinación clásica con ingredientes excepcionales.',
            price: 21.99,
            imageUrl: 'assets/images/products/pizza_pepperoni.png',
            additionalImages: [
              'assets/images/products/pizza_pepperoni_2.png',
            ],
            category: 'Pizza',
            stock: 30,
            tags: ['Bestseller', 'Premium'],
            rating: 4.7,
            reviewCount: 85,
            seller: ProductSeller(
              id: 'pizzapalace_seller',
              name: 'Pizza Palace Co.',
              avatar: 'assets/images/sellers/pizza_palace_avatar.png',
              rating: 4.8,
              reviewCount: 250,
            ),
            reviews: [
              ProductReview(
                id: 'review_2_1',
                userName: 'Ana López',
                userAvatar: 'assets/images/users/ana.png',
                rating: 5.0,
                comment: 'El pepperoni tiene un sabor increíble. Se nota la calidad premium en cada bocado.',
                date: DateTime.now().subtract(const Duration(days: 3)),
              ),
            ],
          ),
          Product(
            id: '1_3',
            name: 'Pizza Hawaiana',
            description: 'Salsa de tomate, mozzarella, jamón, piña',
            price: 19.99,
            imageUrl: 'assets/images/products/pizza_hawaiana.png',
            category: 'Pizza',
            stock: 20,
            tags: ['Dulce y Salada'],
          ),
        ],
        tags: ['Pizza', 'Italiana', 'Delivery'],
        isOpen: true,
        isVerified: true,
        deliveryFee: 0.0,
        estimatedDeliveryTime: 25,
      ),

      // Fresh Market
      Store(
        id: '2',
        name: 'Fresh Market',
        description:
            'Supermercado con productos frescos, orgánicos y de la mejor calidad para tu hogar.',
        category: 'Supermercado',
        logoUrl: 'assets/images/stores/fresh_market_logo.png',
        bannerUrl: 'assets/images/stores/fresh_market_banner.png',
        rating: 4.6,
        reviewCount: 567,
        address: 'Calle Comercial 456, Zona Norte',
        phone: '+1 234-567-8901',
        email: 'contacto@freshmarket.com',
        hours: const StoreHours(
          monday: '7:00 AM - 10:00 PM',
          tuesday: '7:00 AM - 10:00 PM',
          wednesday: '7:00 AM - 10:00 PM',
          thursday: '7:00 AM - 10:00 PM',
          friday: '7:00 AM - 10:00 PM',
          saturday: '7:00 AM - 10:00 PM',
          sunday: '8:00 AM - 9:00 PM',
        ),
        featuredProducts: [
          Product(
            id: '2_1',
            name: 'Aguacates Orgánicos',
            description:
                'Aguacates frescos y orgánicos, perfectos para ensaladas',
            price: 3.99,
            imageUrl: 'assets/images/products/avocados.png',
            category: 'Frutas',
            stock: 45,
            tags: ['Orgánico', 'Fresco'],
          ),
          Product(
            id: '2_2',
            name: 'Pan Integral',
            description: 'Pan integral artesanal, horneado diariamente',
            price: 4.50,
            imageUrl: 'assets/images/products/whole_bread.png',
            category: 'Panadería',
            stock: 15,
            tags: ['Artesanal', 'Integral'],
          ),
          Product(
            id: '2_3',
            name: 'Leche Orgánica',
            description: 'Leche entera orgánica, 1 litro',
            price: 5.99,
            imageUrl: 'assets/images/products/organic_milk.png',
            category: 'Lácteos',
            stock: 30,
            tags: ['Orgánico', 'Fresco'],
          ),
        ],
        tags: ['Supermercado', 'Orgánico', 'Fresh'],
        isOpen: true,
        isVerified: true,
        deliveryFee: 2.99,
        estimatedDeliveryTime: 45,
      ),

      // Style Boutique
      Store(
        id: '3',
        name: 'Style Boutique',
        description:
            'Moda contemporánea para hombres y mujeres. Las últimas tendencias al mejor precio.',
        category: 'Ropa',
        logoUrl: 'assets/images/stores/style_boutique_logo.png',
        bannerUrl: 'assets/images/stores/style_boutique_banner.png',
        rating: 4.7,
        reviewCount: 189,
        address: 'Plaza Fashion 789, Centro Comercial',
        phone: '+1 234-567-8902',
        email: 'ventas@styleboutique.com',
        hours: const StoreHours(
          monday: '10:00 AM - 9:00 PM',
          tuesday: '10:00 AM - 9:00 PM',
          wednesday: '10:00 AM - 9:00 PM',
          thursday: '10:00 AM - 9:00 PM',
          friday: '10:00 AM - 10:00 PM',
          saturday: '10:00 AM - 10:00 PM',
          sunday: '11:00 AM - 8:00 PM',
        ),
        featuredProducts: [
          Product(
            id: '3_1',
            name: 'Camiseta Casual',
            description: 'Camiseta de algodón 100%, corte moderno y cómodo',
            price: 24.99,
            imageUrl: 'assets/images/products/casual_shirt.png',
            category: 'Camisetas',
            stock: 12,
            tags: ['Algodón', 'Casual'],
          ),
          Product(
            id: '3_2',
            name: 'Jeans Skinny',
            description: 'Jeans de mezclilla premium, corte skinny',
            price: 59.99,
            imageUrl: 'assets/images/products/skinny_jeans.png',
            category: 'Pantalones',
            stock: 8,
            tags: ['Premium', 'Skinny'],
          ),
          Product(
            id: '3_3',
            name: 'Zapatillas Deportivas',
            description: 'Zapatillas cómodas para uso diario y deportivo',
            price: 79.99,
            imageUrl: 'assets/images/products/sneakers.png',
            category: 'Calzado',
            stock: 15,
            tags: ['Deportivo', 'Cómodo'],
          ),
        ],
        tags: ['Moda', 'Ropa', 'Tendencias'],
        isOpen: true,
        isVerified: true,
        deliveryFee: 4.99,
        estimatedDeliveryTime: 60,
      ),

      // TechZone
      Store(
        id: '4',
        name: 'TechZone',
        description:
            'Los últimos gadgets y tecnología. Smartphones, laptops, accesorios y más.',
        category: 'Tecnología',
        logoUrl: 'assets/images/stores/techzone_logo.png',
        bannerUrl: 'assets/images/stores/techzone_banner.png',
        rating: 4.9,
        reviewCount: 412,
        address: 'Av. Tecnológica 321, Distrito Digital',
        phone: '+1 234-567-8903',
        email: 'soporte@techzone.com',
        hours: const StoreHours(
          monday: '9:00 AM - 8:00 PM',
          tuesday: '9:00 AM - 8:00 PM',
          wednesday: '9:00 AM - 8:00 PM',
          thursday: '9:00 AM - 8:00 PM',
          friday: '9:00 AM - 9:00 PM',
          saturday: '9:00 AM - 9:00 PM',
          sunday: '10:00 AM - 7:00 PM',
        ),
        featuredProducts: [
          Product(
            id: '4_1',
            name: 'Smartphone Pro',
            description:
                'Último modelo con cámara avanzada y batería de larga duración',
            price: 899.99,
            imageUrl: 'assets/images/products/smartphone_pro.png',
            category: 'Smartphones',
            stock: 5,
            tags: ['Nuevo', 'Premium'],
          ),
          Product(
            id: '4_2',
            name: 'Auriculares Bluetooth',
            description: 'Auriculares inalámbricos con cancelación de ruido',
            price: 149.99,
            imageUrl: 'assets/images/products/bluetooth_headphones.png',
            category: 'Accesorios',
            stock: 20,
            tags: ['Inalámbrico', 'HD Audio'],
          ),
          Product(
            id: '4_3',
            name: 'Laptop Gaming',
            description: 'Laptop para gaming con gráficos de alta performance',
            price: 1299.99,
            imageUrl: 'assets/images/products/gaming_laptop.png',
            category: 'Computadoras',
            stock: 3,
            tags: ['Gaming', 'High Performance'],
          ),
        ],
        tags: ['Tecnología', 'Electrónicos', 'Gaming'],
        isOpen: true,
        isVerified: true,
        deliveryFee: 0.0,
        estimatedDeliveryTime: 90,
      ),

      // Farmacia Central
      Store(
        id: '5',
        name: 'Farmacia Central',
        description:
            'Tu farmacia de confianza. Medicamentos, productos de cuidado personal y salud.',
        category: 'Farmacia',
        logoUrl: 'assets/images/stores/farmacia_central_logo.png',
        bannerUrl: 'assets/images/stores/farmacia_central_banner.png',
        rating: 4.5,
        reviewCount: 298,
        address: 'Calle Salud 654, Centro Médico',
        phone: '+1 234-567-8904',
        email: 'info@farmaciacentral.com',
        hours: const StoreHours(
          monday: '8:00 AM - 10:00 PM',
          tuesday: '8:00 AM - 10:00 PM',
          wednesday: '8:00 AM - 10:00 PM',
          thursday: '8:00 AM - 10:00 PM',
          friday: '8:00 AM - 10:00 PM',
          saturday: '8:00 AM - 10:00 PM',
          sunday: '9:00 AM - 9:00 PM',
        ),
        featuredProducts: [
          Product(
            id: '5_1',
            name: 'Vitamina C',
            description: 'Suplemento de vitamina C, 60 tabletas',
            price: 12.99,
            imageUrl: 'assets/images/products/vitamin_c.png',
            category: 'Suplementos',
            stock: 50,
            tags: ['Vitaminas', 'Inmunidad'],
          ),
          Product(
            id: '5_2',
            name: 'Termómetro Digital',
            description: 'Termómetro digital de respuesta rápida',
            price: 29.99,
            imageUrl: 'assets/images/products/digital_thermometer.png',
            category: 'Instrumentos',
            stock: 15,
            tags: ['Digital', 'Precisión'],
          ),
          Product(
            id: '5_3',
            name: 'Crema Hidratante',
            description: 'Crema facial hidratante para todo tipo de piel',
            price: 18.99,
            imageUrl: 'assets/images/products/moisturizing_cream.png',
            category: 'Cuidado Personal',
            stock: 25,
            tags: ['Hidratante', 'Facial'],
          ),
        ],
        tags: ['Farmacia', 'Salud', '24/7'],
        isOpen: true,
        isVerified: true,
        deliveryFee: 1.99,
        estimatedDeliveryTime: 30,
      ),
    ];
  }

  /// Get store by ID
  static Store? getStoreById(String id) {
    try {
      return getAllStores().firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get stores by category
  static List<Store> getStoresByCategory(String category) {
    return getAllStores()
        .where(
          (store) => store.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Get featured stores (top rated)
  static List<Store> getFeaturedStores() {
    final stores = getAllStores();
    stores.sort((a, b) => b.rating.compareTo(a.rating));
    return stores.take(3).toList();
  }

  /// Get store promotions
  static List<Promotion> getStorePromotions(String storeId) {
    // Mock promotions data
    return [
      Promotion(
        id: '1',
        title: '20% OFF Todo el Menú',
        description:
            'Descuento especial en todos los productos hasta fin de mes',
        imageUrl: 'assets/images/promotions/general_discount.png',
        type: PromotionType.percentage,
        discountPercentage: 20.0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        promoCode: 'SAVE20',
      ),
      Promotion(
        id: '2',
        title: 'Envío Gratis',
        description: 'Envío gratuito en pedidos mayores a \$25',
        imageUrl: 'assets/images/promotions/free_delivery.png',
        type: PromotionType.freeDelivery,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
      ),
      Promotion(
        id: '3',
        title: 'Combo Especial',
        description: 'Compra 2 productos y llévate el tercero gratis',
        imageUrl: 'assets/images/promotions/combo_deal.png',
        type: PromotionType.buyOneGetOne,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 15)),
      ),
    ];
  }

  /// Get all products for a store
  static List<Product> getStoreProducts(String storeId) {
    final store = getStoreById(storeId);
    if (store == null) return [];

    // Return featured products plus additional mock products
    final additionalProducts = <Product>[
      // Add more products based on store category
      if (store.category == 'Comida') ...[
        Product(
          id: '${storeId}_extra_1',
          name: 'Caesar Salad',
          description:
              'Lechuga fresca, crutones, queso parmesano, aderezo caesar',
          price: 14.99,
          imageUrl: 'assets/images/products/caesar_salad.png',
          category: 'Ensaladas',
          stock: 18,
          tags: ['Saludable', 'Vegetariano'],
        ),
        Product(
          id: '${storeId}_extra_2',
          name: 'Pasta Carbonara',
          description: 'Pasta con salsa carbonara, tocino, queso parmesano',
          price: 16.99,
          imageUrl: 'assets/images/products/pasta_carbonara.png',
          category: 'Pasta',
          stock: 12,
          tags: ['Italiano', 'Popular'],
        ),
      ],
    ];

    return [...store.featuredProducts, ...additionalProducts];
  }

  /// Get product categories for a store
  static List<ProductCategory> getStoreCategories(String storeId) {
    final store = getStoreById(storeId);
    if (store == null) return [];

    final products = getStoreProducts(storeId);
    final categoryNames = products.map((p) => p.category).toSet().toList();

    return categoryNames.map((name) {
      final categoryProducts = products
          .where((p) => p.category == name)
          .toList();
      return ProductCategory(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        description: 'Productos de $name',
        iconName: name.toLowerCase(),
        productCount: categoryProducts.length,
      );
    }).toList();
  }
}
