// lib/data/repositories/market_data_repository.dart

import 'package:logger/logger.dart';
import '../datasources/remote/market_api.dart';

abstract class MarketDataRepository {
  Future<Map<String, double>> getStockPrices(List<String> symbols);
  Future<Map<String, String>> getStockSectors(List<String> symbols);
  Future<Map<String, dynamic>> getMarketIndices();
}

class MarketDataRepositoryImpl implements MarketDataRepository {
  final MarketApi _marketApi;
  final Logger _logger = Logger();
  
  MarketDataRepositoryImpl(this._marketApi);
  
  @override
  Future<Map<String, double>> getStockPrices(List<String> symbols) async {
    try {
      return await _marketApi.fetchStockPrices(symbols);
    } catch (e) {
      _logger.e('Error getting stock prices', error: e);
      // Return empty map in case of error
      return {};
    }
  }
  
  @override
  Future<Map<String, String>> getStockSectors(List<String> symbols) async {
    try {
      return await _marketApi.fetchStockSectors(symbols);
    } catch (e) {
      _logger.e('Error getting stock sectors', error: e);
      // Return empty map in case of error
      return {};
    }
  }
  
  @override
  Future<Map<String, dynamic>> getMarketIndices() async {
    try {
      return await _marketApi.fetchMarketIndices();
    } catch (e) {
      _logger.e('Error getting market indices', error: e);
      // Return empty map in case of error
      return {};
    }
  }
}