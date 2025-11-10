import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Image carousel widget for displaying store showcase images
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 200,
  });

  final List<String> images;
  final double height;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return _buildImageItem(widget.images[index]);
            },
          ),

          // Page indicators
          if (widget.images.length > 1)
            Positioned(
              bottom: AppTheme.spacingS,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String imageUrl) {
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusLarge),
      ),
      child: kIsWeb
          ? _buildWebImage(imageUrl)
          : _buildMobileImage(imageUrl),
    );
  }

  /// Build image for web platform (supports WebP)
  Widget _buildWebImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;
            
        
        return Container(
          color: AppColors.surfaceSecondary,
          child: Center(
            child: CircularProgressIndicator(
              value: progress,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        String errorMsg = error.toString();
        if (errorMsg.contains('statusCode: 0') || errorMsg.contains('NetworkImageLoadException')) {
          errorMsg = 'CORS Error: S3 bucket needs CORS configuration.\nCheck console for details.';
        }
        
        return _buildPlaceholder(errorMessage: errorMsg);
      },
    );
  }

  /// Build image for mobile platforms (uses caching)
  Widget _buildMobileImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) {
        return Container(
          color: AppColors.surfaceSecondary,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return _buildPlaceholder(errorMessage: error.toString());
      },
    );
  }

  Widget _buildPlaceholder({String? errorMessage}) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorMessage != null ? Icons.broken_image : Icons.store,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage != null ? 'Error al cargar imagen' : 'Sin imagen',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  errorMessage.length > 100 
                      ? '${errorMessage.substring(0, 100)}...' 
                      : errorMessage,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.persianIndigo : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
