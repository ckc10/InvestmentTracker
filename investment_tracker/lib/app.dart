// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'logic/blocs/portfolio_bloc/portfolio_bloc.dart';
import 'logic/blocs/market_bloc/market_bloc.dart';
import 'logic/di/service_locator.dart';

class InvestmentTrackerApp extends StatelessWidget {
  const InvestmentTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PortfolioBloc>(
          create: (context) => getIt<PortfolioBloc>()..add(FetchPortfolio()),
        ),
        BlocProvider<MarketBloc>(
          create: (context) => getIt<MarketBloc>()..add(FetchMarketData()),
        ),
      ],
      child: MaterialApp(
        title: 'Investment Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}