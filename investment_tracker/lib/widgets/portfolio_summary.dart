// File: lib/widgets/portfolio_summary.dart
import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../utils/formatters.dart';

class PortfolioSummary extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioSummary({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = portfolio.overallGain >= 0;
    final gainColor = isPositive ? Colors.green : Colors.red;
    final gainIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Value',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Last Updated',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(portfolio.currentValue),
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormatter.format(portfolio.lastUpdated),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  'Invested',
                  CurrencyFormatter.format(portfolio.investedValue),
                ),
                _buildInfoItem(
                  context,
                  'Gain/Loss',
                  CurrencyFormatter.format(portfolio.overallGain),
                  color: gainColor,
                  icon: gainIcon,
                ),
                _buildInfoItem(
                  context,
                  'Return',
                  '${portfolio.overallGainPercentage.toStringAsFixed(2)}%',
                  color: gainColor,
                  icon: gainIcon,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  'Brokers',
                  _getBrokerCount(),
                ),
                _buildInfoItem(
                  context,
                  'Holdings',
                  portfolio.holdings.length.toString(),
                ),
                _buildInfoItem(
                  context,
                  'Sectors',
                  portfolio.sectorAllocation.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    IconData? icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                SizedBox(width: 4),
              ],
              Text(
                value,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBrokerCount() {
    final Set<String> brokers = {};
    for (final holding in portfolio.holdings) {
      brokers.add(holding.broker);
    }
    return brokers.length.toString();
  }
}