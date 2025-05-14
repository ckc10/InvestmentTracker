// lib/data/repositories/portfolio_repository.dart

import 'package:logger/logger.dart';
import '../models/portfolio.dart';
import '../models/holding.dart';
import '../datasources/local/database.dart';

abstract class PortfolioRepository {
  Future<List<Portfolio>> getAllPortfolios();
  Future<Portfolio?> getPortfolio(String id);
  Future<bool> savePortfolio(Portfolio portfolio);
  Future<bool> deletePortfolio(String id);
  Future<bool> updateHolding(String portfolioId, Holding holding);
  Future<bool> updateHoldingsMarketPrices(String portfolioId, Map<String, double> prices);
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  final LocalDatabase _localDb;
  final Logger _logger = Logger();
  
  PortfolioRepositoryImpl(this._localDb);
  
  @override
  Future<List<Portfolio>> getAllPortfolios() async {
    try {
      return await _localDb.getPortfolios();
    } catch (e) {
      _logger.e('Error getting portfolios', error: e);
      return [];
    }
  }
  
  @override
  Future<Portfolio?> getPortfolio(String id) async {
    try {
      return await _localDb.getPortfolio(id);
    } catch (e) {
      _logger.e('Error getting portfolio: $id', error: e);
      return null;
    }
  }
  
  @override
  Future<bool> savePortfolio(Portfolio portfolio) async {
    try {
      await _localDb.savePortfolio(portfolio);
      return true;
    } catch (e) {
      _logger.e('Error saving portfolio', error: e);
      return false;
    }
  }
  
  @override
  Future<bool> deletePortfolio(String id) async {
    try {
      await _localDb.deletePortfolio(id);
      return true;
    } catch (e) {
      _logger.e('Error deleting portfolio: $id', error: e);
      return false;
    }
  }
  
  @override
  Future<bool> updateHolding(String portfolioId, Holding holding) async {
    try {
      final portfolio = await getPortfolio(portfolioId);
      if (portfolio == null) return false;
      
      // Find and update the holding
      final holdings = List<Holding>.from(portfolio.holdings);
      final index = holdings.indexWhere((h) => h.isin == holding.isin);
      
      if (index >= 0) {
        holdings[index] = holding;
      } else {
        holdings.add(holding);
      }
      
      // Save updated portfolio
      final updatedPortfolio = portfolio.copyWith(
        holdings: holdings,
        lastUpdated: DateTime.now(),
      );
      
      return await savePortfolio(updatedPortfolio);
    } catch (e) {
      _logger.e('Error updating holding', error: e);
      return false;
    }
  }
  
  @override
  Future<bool> updateHoldingsMarketPrices(String portfolioId, Map<String, double> prices) async {
    try {
      final portfolio = await getPortfolio(portfolioId);
      if (portfolio == null) return false;
      
      // Update market prices for all holdings
      final updatedHoldings = portfolio.holdings.map((holding) {
        final symbol = holding.symbol;
        if (prices.containsKey(symbol)) {
          return holding.copyWith(currentPrice: prices[symbol]);
        }
        return holding;
      }).toList();
      
      // Save updated portfolio
      final updatedPortfolio = portfolio.copyWith(
        holdings: updatedHoldings,
        lastUpdated: DateTime.now(),
      );
      
      return await savePortfolio(updatedPortfolio);
    } catch (e) {
      _logger.e('Error updating market prices', error: e);
      return false;
    }
  }
}