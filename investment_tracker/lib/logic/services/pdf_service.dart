// lib/logic/services/pdf_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/pdf_parser.dart';
import '../../data/models/holding.dart';
import '../../data/models/portfolio.dart';
import '../../data/models/transaction.dart';

abstract class PdfService {
  Future<Portfolio> processCDSLStatement(Uint8List pdfBytes, String portfolioName);
}

class PdfServiceImpl implements PdfService {
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();
  final CDSLStatementParser _parser = CDSLStatementParser();
  
  @override
  Future<Portfolio> processCDSLStatement(Uint8List pdfBytes, String portfolioName) async {
    try {
      // Parse the CDSL statement
      final Map<String, dynamic> parsedData = await _parser.parseCDSLStatement(pdfBytes);
      
      // Extract data
      final Map<String, String> accountDetails = parsedData['accountDetails'] as Map<String, String>;
      final List<Holding> holdings = parsedData['holdings'] as List<Holding>;
      final List<Transaction> transactions = parsedData['transactions'] as List<Transaction>;
      
      _logger.i('Parsed CDSL statement: ${holdings.length} holdings, ${transactions.length} transactions');
      
      // Create a portfolio
      final portfolio = Portfolio(
        id: _uuid.v4(),
        name: portfolioName.isNotEmpty ? portfolioName : 'Portfolio ${DateTime.now().toString().substring(0, 10)}',
        holdings: holdings,
        lastUpdated: DateTime.now(),
      );
      
      return portfolio;
    } catch (e) {
      _logger.e('Error processing CDSL statement', error: e);
      rethrow;
    }
  }
  
  // Helper method to enrich holdings with sector data
  Future<List<Holding>> _enrichHoldingsWithSectorData(List<Holding> holdings) async {
    // In a real implementation, you would fetch sector data from an API or database
    // For now, we'll use a dummy implementation
    
    // Sample sector mapping
    const Map<String, String> sectorMap = {
      'HDFC': 'Banking',
      'ICICI': 'Banking',
      'TCS': 'IT',
      'INFOSYS': 'IT',
      'WIPRO': 'IT',
      'RELIANCE': 'Oil & Gas',
      'ONGC': 'Oil & Gas',
      'SUN': 'Pharma',
      'CIPLA': 'Pharma',
    };
    
    return holdings.map((holding) {
      // Try to find sector based on company name
      String sector = 'Other';
      
      for (final entry in sectorMap.entries) {
        if (holding.companyName.toUpperCase().contains(entry.key)) {
          sector = entry.value;
          break;
        }
      }
      
      return holding.copyWith(sector: sector);
    }).toList();
  }
}