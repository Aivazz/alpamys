import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/card_service.dart';

/// A reusable payment bottom sheet that:
/// - Shows saved card details if a card is stored, with option to use it or change it.
/// - Shows a real input form (card number, name, expiry, CVC) if no card is saved.
/// - Optionally saves the card for future use.
///
/// [title]        — e.g. "Ödeme Yap"
/// [subtitle]     — e.g. "3 Aylık Paket — 3.270 TL ödeme alınacak."
/// [confirmLabel] — e.g. "Ödemeyi Tamamla"
/// [primaryColor] — accent color for button/card border
/// [onConfirm]    — called after successful "pay" tap
void showPaymentSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  String confirmLabel = 'Ödemeyi Tamamla',
  Color primaryColor = const Color(0xFFA3CB24),
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PaymentSheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      primaryColor: primaryColor,
      onConfirm: onConfirm,
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;
  final Color primaryColor;
  final VoidCallback onConfirm;

  const _PaymentSheet({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.primaryColor,
    required this.onConfirm,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _cardService = CardService();

  // form state
  bool _showForm = false;
  bool _saveCard = true;

  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cardService.loadCard().then((_) {
      if (mounted) setState(() {});
    });
    _showForm = !_cardService.hasCard;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  bool get _formValid {
    final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 16 &&
        _nameCtrl.text.trim().length >= 3 &&
        RegExp(r'^\d{2}/\d{2}$').hasMatch(_expiryCtrl.text.trim()) &&
        _cvcCtrl.text.trim().length >= 3;
  }

  void _handleConfirm() async {
    if (_showForm) {
      if (!_formValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen kart bilgilerini eksiksiz girin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_saveCard) {
        final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
        await _cardService.saveCard(
          last4: digits.substring(digits.length - 4),
          cardholderName: _nameCtrl.text.trim().toUpperCase(),
          expiry: _expiryCtrl.text.trim(),
        );
      }
    }
    if (mounted) Navigator.pop(context);
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final saved = _cardService.savedCard;
    final hasSaved = saved != null && !_showForm;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 48, height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // title
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w900, letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 24),

            if (hasSaved) ...[
              // ── Saved card view ──────────────────────────────────────
              _SavedCardWidget(card: saved, primaryColor: widget.primaryColor),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _showForm = true),
                child: Row(
                  children: [
                    Icon(Icons.credit_card_outlined,
                        color: Colors.grey.shade400, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Farklı kart kullan',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── Card input form ──────────────────────────────────────
              if (_cardService.hasCard) ...[
                GestureDetector(
                  onTap: () => setState(() => _showForm = false),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.grey.shade400, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        'Kayıtlı kartı kullan',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _CardInputForm(
                numberCtrl: _numberCtrl,
                nameCtrl: _nameCtrl,
                expiryCtrl: _expiryCtrl,
                cvcCtrl: _cvcCtrl,
                primaryColor: widget.primaryColor,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              // Save card checkbox
              GestureDetector(
                onTap: () => setState(() => _saveCard = !_saveCard),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: _saveCard
                            ? widget.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _saveCard
                              ? widget.primaryColor
                              : Colors.white30,
                          width: 1.5,
                        ),
                      ),
                      child: _saveCard
                          ? const Icon(Icons.check_rounded,
                              color: Colors.black, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Kartı sonraki ödemeler için kaydet',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Confirm button ───────────────────────────────────────
            GestureDetector(
              onTap: _handleConfirm,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.confirmLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Saved card display widget ─────────────────────────────────────────────────
class _SavedCardWidget extends StatelessWidget {
  final SavedCard card;
  final Color primaryColor;
  const _SavedCardWidget({required this.card, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF161616)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KAYITLI KART',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.credit_card_rounded, color: primaryColor, size: 22),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            card.maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KART SAHİBİ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.cardholderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card input form ───────────────────────────────────────────────────────────
class _CardInputForm extends StatelessWidget {
  final TextEditingController numberCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvcCtrl;
  final Color primaryColor;
  final VoidCallback onChanged;

  const _CardInputForm({
    required this.numberCtrl,
    required this.nameCtrl,
    required this.expiryCtrl,
    required this.cvcCtrl,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          label: 'Kart Numarası',
          controller: numberCtrl,
          hint: '•••• •••• •••• ••••',
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
        _field(
          label: 'Kart Sahibi',
          controller: nameCtrl,
          hint: 'AD SOYAD',
          keyboardType: TextInputType.name,
          formatters: [UpperCaseTextFormatter()],
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _field(
                label: 'Son Kullanma',
                controller: expiryCtrl,
                hint: 'AA/YY',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _field(
                label: 'CVC / CVV',
                controller: cvcCtrl,
                hint: '•••',
                keyboardType: TextInputType.number,
                obscureText: true,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> formatters = const [],
    bool obscureText = false,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            obscureText: obscureText,
            onChanged: (_) => onChanged(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Text formatters ───────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
