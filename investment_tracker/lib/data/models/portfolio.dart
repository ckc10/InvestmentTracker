// lib/data/models/portfolio.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'holding.dart';

part 'portfolio.g.dart';

@HiveType(typeId: 0)
class Portfolio extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final List<Holding> holdings;
  
  @HiveField(3)
  final DateTime lastUpdated;
  
  const Portfolio({
    required this.id,
    required this.name,
    required this.holdings,
    required this.lastUpdated,
  });
  
  // Calculated fields
  double get totalInvestedValue => holdings.fold(
    0, (sum, holding) => sum + holding.investedValue
  );
  
  double get totalCurrentValue => holdings.fold(
    0, (sum, holding) => sum + holding.currentValue
  );
  
  double get totalProfitLoss => totalCurrentValue - totalInvestedValue;
  
  double get totalProfitLossPercentage => (totalInvestedValue > 0)
    ? (totalProfitLoss / totalInvestedValue) * 100
    : 0.0;
  
  // Get unique brokers
  List<String> get brokers => holdings
    .map((holding) => holding.broker)
    .toSet()
    .toList();
  
  // Get unique sectors
  List<String> get sectors => holdings
    .map((holding) => holding.sector)
    .toSet()
    .toList();
  
  // Get sector allocation
  Map<String, double> get sectorAllocation {
    final Map<String, double> allocation = {};
    
    for (final sector in sectors) {
      final sectorHoldings = holdings.where((h) => h.sector == sector).toList();
      final sectorValue = sectorHoldings.fold(
        0.0, (sum, holding) => sum + holding.currentValue
      );
      
      allocation[sector] = sectorValue / totalCurrentValue * 100;
    }
    
    return allocation;
  }
  
  // Get broker allocation
  Map<String, double> get brokerAllocation {
    final Map<String, double> allocation = {};
    
    for (final broker in brokers) {
      final brokerHoldings = holdings.where((h) => h.broker == broker).toList();
      final brokerValue = brokerHoldings.fold(
        0.0, (sum, holding) => sum + holding.currentValue
      );
      
      allocation[broker] = brokerValue / totalCurrentValue * 100;
    }
    
    return allocation;
  }
  
  // Copy with method for immutability
  Portfolio copyWith({
    String? id,
    String? name,
    List<Holding>? holdings,
    DateTime? lastUpdated,
  }) {
    return Portfolio(
      id: id ?? this.id,
      name: name ?? this.name,
      holdings: holdings ?? this.holdings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  List<Object?> get props => [id, name, holdings, lastUpdated];
  
  @override
  String toString() {
    return 'Portfolio(id: $id, name: $name, holdings: ${holdings.length}, lastUpdated: $lastUpdated)';
  }
}