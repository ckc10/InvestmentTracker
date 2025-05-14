// lib/data/models/transaction.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

enum TransactionType {
  buy,
  sell,
  dividend,
  bonus,
  split,
  rights,
  other
}

@HiveType(typeId: 2)
class Transaction extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String isin;
  
  @HiveField(2)
  final String symbol;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final TransactionType type;
  
  @HiveField(5)
  final int quantity;
  
  @HiveField(6)
  final double price;
  
  @HiveField(7)
  final double value;
  
  @HiveField(8)
  final String broker;
  
  const Transaction({
    required this.id,
    required this.isin,
    required this.symbol,
    required this.date,
    required this.type,
    required this.quantity,
    required this.price,
    required this.value,
    required this.broker,
  });
  
  // Copy with method for immutability
  Transaction copyWith({
    String? id,
    String? isin,
    String? symbol,
    DateTime? date,
    TransactionType? type,
    int? quantity,
    double? price,
    double? value,
    String? broker,
  }) {
    return Transaction(
      id: id ?? this.id,
      isin: isin ?? this.isin,
      symbol: symbol ?? this.symbol,
      date: date ?? this.date,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      value: value ?? this.value,
      broker: broker ?? this.broker,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    isin,
    symbol,
    date,
    type,
    quantity,
    price,
    value,
    broker,
  ];
  
  @override
  String toString() {
    return 'Transaction(id: $id, symbol: $symbol, date: $date, type: $type, quantity: $quantity, price: $price)';
  }
}