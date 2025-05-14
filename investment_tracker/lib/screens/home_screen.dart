// File: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pdf_service.dart';
import '../services/market_data_service.dart';
import '../models/portfolio.dart';
import '../widgets/portfolio_summary.dart';
import '../widgets/sector_chart.dart';
import '../widgets/holdings_list.dart';
import 'import_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Portfolio? _portfolio;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For development, use mock data
      final pdfService = Provider.of<PdfService>(context, listen: false);
      final portfolio = await pdfService.getMockPortfolio();
      
      // Update portfolio with current market prices
      final marketDataService = Provider.of<MarketDataService>(context, listen: false);
      await marketDataService.updatePortfolioPrices(portfolio);
      
      setState(() {
        _portfolio = portfolio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load portfolio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPortfolio,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _portfolio == null
          ? _buildEmptyState()
          : _buildDashboard(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImportScreen()),
          ).then((_) => _loadPortfolio());
        },
        child: Icon(Icons.file_upload),
        tooltip: 'Import Statement',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Portfolio Data',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 8),
          Text(
            'Import your CDSL statement to get started',
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.file_upload),
            label: Text('Import Statement'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImportScreen()),
              ).then((_) => _loadPortfolio());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadPortfolio,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortfolioSummary(portfolio: _portfolio!),
            SizedBox(height: 24),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sector Allocation',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: SectorChart(portfolio: _portfolio!),
                    ),
                    if (_portfolio!.overallocatedSectors.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Possible sector overallocation',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalysisScreen(portfolio: _portfolio!),
                            ),
                          );
                        },
                        child: Text('View Analysis'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            Text(
              'Your Holdings',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 16),
            HoldingsList(holdings: _portfolio!.holdings),
          ],
        ),
      ),
    );
  }
}