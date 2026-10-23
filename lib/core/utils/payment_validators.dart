import 'package:flutter/services.dart';

class PaymentValidators {
  /// Luhn Algorithm for Genuine Card Checksum Validation
  static bool validateLuhn(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.isEmpty || !RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return false;
    }

    int sum = 0;
    bool isSecondDigit = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (isSecondDigit) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isSecondDigit = !isSecondDigit;
    }

    return (sum % 10 == 0);
  }

  /// Detects Card Brand (Visa, Mastercard, RuPay, Amex, Discover)
  static String detectCardNetwork(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (clean.startsWith(RegExp(r'^4'))) {
      return 'Visa';
    } else if (clean.startsWith(RegExp(r'^(5[1-5]|2[2-7])'))) {
      return 'Mastercard';
    } else if (clean.startsWith(RegExp(r'^(60|65|508|353)'))) {
      return 'RuPay';
    } else if (clean.startsWith(RegExp(r'^3[47]'))) {
      return 'Amex';
    } else if (clean.startsWith(RegExp(r'^6(?:011|5)'))) {
      return 'Discover';
    }
    return 'Card';
  }

  /// Validates Credit/Debit Card Number
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }

    final cleanNumber = value.replaceAll(RegExp(r'\s+'), '');

    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Enter a valid 16-digit card number';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Card number must contain digits only';
    }

    if (!validateLuhn(cleanNumber)) {
      return 'Invalid card number (Luhn checksum failed)';
    }

    return null;
  }

  /// Validates Expiry Date (MM/YY)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date required (MM/YY)';
    }

    final clean = value.trim();
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(clean)) {
      return 'Enter date in MM/YY format (e.g. 12/28)';
    }

    final parts = clean.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    if (year > currentYear + 25) {
      return 'Invalid expiry year';
    }

    return null;
  }

  /// Validates CVV / CVC
  static String? validateCVV(String? value, {bool isAmex = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV required';
    }

    final clean = value.trim();
    final expectedLength = isAmex ? 4 : 3;

    if (clean.length != expectedLength || !RegExp(r'^\d+$').hasMatch(clean)) {
      return 'CVV must be $expectedLength digits';
    }

    return null;
  }

  /// Validates Cardholder Name
  static String? validateCardHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cardholder name is required';
    }

    final clean = value.trim();
    if (clean.length < 3) {
      return 'Enter full name as printed on card';
    }

    if (!RegExp(r"^[a-zA-Z\s.'\-]+$").hasMatch(clean)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validates UPI VPA ID (e.g. username@okaxis, mobile@ybl)
  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI VPA ID is required';
    }

    final clean = value.trim();
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

    if (!upiRegex.hasMatch(clean)) {
      return 'Enter valid UPI ID (e.g., user@okaxis or mobile@paytm)';
    }

    return null;
  }

  /// Validates 10-digit Indian Mobile Phone Number
  static String? validateIndianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number required';
    }

    final clean = value.replaceAll(RegExp(r'[\s\-+]'), '');
    final numberOnly = clean.length > 10 ? clean.substring(clean.length - 10) : clean;

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(numberOnly)) {
      return 'Enter valid 10-digit Indian mobile number';
    }

    return null;
  }

  /// Validates Indian Postal PIN Code
  static String? validateIndianPincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN Code is required';
    }

    final clean = value.trim();
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(clean)) {
      return 'Enter valid 6-digit Indian PIN Code';
    }

    return null;
  }
}

/// Auto Formatter for Card Numbers: "XXXX XXXX XXXX XXXX"
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonIndex = i + 1;
      if (nonIndex % 4 == 0 && nonIndex != text.length && nonIndex < 16) {
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

/// Auto Formatter for Card Expiry Date: "MM/YY"
class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.length > 4) {
      newText = newText.substring(0, 4);
    }

    var formatted = '';
    if (newText.length >= 2) {
      var month = int.tryParse(newText.substring(0, 2)) ?? 0;
      if (month > 12) {
        newText = '12${newText.substring(2)}';
      } else if (month == 0) {
        newText = '01${newText.substring(2)}';
      }

      formatted = '${newText.substring(0, 2)}/${newText.substring(2)}';
    } else {
      formatted = newText;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
