// lib/data/models/holding.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'holding.g.dart';

@HiveType(typeId: 1)
class Holding extends Equatable {
  @HiveField(0)
  final String isin;
  
  @HiveField(1)
  final String symbol;
  
  @HiveField(2)
  final String companyName;
  
  @HiveField(3)
  final int quantity;
  
  @HiveField(4)
  final double averagePrice;
  
  @HiveField(5)
  final double currentPrice;
  
  @HiveField(6)
  final String sector;
  
  @HiveField(7)
  final String broker;
  
  const Holding({
    required this.isin,
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.averagePrice,
    this.currentPrice = 0.0,
    required this.sector,
    required this.broker,
  });
  
  // Calculated fields
  double get investedValue => quantity * averagePrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - investedValue;
  double get profitLossPercentage => (investedValue > 0) 
    ? (profitLoss / investedValue) * 100 
    : 0.0;
  
  // Copy with method for immutability
  Holding copyWith({
    String? isin,
    String? symbol,
    String? companyName,
    int? quantity,
    double? averagePrice,
    double? currentPrice,
    String? sector,
    String? broker,
  }) {
    return Holding(
      isin: isin ?? this.isin,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      broker: broker ?? this.broker,
    );
  }
  
  @override
  List<Object?> get props => [
    isin, 
    symbol, 
    companyName, 
    quantity, 
    averagePrice,
    currentPrice,
    sector,
    broker,
  ];
  
  @override
  String toString() {
    return 'Holding(isin: $isin, symbol: $symbol, quantity: $quantity, averagePrice: $averagePrice, currentPrice: $currentPrice)';
  }
}