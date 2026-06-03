import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/api_service.dart';
import '../services/cart_service.dart';
import '../../../common_widgets/feedback/custom_feedback.dart';
import '../../../core/constants/app_colors.dart';
import '../../payment/widgets/payment_sheet.dart';
import '../../profile/services/order_history_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_updateState);
  }

  @override
  void dispose() {
    _cartService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final items = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: items.isEmpty
          ? Column(
              children: [
                _buildHeader(topPadding),
                Expanded(child: _buildEmptyState()),
              ],
            )
          : Column(
              children: [
                _buildHeader(topPadding),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Cart Items List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _buildCartItem(items[index]);
                            },
                          ),

                          const SizedBox(height: 24),

                          // 2. Order summary card
                          _buildSummaryCard(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Bottom Order Checkout Action Button
                _buildCheckoutBar(),
              ],
            ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: topPadding + 80,
          decoration: const BoxDecoration(
            color: Color(0xFF131313),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: topPadding + 12.0),
          child: SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          UIcons.regularRounded.angle_left,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'SEPETİM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                UIcons.regularRounded.shopping_cart,
                size: 48,
                color: const Color(0xFF7B8085),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sepetiniz Boş',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sepetinizde henüz ürün bulunmuyor. Market sayfasına giderek ürün ekleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Alışverişe Başla',
                  style: TextStyle(
                    color: Color(0xFFA3CB24),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                item.product['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF1F3F5),
                  child: Center(
                    child: Icon(
                      UIcons.regularRounded.picture,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Product Info text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product['name'] as String,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Boyut: ${item.size}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.product['price'] as String,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Quantity adjustment buttons & Trash delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  UIcons.regularRounded.trash,
                  color: Colors.red[400],
                  size: 16,
                ),
                onPressed: () => _cartService.removeItem(item),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _cartService.decrementQuantity(item),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          '—',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _cartService.incrementQuantity(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Icon(
                          UIcons.regularRounded.plus,
                          size: 10,
                          color: AppColors.textDark,
                        ),
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sipariş Özeti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Ara Toplam', '${_cartService.subtotal.toStringAsFixed(0)} TL'),
          const SizedBox(height: 10),
          _buildSummaryRow('Kargo Ücreti', _cartService.deliveryFee == 0 ? 'Ücretsiz' : '${_cartService.deliveryFee.toStringAsFixed(0)} TL'),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Tutar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${_cartService.total.toStringAsFixed(0)} TL',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFA3CB24), // Lime Green
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    final total = _cartService.total.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () async {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final hasAddress = await _checkAndPromptAddress(context, isDark);
            if (!hasAddress) return;

            if (!mounted) return;
            showPaymentSheet(
              context: context,
              title: 'Ödeme Yap',
              subtitle: 'Toplam tutar: $total TL — Güvenli ödeme.',
              confirmLabel: 'Siparişi Tamamla  ($total TL)',
              primaryColor: const Color(0xFFA3CB24),
              onConfirm: () async {
                // Save order history before clearing cart
                final cartItems = _cartService.items.map((item) => {
                  'name': item.product['name'],
                  'image': item.product['image'],
                  'price': item.product['price'],
                  'size': item.size,
                  'quantity': item.quantity,
                }).toList();
                await OrderHistoryService().addOrder(cartItems);
                _cartService.clear();
                if (!mounted) return;
                CustomFeedback.show(
                  context, // ignore: use_build_context_synchronously
                  'Siparişiniz başarıyla oluşturuldu! Alpamys\'i seçtiğiniz için teşekkürler.',
                  type: FeedbackType.success,
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFFA3CB24), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Ödemeye Geç — $total TL',
                    style: const TextStyle(
                      color: Color(0xFFA3CB24),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getUserPrefix() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return 'user_${user.uid}_';
        }
      }
    } catch (_) {}
    return 'user_anonymous_';
  }

  Future<bool> _checkAndPromptAddress(BuildContext context, bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = _getUserPrefix();
      final String key = '${prefix}user_addresses';
      final List<String> currentAddresses = prefs.getStringList(key) ?? [];

      if (currentAddresses.isNotEmpty) {
        return true;
      }
    } catch (e) {
      debugPrint('Error checking local address: $e');
    }

    // No address found, show bottom sheet slider to add one
    if (!context.mounted) return false;
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddressInputSlider(isDark: isDark);
      },
    );

    return result ?? false;
  }
}

class _AddressInputSlider extends StatefulWidget {
  final bool isDark;
  const _AddressInputSlider({required this.isDark});

  @override
  State<_AddressInputSlider> createState() => _AddressInputSliderState();
}

class _AddressInputSliderState extends State<_AddressInputSlider> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  String _getUserPrefix() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return 'user_${user.uid}_';
        }
      }
    } catch (_) {}
    return 'user_anonymous_';
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final city = _cityController.text.trim();
      final addressText = _addressController.text.trim();
      final postal = _postalCodeController.text.trim();
      
      final String fullFormattedAddress = '$title||$city||$addressText||$postal';

      // 1. Save to SharedPreferences for local lists
      final prefs = await SharedPreferences.getInstance();
      final prefix = _getUserPrefix();
      final String key = '${prefix}user_addresses';
      final List<String> currentAddresses = prefs.getStringList(key) ?? [];
      currentAddresses.add(fullFormattedAddress);
      await prefs.setStringList(key, currentAddresses);

      // 2. Save to Remote Database
      await ApiService.updateAddress(fullFormattedAddress);

      if (mounted) {
        CustomFeedback.show(context, 'Adres başarıyla kaydedildi!', type: FeedbackType.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomFeedback.show(context, 'Adres kaydedilemedi: $e', type: FeedbackType.warning);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey : Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131313) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'TESLİMAT ADRESİ EKLEYİN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Siparişi tamamlamak için teslimat adresinizi girmelisiniz.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _titleController,
                  label: 'Adres Başlığı',
                  hint: 'Örn: Ev, İş, Okul',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Lütfen bir başlık girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _cityController,
                  label: 'Şehir / İlçe',
                  hint: 'Örn: Almatı, Medeu',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Lütfen şehir/ilçe girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _addressController,
                  label: 'Tam Adres',
                  hint: 'Sokak, mahalle, bina ve daire numarası',
                  maxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Lütfen tam adresinizi girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _postalCodeController,
                  label: 'Posta Kodu (İsteğe Bağlı)',
                  hint: 'Örn: 050000',
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'ADRESİ KAYDET VE DEVAM ET',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.8,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
