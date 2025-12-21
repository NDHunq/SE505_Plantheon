class MoneyFormatter {
  static String format(double amount) {
    if (amount.abs() >= 1000000000) {
      double billionAmount = amount / 1000000000;
      // Remove trailing .0 if present
      String formatted = billionAmount
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.0$'), '');
      return '$formatted tỷ';
    } else {
      // Use existing logic: comma separated
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
  }
}
