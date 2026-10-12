import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyUtils {
  static String formatINR(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currencySymbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }
}
