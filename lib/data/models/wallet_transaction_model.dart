import 'package:flutter/material.dart';

class WalletTransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  const WalletTransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });
}
