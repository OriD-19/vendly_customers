import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';

/// Order confirmation screen showing successful order placement
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({
    super.key,
    this.orderNumber,
    this.totalAmount,
    this.orderDate,
  });

  final String? orderNumber;
  final double? totalAmount;
  final DateTime? orderDate;

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Get order number from widget or generate a fallback
  String get orderNumber => 
      widget.orderNumber ?? 'VEN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  
  double get totalAmount => widget.totalAmount ?? 0.0;
  
  DateTime get orderDate => widget.orderDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Navigate to home screen
  void _goToHome() {
    context.go('/home');
  }

  /// Navigate to orders screen
  void _viewOrder() {
    // For now, just navigate to orders screen
    // In a real app, this would navigate to the specific order detail
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aliceBlue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Success message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            '¡Pedido Confirmado!',
                            style: AppTypography.h1.copyWith(
                              color: AppColors.russianViolet,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Tu pedido ha sido procesado exitosamente',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.russianViolet.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Order details card
                          _buildOrderDetailsCard(),
                          
                          const SizedBox(height: 32),
                          
                          // Information text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.persianIndigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              border: Border.all(
                                color: AppColors.persianIndigo.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.persianIndigo,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Información del Pedido',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.persianIndigo,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Recibirás una confirmación por correo electrónico y notificaciones sobre el estado de tu entrega.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.russianViolet.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // View order button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.persianIndigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver Mi Pedido',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Continue shopping button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _goToHome,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.persianIndigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                          ),
                          side: BorderSide(
                            color: AppColors.persianIndigo,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              size: 20,
                              color: AppColors.persianIndigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continuar Comprando',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.persianIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build order details card
  Widget _buildOrderDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Order number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.persianIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.persianIndigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número de Pedido',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.russianViolet.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      orderNumber,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.russianViolet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Estimated delivery
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrega Estimada',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.russianViolet.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '3-5 días hábiles',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.russianViolet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Tracking info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.track_changes,
                  color: AppColors.mauve,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguimiento',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.russianViolet.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      'Te enviaremos actualizaciones',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.russianViolet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}