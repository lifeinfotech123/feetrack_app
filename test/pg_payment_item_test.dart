import 'package:flutter_test/flutter_test.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/constants.dart';

void main() {
  test('PG customer payments endpoint uses plural payments route', () {
    expect(AppConstants.pgCustomerPayments, 'v1/pg/customer/payments');
  });

  test('parses PG customer payment transaction fields', () {
    final payment = PgPaymentItem.fromJson({
      'id': '0f3ccb10-7a1e-4b31-9426-46a282d67140',
      'booking_id': '979a4081-26f9-45e7-a063-05a4ce95714b',
      'domain': 'ankitpg',
      'domain_name': 'Ankit PG',
      'website_id': 13,
      'gateway': 'razorpay',
      'gateway_ref': 'PAY_EG96FEARJLDC',
      'amount': 10000,
      'formatted_amount': '₹10,000',
      'status': 'paid',
      'paid_at': '2026-10-23 11:16:56',
      'formatted_date': '23 Oct 2026, 11:16 AM',
    });

    expect(payment.bookingId, '979a4081-26f9-45e7-a063-05a4ce95714b');
    expect(payment.domain, 'ankitpg');
    expect(payment.domainName, 'Ankit PG');
    expect(payment.websiteId, 13);
    expect(payment.gatewayRef, 'PAY_EG96FEARJLDC');
    expect(payment.amount, 10000);
    expect(payment.formattedAmount, '₹10,000');
    expect(payment.formattedDate, '23 Oct 2026, 11:16 AM');
  });

  test('parses wallet balance and only API-provided transactions', () {
    final wallet = PgCustomerWalletModel.fromJson({
      'balance': 1000,
      'formatted_balance': '₹1,000.00',
      'currency': 'INR',
      'currency_symbol': '₹',
      'total_transactions': 1,
      'transactions': [
        {
          'id': 'b096597f-8487-43fa-9130-54cf1d1fbe49',
          'type': 'credit',
          'amount': 1000,
          'formatted_amount': '+₹1,000.00',
          'description': 'Wallet recharge',
          'reference_type': 'wallet_recharge',
          'reference_id': 'WAL_ORDER_VAHZRVMZ6J',
          'created_at': '2026-10-16 13:16:27',
          'formatted_date': '16 Oct 2026, 01:16 PM',
        },
      ],
    });

    expect(wallet.formattedBalance, '₹1,000.00');
    expect(wallet.totalTransactions, 1);
    expect(wallet.transactions, hasLength(1));
    expect(wallet.transactions.single.formattedAmount, '+₹1,000.00');
    expect(wallet.transactions.single.description, 'Wallet recharge');
    expect(wallet.transactions.single.referenceId, 'WAL_ORDER_VAHZRVMZ6J');
  });

  test('does not invent a balance when wallet response omits it', () {
    final wallet = PgCustomerWalletModel.fromJson({});

    expect(wallet.formattedBalance, isNull);
    expect(wallet.transactions, isEmpty);
  });
}
