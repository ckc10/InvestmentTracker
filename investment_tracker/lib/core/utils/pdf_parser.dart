// lib/core/utils/pdf_parser.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf_text/pdf_text.dart';
import '../../data/models/holding.dart';
import '../../data/models/transaction.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class CDSLStatementParser {
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();
  
  // Constants for CDSL statement patterns
  static const String _holdingsHeader = "ISIN";
  static const String _holdingsSectionText = "Holdings Statement";
  static const String _transactionSectionText = "Transaction Statement";
  static const String _accountDetailsText = "DP ID";
  
  /// Parses a CDSL statement PDF file
  /// Returns a map containing holdings and transactions
  Future<Map<String, dynamic>> parseCDSLStatement(Uint8List pdfBytes) async {
    try {
      final PDFDoc document = await PDFDoc.fromData(pdfBytes);
      
      // Extract text from all pages
      final String fullText = await document.text;
      
      // Parse account details
      final Map<String, String> accountDetails = _parseAccountDetails(fullText);
      
      // Parse holdings
      final List<Holding> holdings = await _parseHoldings(document);
      
      // Parse transactions
      final List<Transaction> transactions = await _parseTransactions(document);
      
      return {
        'accountDetails': accountDetails,
        'holdings': holdings,
        'transactions': transactions,
      };
    } catch (e) {
      _logger.e('Error parsing CDSL statement', error: e);
      rethrow;
    }
  }
  
  /// Parses account details section from CDSL statement
  Map<String, String> _parseAccountDetails(String text) {
    final Map<String, String> details = {};
    
    // Extract DP ID
    final RegExp dpIdRegex = RegExp(r'DP ID\s*:\s*([0-9]+)');
    final Match? dpIdMatch = dpIdRegex.firstMatch(text);
    if (dpIdMatch != null && dpIdMatch.groupCount >= 1) {
      details['dpId'] = dpIdMatch.group(1)!;
    }
    
    // Extract Client ID
    final RegExp clientIdRegex = RegExp(r'Client ID\s*:\s*([0-9]+)');
    final Match? clientIdMatch = clientIdRegex.firstMatch(text);
    if (clientIdMatch != null && clientIdMatch.groupCount >= 1) {
      details['clientId'] = clientIdMatch.group(1)!;
    }
    
    // Extract statement period
    final RegExp periodRegex = RegExp(r'Statement Period\s*:\s*([0-9]{2}/[0-9]{2}/[0-9]{4})\s*to\s*([0-9]{2}/[0-9]{2}/[0-9]{4})');
    final Match? periodMatch = periodRegex.firstMatch(text);
    if (periodMatch != null && periodMatch.groupCount >= 2) {
      details['fromDate'] = periodMatch.group(1)!;
      details['toDate'] = periodMatch.group(2)!;
    }
    
    // Extract account holder name
    final RegExp nameRegex = RegExp(r'Name\s*:\s*([^\n\r]+)');
    final Match? nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      details['name'] = nameMatch.group(1)!.trim();
    }
    
    return details;
  }
  
  /// Parses holdings data from CDSL statement
  Future<List<Holding>> _parseHoldings(PDFDoc document) async {
    List<Holding> holdings = [];
    
    try {
      // Find pages with holdings data
      int? holdingsStartPage;
      
      for (int i = 0; i < document.length; i++) {
        final pageText = await document.pageAt(i + 1).text;
        if (pageText.contains(_holdingsSectionText)) {
          holdingsStartPage = i + 1;
          break;
        }
      }
      
      if (holdingsStartPage == null) {
        _logger.w('Holdings section not found in the document');
        return [];
      }
      
      // Extract holdings data
      bool isProcessingHoldings = false;
      
      for (int i = holdingsStartPage - 1; i < document.length; i++) {
        final pageText = await document.pageAt(i + 1).text;
        
        // Check if we reached the end of holdings section
        if (isProcessingHoldings && pageText.contains(_transactionSectionText)) {
          break;
        }
        
        // Check if we're in the holdings section
        if (pageText.contains(_holdingsHeader)) {
          isProcessingHoldings = true;
          
          // Split by lines and process each holding entry
          final lines = pageText.split('\n');
          
          for (int j = 0; j < lines.length; j++) {
            final line = lines[j].trim();
            
            // Check if line contains ISIN (12 characters alphanumeric)
            final RegExp isinRegex = RegExp(r'(IN[A-Z0-9]{10})');
            final Match? isinMatch = isinRegex.firstMatch(line);
            
            if (isinMatch != null) {
              final String isin = isinMatch.group(1)!;
              
              // Extract other details
              String fullLine = line;
              if (j + 1 < lines.length) {
                fullLine += " " + lines[j + 1].trim();
              }
              
              // Parse holding details
              final holding = _parseHoldingLine(fullLine, isin);
              if (holding != null) {
                holdings.add(holding);
              }
            }
          }
        }
      }
      
      return holdings;
    } catch (e) {
      _logger.e('Error parsing holdings', error: e);
      return [];
    }
  }
  
  /// Parses a single holding line from CDSL statement
  Holding? _parseHoldingLine(String line, String isin) {
    try {
      // Example line format: "IN0000000001 COMPANY NAME LTD               100      500.50"
      // Extract company name (between ISIN and quantity)
      final parts = line.split(RegExp(r'\s{2,}'));
      
      if (parts.length < 3) {
        return null;
      }
      
      String companyName = "";
      int quantity = 0;
      double avgPrice = 0.0;
      String broker = "Unknown";
      
      // Find the company name (text between ISIN and numbers)
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].contains(isin)) {
          companyName = parts[i].replaceFirst(isin, "").trim();
          
          // If company name is empty, it might be in the next part
          if (companyName.isEmpty && i + 1 < parts.length) {
            companyName = parts[i + 1].trim();
          }
          
          // Extract quantity (usually a number after company name)
          if (i + 2 < parts.length) {
            quantity = int.tryParse(parts[i + 2].replaceAll(',', '').trim()) ?? 0;
          }
          
          // Extract average price if available
          if (i + 3 < parts.length) {
            avgPrice = double.tryParse(parts[i + 3].replaceAll(',', '').trim()) ?? 0.0;
          }
          
          break;
        }
      }
      
      // Extract broker information if available
      final RegExp brokerRegex = RegExp(r'Broker:\s*([^\n\r]+)');
      final Match? brokerMatch = brokerRegex.firstMatch(line);
      if (brokerMatch != null && brokerMatch.groupCount >= 1) {
        broker = brokerMatch.group(1)!.trim();
      }
      
      // Extract symbol from company name
      String symbol = _extractSymbol(companyName);
      
      // Create holding object
      return Holding(
        isin: isin,
        symbol: symbol,
        companyName: companyName,
        quantity: quantity,
        averagePrice: avgPrice,
        currentPrice: 0.0, // Will be updated with real-time data
        sector: "Unknown", // Will be updated with sector data
        broker: broker,
      );
    } catch (e) {
      _logger.e('Error parsing holding line', error: e);
      return null;
    }
  }
  
  /// Extract stock symbol from company name
  String _extractSymbol(String companyName) {
    // This is a simplistic approach - in a real implementation,
    // you would use a more robust method or a lookup table
    
    // Remove common suffixes
    String processed = companyName
        .replaceAll("LIMITED", "")
        .replaceAll("LTD", "")
        .replaceAll("CORPORATION", "")
        .replaceAll("CORP", "")
        .replaceAll("INDIA", "")
        .trim();
    
    // Take first word or first two words if short
    List<String> words = processed.split(" ");
    if (words.isEmpty) return companyName;
    
    if (words.length == 1 || words[0].length >= 4) {
      return words[0];
    } else {
      return "${words[0]} ${words[1]}";
    }
  }
  
  /// Parses transactions data from CDSL statement
  Future<List<Transaction>> _parseTransactions(PDFDoc document) async {
    List<Transaction> transactions = [];
    
    try {
      // Find pages with transaction data
      int? transactionsStartPage;
      
      for (int i = 0; i < document.length; i++) {
        final pageText = await document.pageAt(i + 1).text;
        if (pageText.contains(_transactionSectionText)) {
          transactionsStartPage = i + 1;
          break;
        }
      }
      
      if (transactionsStartPage == null) {
        _logger.w('Transactions section not found in the document');
        return [];
      }
      
      // Extract transactions data
      bool isProcessingTransactions = false;
      
      for (int i = transactionsStartPage - 1; i < document.length; i++) {
        final pageText = await document.pageAt(i + 1).text;
        
        // Check if we're in the transactions section
        if (pageText.contains("Date") && pageText.contains("ISIN") && pageText.contains("Transaction Type")) {
          isProcessingTransactions = true;
          
          // Split by lines and process each transaction entry
          final lines = pageText.split('\n');
          
          for (int j = 0; j < lines.length; j++) {
            final line = lines[j].trim();
            
            // Process date-based transaction entries
            final RegExp dateRegex = RegExp(r'(\d{2}/\d{2}/\d{4})');
            final Match? dateMatch = dateRegex.firstMatch(line);
            
            if (dateMatch != null) {
              // Extract ISIN if on same line or next line
              String isin = "";
              final RegExp isinRegex = RegExp(r'(IN[A-Z0-9]{10})');
              Match? isinMatch = isinRegex.firstMatch(line);
              
              if (isinMatch == null && j + 1 < lines.length) {
                isinMatch = isinRegex.firstMatch(lines[j + 1]);
              }
              
              if (isinMatch != null) {
                isin = isinMatch.group(1)!;
              }
              
              // Parse full transaction details
              String fullLine = line;
              if (j + 1 < lines.length) {
                fullLine += " " + lines[j + 1].trim();
              }
              
              final transaction = _parseTransactionLine(fullLine, isin);
              if (transaction != null) {
                transactions.add(transaction);
              }
            }
          }
        }
      }
      
      return transactions;
    } catch (e) {
      _logger.e('Error parsing transactions', error: e);
      return [];
    }
  }
  
  /// Parses a single transaction line from CDSL statement
  Transaction? _parseTransactionLine(String line, String isin) {
    try {
      // Example format: "01/04/2023 IN0000000001 COMPANY NAME LTD BUY 100 500.50 50050.00"
      
      // Extract date
      final RegExp dateRegex = RegExp(r'(\d{2}/\d{2}/\d{4})');
      final Match? dateMatch = dateRegex.firstMatch(line);
      if (dateMatch == null) return null;
      
      final String dateStr = dateMatch.group(1)!;
      final List<String> dateParts = dateStr.split('/');
      final DateTime date = DateTime(
        int.parse(dateParts[2]), 
        int.parse(dateParts[1]), 
        int.parse(dateParts[0])
      );
      
      // Split into parts for other fields
      final parts = line.split(RegExp(r'\s{2,}'));
      
      if (parts.length < 6) return null;
      
      String companyName = "";
      String transactionTypeStr = "";
      int quantity = 0;
      double price = 0.0;
      double value = 0.0;
      String broker = "Unknown";
      
      // Extract transaction details
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].contains(isin)) {
          // Company name
          companyName = parts[i].replaceFirst(isin, "").trim();
          
          // If company name is empty, it might be in the next part
          if (companyName.isEmpty && i + 1 < parts.length) {
            companyName = parts[i + 1].trim();
          }
          
          // Transaction type
          if (i + 2 < parts.length) {
            transactionTypeStr = parts[i + 2].trim();
          }
          
          // Quantity
          if (i + 3 < parts.length) {
            quantity = int.tryParse(parts[i + 3].replaceAll(',', '').trim()) ?? 0;
          }
          
          // Price
          if (i + 4 < parts.length) {
            price = double.tryParse(parts[i + 4].replaceAll(',', '').trim()) ?? 0.0;
          }
          
          // Value
          if (i + 5 < parts.length) {
            value = double.tryParse(parts[i + 5].replaceAll(',', '').trim()) ?? 0.0;
          }
          
          break;
        }
      }
      
      // Determine transaction type
      TransactionType type = _parseTransactionType(transactionTypeStr);
      
      // Extract broker information if available
      final RegExp brokerRegex = RegExp(r'Broker:\s*([^\n\r]+)');
      final Match? brokerMatch = brokerRegex.firstMatch(line);
      if (brokerMatch != null && brokerMatch.groupCount >= 1) {
        broker = brokerMatch.group(1)!.trim();
      }
      
      // Extract symbol from company name
      String symbol = _extractSymbol(companyName);
      
      // Create transaction object
      return Transaction(
        id: _uuid.v4(),
        isin: isin,
        symbol: symbol,
        date: date,
        type: type,
        quantity: quantity,
        price: price,
        value: value,
        broker: broker,
      );
    } catch (e) {
      _logger.e('Error parsing transaction line', error: e);
      return null;
    }
  }
  
  /// Parse transaction type string into enum
  TransactionType _parseTransactionType(String typeStr) {
    switch (typeStr.toUpperCase()) {
      case 'BUY':
      case 'PURCHASE':
        return TransactionType.buy;
      case 'SELL':
      case 'SALE':
        return TransactionType.sell;
      case 'DIVIDEND':
        return TransactionType.dividend;
      case 'BONUS':
        return TransactionType.bonus;
      case 'SPLIT':
      case 'STOCK SPLIT':
        return TransactionType.split;
      case 'RIGHTS':
      case 'RIGHTS ISSUE':
        return TransactionType.rights;
      default:
        return TransactionType.other;
    }
  }
}