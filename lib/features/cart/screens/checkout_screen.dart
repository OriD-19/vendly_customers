import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../models/cart.dart';

/// Checkout screen for payment and shipping information
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Credit card controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // Address controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Additional notes
  final _notesController = TextEditingController();
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Process the order
  void _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate to confirmation screen
    context.push('/checkout/confirmation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aliceBlue,
      appBar: AppBar(
        backgroundColor: AppColors.aliceBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.russianViolet,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Finalizar Compra',
          style: AppTypography.h2.copyWith(
            color: AppColors.russianViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary card
                    _buildOrderSummaryCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Credit card section
                    _buildSectionTitle('Información de Pago'),
                    const SizedBox(height: 16),
                    _buildCreditCardForm(),
                    
                    const SizedBox(height: 24),
                    
                    // Address section
                    _buildSectionTitle('Dirección de Envío'),
                    const SizedBox(height: 16),
                    _buildAddressForm(),
                    
                    const SizedBox(height: 24),
                    
                    // Additional notes section
                    _buildSectionTitle('Notas Adicionales'),
                    const SizedBox(height: 16),
                    _buildNotesForm(),
                    
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            
            // Process order button
            _buildProcessOrderButton(),
          ],
        ),
      ),
    );
  }

  /// Build order summary card
  Widget _buildOrderSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Pedido',
            style: AppTypography.h3.copyWith(
              color: AppColors.russianViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos (${widget.cart.itemCount})',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet.withOpacity(0.8),
                ),
              ),
              Text(
                '\$${widget.cart.subtotal.toStringAsFixed(2)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Envío',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet.withOpacity(0.8),
                ),
              ),
              Text(
                '\$${widget.cart.shippingCost.toStringAsFixed(2)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Impuestos',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet.withOpacity(0.8),
                ),
              ),
              Text(
                '\$${widget.cart.taxAmount.toStringAsFixed(2)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.russianViolet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTypography.h4.copyWith(
                  color: AppColors.russianViolet,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${widget.cart.total.toStringAsFixed(2)}',
                style: AppTypography.h4.copyWith(
                  color: AppColors.russianViolet,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h3.copyWith(
        color: AppColors.russianViolet,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Build credit card form
  Widget _buildCreditCardForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Card number
          _buildTextField(
            controller: _cardNumberController,
            label: 'Número de Tarjeta',
            hintText: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberInputFormatter(),
            ],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Ingresa el número de tarjeta';
              }
              if (value!.replaceAll(' ', '').length < 16) {
                return 'Número de tarjeta inválido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Cardholder name
          _buildTextField(
            controller: _cardHolderController,
            label: 'Nombre del Titular',
            hintText: 'Juan Pérez',
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Ingresa el nombre del titular';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Expiry and CVV row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _expiryController,
                  label: 'Fecha de Vencimiento',
                  hintText: 'MM/AA',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Fecha requerida';
                    }
                    if (value!.length < 5) {
                      return 'Formato inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'CVV requerido';
                    }
                    if (value!.length < 3) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build address form
  Widget _buildAddressForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Address
          _buildTextField(
            controller: _addressController,
            label: 'Dirección',
            hintText: 'Calle 123, Colonia Centro',
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Ingresa tu dirección';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // City and ZIP row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Ciudad',
                  hintText: 'Ciudad de México',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Ciudad requerida';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _zipController,
                  label: 'Código Postal',
                  hintText: '12345',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'CP requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Phone number
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono',
            hintText: '55 1234 5678',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Ingresa tu teléfono';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build notes form
  Widget _buildNotesForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Notas para el Repartidor (Opcional)',
          hintText: 'Ej: Tocar el timbre dos veces, casa azul...',
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.mauve,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.russianViolet.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            borderSide: BorderSide(
              color: AppColors.mauve.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            borderSide: BorderSide(
              color: AppColors.persianIndigo,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            borderSide: BorderSide(
              color: AppColors.mauve.withOpacity(0.3),
            ),
          ),
          filled: true,
          fillColor: AppColors.aliceBlue.withOpacity(0.3),
        ),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.russianViolet,
        ),
      ),
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mauve,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.russianViolet.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(
            color: AppColors.mauve.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(
            color: AppColors.persianIndigo,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(
            color: AppColors.mauve.withOpacity(0.3),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.aliceBlue.withOpacity(0.3),
      ),
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.russianViolet,
      ),
    );
  }

  /// Build process order button
  Widget _buildProcessOrderButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.persianIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Procesando...',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Confirmar Pedido - \$${widget.cart.total.toStringAsFixed(2)}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Card number input formatter
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

/// Expiry date input formatter
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 2) {
      return newValue;
    }
    
    if (text.length > 2 && !text.contains('/')) {
      final month = text.substring(0, 2);
      final year = text.substring(2);
      return newValue.copyWith(
        text: '$month/$year',
        selection: TextSelection.collapsed(offset: '$month/$year'.length),
      );
    }
    
    return newValue;
  }
}