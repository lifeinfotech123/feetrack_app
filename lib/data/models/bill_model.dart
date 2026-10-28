class BillModel {
  final String category;
  final String billName;
  final String dueText;
  final double amount;

  const BillModel({
    required this.category,
    required this.billName,
    required this.dueText,
    required this.amount,
  });
}
