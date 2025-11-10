import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';

/// Product detail screen showing full product information
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  Product? product;
  bool isLoading = true;
  String? errorMessage;
  
  // Review-related state
  List<Review> reviews = [];
  ReviewStats? reviewStats;
  Review? myReview;
  bool isLoadingReviews = false;
  int currentReviewPage = 0;
  bool hasMoreReviews = true;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _loadProduct();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final productId = int.tryParse(widget.productId);
    if (productId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'ID de producto inválido';
      });
      return;
    }

    final result = await ProductService.getProductById(productId);

    if (result.success && result.products.isNotEmpty) {
      setState(() {
        product = result.products.first;
        isLoading = false;
      });
      
      _loadReviews();
      _loadReviewStats();
      _loadMyReview();
    } else {
      setState(() {
        errorMessage = result.error ?? 'No se pudo cargar el producto';
        isLoading = false;
      });
    }
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (product == null) return;

    setState(() {
      isLoadingReviews = true;
    });

    final productId = int.tryParse(widget.productId);
    if (productId == null) return;

    final skip = loadMore ? reviews.length : 0;
    final result = await ReviewService.getProductReviews(
      productId: productId,
      skip: skip,
      limit: 10,
    );

    if (result.success) {
      setState(() {
        if (loadMore) {
          reviews.addAll(result.reviews);
        } else {
          reviews = result.reviews;
        }
        hasMoreReviews = result.reviews.length >= 10;
        isLoadingReviews = false;
      });
    } else {
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadReviewStats() async {
    if (product == null) return;

    final productId = int.tryParse(widget.productId);
    if (productId == null) return;

    final result = await ReviewService.getProductReviewStats(productId);
    if (result.success && result.stats != null) {
      setState(() {
        reviewStats = result.stats;
      });
    }
  }

  Future<void> _loadMyReview() async {
    if (product == null) return;

    final productId = int.tryParse(widget.productId);
    if (productId == null) return;

    final result = await ReviewService.getMyReviewForProduct(productId);
    if (result.success && result.reviews.isNotEmpty) {
      setState(() {
        myReview = result.reviews.first;
      });
    }
  }

  Future<void> _showReviewDialog({Review? existingReview}) async {
    int rating = existingReview?.rating ?? 5;
    final commentController = TextEditingController(text: existingReview?.comment ?? '');

    await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingReview == null ? 'Escribe una opinión' : 'Editar opinión',
            style: AppTypography.h3,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calificación',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'Comentario',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Comparte tu experiencia con este producto...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (existingReview != null)
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Eliminar opinión'),
                      content: const Text('¿Estás seguro de que quieres eliminar tu opinión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    final success = await ReviewService.deleteReview(existingReview.id);
                    if (success && mounted) {
                      Navigator.pop(context, true);
                      setState(() {
                        myReview = null;
                      });
                      _loadReviews();
                      _loadReviewStats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opinión eliminada'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Eliminar'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor escribe un comentario'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                Navigator.pop(context, true);

                final productId = int.tryParse(widget.productId);
                if (productId == null) return;

                if (existingReview == null) {
                  // Create new review
                  final request = CreateReviewRequest(
                    productId: productId,
                    rating: rating,
                    comment: commentController.text.trim(),
                  );
                  final result = await ReviewService.createReview(request);
                  
                  if (result.success && mounted) {
                    setState(() {
                      myReview = result.reviews.first;
                    });
                    _loadReviews();
                    _loadReviewStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opinión publicada'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.error ?? 'Error al publicar opinión'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } else {
                  // Update existing review
                  final request = UpdateReviewRequest(
                    rating: rating,
                    comment: commentController.text.trim(),
                  );
                  final result = await ReviewService.updateReview(
                    reviewId: existingReview.id,
                    request: request,
                  );
                  
                  if (result.success && mounted) {
                    setState(() {
                      myReview = result.reviews.first;
                    });
                    _loadReviews();
                    _loadReviewStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opinión actualizada'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.error ?? 'Error al actualizar opinión'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persianIndigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      appBar: AppBar(
        title: Text(
          'Detalles del Producto',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add to favorites functionality
            },
            icon: const Icon(Icons.favorite_border, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : product == null
                  ? _buildNotFoundState()
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image Carousel
                                _buildImageCarousel(),

                                // Product Information
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildProductHeader(),
                                      const SizedBox(height: 20),
                                      _buildProductDescription(),
                                      const SizedBox(height: 24),
                                      if (product!.tags.isNotEmpty) ...[
                                        _buildCategoriesSection(),
                                        const SizedBox(height: 24),
                                      ],
                                      _buildReviewsSection(),
                                      const SizedBox(height: 24),
                                      if (product!.seller.id != 'default') ...[
                                        _buildSellerInformation(),
                                        const SizedBox(height: 24),
                                      ],
                                      const SizedBox(height: 100), // Space for bottom button
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Add to Cart Button (Fixed at bottom)
                        _buildAddToCartButton(),
                      ],
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el producto',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persianIndigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Producto no encontrado',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El producto que buscas no está disponible',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persianIndigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = product!.allImages;
    
    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                color: AppColors.surfaceSecondary,
              ),
              child: PageView.builder(
                controller: _imageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: images.isEmpty ? 1 : images.length,
                itemBuilder: (context, index) {
                  if (images.isEmpty || images[index].isEmpty) {
                    return _buildPlaceholderImage();
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Container(
                            color: AppColors.surfaceSecondary,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.persianIndigo,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (images.length > 1) ...[
            const SizedBox(height: 16),
            // Image indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? AppColors.persianIndigo
                        : AppColors.borderColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        color: AppColors.surfaceSecondary,
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 120,
          color: AppColors.persianIndigo.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.name,
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Price display with discount support
        if (product!.hasValidDiscount) ...[
          Row(
            children: [
              Text(
                product!.formattedDiscountPrice,
                style: AppTypography.h1.copyWith(
                  color: AppColors.persianIndigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product!.formattedDiscountPercentage,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product!.formattedPrice,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ] else ...[
          Text(
            product!.formattedPrice,
            style: AppTypography.h1.copyWith(
              color: AppColors.persianIndigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        
        // Stock status
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              product!.inStock ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: product!.inStock ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              product!.inStock ? 'En stock' : 'Agotado',
              style: AppTypography.bodyMedium.copyWith(
                color: product!.inStock ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.description,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: product!.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Text(
                tag, // display the name of the tag
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final stats = reviewStats;
    final totalReviews = stats?.totalReviews ?? 0;
    final avgRating = stats?.averageRating ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opiniones',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (myReview != null)
              TextButton.icon(
                onPressed: () => _showReviewDialog(existingReview: myReview),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.persianIndigo,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _showReviewDialog(),
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Escribir opinión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.persianIndigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Rating Summary
        if (stats != null && totalReviews > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                // Average Rating
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: AppTypography.h1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 48,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.floor()
                              ? Icons.star
                              : index < avgRating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: AppColors.warning,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews ${totalReviews == 1 ? 'opinión' : 'opiniones'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                // Rating Breakdown
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 5; i >= 1; i--)
                        _buildRatingBar(i, stats.getPercentage(i)),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sé el primero en opinar',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comparte tu experiencia con este producto',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Individual Reviews
        if (reviews.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...reviews.map((review) => _buildReviewItem(review)),
          
          if (hasMoreReviews)
            Center(
              child: TextButton(
                onPressed: isLoadingReviews ? null : () => _loadReviews(loadMore: true),
                child: isLoadingReviews
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Ver más opiniones',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.persianIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation(AppColors.persianIndigo),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.round()}%',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    final isMyReview = myReview?.id == review.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: isMyReview ? AppColors.persianIndigo : AppColors.borderColor,
          width: isMyReview ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.persianIndigo,
                backgroundImage: review.customerAvatar != null && review.customerAvatar!.isNotEmpty
                    ? CachedNetworkImageProvider(review.customerAvatar!)
                    : null,
                child: review.customerAvatar == null || review.customerAvatar!.isEmpty
                    ? Text(
                        review.customerName.isNotEmpty 
                            ? review.customerName[0].toUpperCase()
                            : '?',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.customerName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isMyReview) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.persianIndigo,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Tú',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      review.formattedDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMyReview)
                IconButton(
                  onPressed: () => _showReviewDialog(existingReview: review),
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.persianIndigo,
                  tooltip: 'Editar opinión',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.floor()
                    ? Icons.star
                    : Icons.star_border,
                color: AppColors.warning,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Vendedor',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.persianIndigo,
                child: Text(
                  product!.seller.name[0].toUpperCase(),
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.seller.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product!.seller.formattedRating,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: product!.inStock
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product!.name} agregado al carrito'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.persianIndigo,
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.persianIndigo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Text(
              product!.inStock ? 'Agregar al Carrito' : 'Agotado',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}