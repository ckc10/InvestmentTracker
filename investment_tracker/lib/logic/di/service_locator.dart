// lib/logic/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/portfolio_repository.dart';
import '../../data/repositories/market_data_repository.dart';
import '../../data/datasources/remote/market_api.dart';
import '../../data/datasources/local/database.dart';
import '../blocs/portfolio_bloc/portfolio_bloc.dart';
import '../blocs/market_bloc/market_bloc.dart';
import '../services/pdf_service.dart';
import '../services/analysis_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(milliseconds: 15000);
    dio.options.receiveTimeout = const Duration(milliseconds: 15000);
    return dio;
  });

  // Data sources
  getIt.registerLazySingleton<LocalDatabase>(() => LocalDatabaseImpl());
  getIt.registerLazySingleton<MarketApi>(() => MarketApiImpl(getIt<Dio>()));

  // Repositories
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(getIt<LocalDatabase>()),
  );
  getIt.registerLazySingleton<MarketDataRepository>(
    () => MarketDataRepositoryImpl(getIt<MarketApi>()),
  );

  // Services
  getIt.registerLazySingleton<PdfService>(() => PdfServiceImpl());
  getIt.registerLazySingleton<AnalysisService>(
    () => AnalysisServiceImpl(getIt<PortfolioRepository>()),
  );

  // BLoCs
  getIt.registerFactory<PortfolioBloc>(
    () => PortfolioBloc(
      portfolioRepository: getIt<PortfolioRepository>(),
      pdfService: getIt<PdfService>(),
    ),
  );
  getIt.registerFactory<MarketBloc>(
    () => MarketBloc(
      marketDataRepository: getIt<MarketDataRepository>(),
    ),
  );
}