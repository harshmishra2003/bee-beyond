import 'package:flutter/material.dart';
import '../../../../core/utils/currency_utils.dart';

class PriceSummaryCard extends StatefulWidget {
  final double subtotal;
  final double discount;
  final double shippingFee;
  final Function(double total, double discountApplied)? onSummaryCalculated;

  const PriceSummaryCard({
    super.key,
    required this.subtotal,
    this.discount = 0.0,
    this.shippingFee = 0.0,
    this.onSummaryCalculated,
  });

  @override
  State<PriceSummaryCard> createState() => _PriceSummaryCardState();
}

class _PriceSummaryCardState extends State<PriceSummaryCard> {
  final _couponController = TextEditingController();
  double _appliedDiscount = 0.0;
  String _appliedCode = '';
  bool _couponApplied = false;

  final List<Map<String, String>> _availableCoupons = const [
    {'code': 'BEEBEYONND10', 'desc': '10% OFF'},
    {'code': 'HOLISTIC20', 'desc': '20% OFF'},
    {'code': 'WELLNESS500', 'desc': '₹500 OFF'},
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCouponCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    FocusScope.of(context).unfocus();

    if (cleanCode == 'BEEBEYONND10' || cleanCode == 'BEEBEEYOND10') {
      setState(() {
        _appliedDiscount = widget.subtotal * 0.10;
        _couponApplied = true;
        _appliedCode = 'BEEBEYONND10';
        _couponController.text = 'BEEBEYONND10';
      });
      _showSnack('Promo code "BEEBEYONND10" applied! 10% discount added.', isSuccess: true);
    } else if (cleanCode == 'HOLISTIC20') {
      setState(() {
        _appliedDiscount = widget.subtotal * 0.20;
        _couponApplied = true;
        _appliedCode = cleanCode;
        _couponController.text = cleanCode;
      });
      _showSnack('Promo code "HOLISTIC20" applied! 20% discount added.', isSuccess: true);
    } else if (cleanCode == 'WELLNESS500') {
      setState(() {
        _appliedDiscount = 500.0;
        _couponApplied = true;
        _appliedCode = cleanCode;
        _couponController.text = cleanCode;
      });
      _showSnack('Promo code "WELLNESS500" applied! ₹500 discount added.', isSuccess: true);
    } else {
      _showSnack('Invalid coupon code. Try "BEEBEYONND10" or "HOLISTIC20"', isSuccess: false);
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedDiscount = 0.0;
      _couponApplied = false;
      _appliedCode = '';
      _couponController.clear();
    });
    _showSnack('Coupon removed.', isSuccess: false);
  }

  void _showSnack(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDiscount = widget.discount + _appliedDiscount;
    final estimatedTaxes = widget.subtotal * 0.03; // 3% GST/Tax
    final total = (widget.subtotal - totalDiscount + widget.shippingFee + estimatedTaxes)
        .clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.confirmation_number_outlined, color: Color(0xFF312E81), size: 20),
              SizedBox(width: 8),
              Text(
                'Apply Promo Coupons',
                style: TextStyle(
                  color: Color(0xFF1E1B4B),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Coupon Code Input Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  ),
                  child: TextField(
                    controller: _couponController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Enter Promo Code',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _couponApplied ? const Color(0xFF10B981) : const Color(0xFF312E81),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: () {
                  if (_couponApplied) {
                    _removeCoupon();
                  } else {
                    _applyCouponCode(_couponController.text);
                  }
                },
                child: Text(
                  _couponApplied ? 'Remove' : 'Apply',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Available Coupon Chips Row
          if (!_couponApplied) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _availableCoupons.map((c) {
                  final code = c['code']!;
                  final desc = c['desc']!;
                  return GestureDetector(
                    onTap: () => _applyCouponCode(code),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_rounded, size: 12, color: Color(0xFF4338CA)),
                          const SizedBox(width: 4),
                          Text(
                            '$code ($desc)',
                            style: const TextStyle(
                              color: Color(0xFF312E81),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            // Applied Coupon Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Coupon "$_appliedCode" Applied Successfully!',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 28, color: Color(0xFFE2E8F0)),

          // Order Summary Title
          const Text(
            'Order Price Summary',
            style: TextStyle(
              color: Color(0xFF1E1B4B),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items Subtotal', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              Text(
                CurrencyUtils.formatINR(widget.subtotal),
                style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Shipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Express Delivery', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              Text(
                widget.shippingFee == 0 ? 'FREE' : CurrencyUtils.formatINR(widget.shippingFee),
                style: TextStyle(
                  color: widget.shippingFee == 0 ? const Color(0xFF059669) : const Color(0xFF1E1B4B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // GST & Taxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Taxes & GST (3%)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              Text(
                CurrencyUtils.formatINR(estimatedTaxes),
                style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          if (totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Promo Discount Savings', style: TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  '- ${CurrencyUtils.formatINR(totalDiscount)}',
                  style: const TextStyle(color: Color(0xFF059669), fontSize: 13.5, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],

          const Divider(height: 28, color: Color(0xFFE2E8F0)),

          // Total Payable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable',
                    style: TextStyle(
                      color: Color(0xFF1E1B4B),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Inclusive of all taxes',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyUtils.formatINR(total),
                style: const TextStyle(
                  color: Color(0xFF312E81),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trust Badges Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TrustTag(icon: Icons.lock_outline_rounded, label: '100% Secure'),
                _TrustTag(icon: Icons.flash_on_rounded, label: 'Instant Access'),
                _TrustTag(icon: Icons.verified_user_outlined, label: 'Guaranteed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
