# InvestmentTracker
# Investment Tracker App Architecture

## System Overview

```
┌─────────────────┐     ┌───────────────────┐     ┌────────────────────┐
│                 │     │                   │     │                    │
│  Mobile Client  │◄───►│  Backend Service  │◄───►│  Market Data APIs  │
│  (Flutter App)  │     │  (PDF Parsing &   │     │  (NSE/BSE Feeds)   │
│                 │     │   Data Storage)   │     │                    │
└─────────────────┘     └───────────────────┘     └────────────────────┘
```

## Project Structure

```
investment_tracker/
├── lib/
│   ├── main.dart                  # Entry point
│   ├── config/                    # App configuration
│   ├── models/                    # Data models
│   │   ├── portfolio.dart         # Portfolio model
│   │   ├── holding.dart           # Holding model
│   │   ├── transaction.dart       # Transaction model
│   │   └── sector.dart            # Sector categorization
│   ├── services/
│   │   ├── pdf_service.dart       # PDF parsing service
│   │   ├── storage_service.dart   # Local storage
│   │   ├── api_service.dart       # Backend API service
│   │   └── market_data_service.dart # Market data fetching
│   ├── screens/
│   │   ├── home_screen.dart       # Main dashboard
│   │   ├── portfolio_screen.dart  # Portfolio details
│   │   ├── analysis_screen.dart   # Analysis & recommendations
│   │   ├── import_screen.dart     # PDF import screen
│   │   └── settings_screen.dart   # App settings
│   ├── widgets/
│   │   ├── portfolio_summary.dart # Portfolio summary widget
│   │   ├── holdings_list.dart     # List of current holdings
│   │   ├── sector_chart.dart      # Sector allocation chart
│   │   └── price_ticker.dart      # Real-time price ticker
│   └── utils/
│       ├── formatters.dart        # Formatting utilities
│       └── constants.dart         # App constants
├── assets/
│   ├── images/                    # App images
│   └── fonts/                     # Custom fonts
├── pubspec.yaml                   # Dependencies
└── test/                          # Unit tests
```

## Backend Service Structure

```
backend/
├── server.js                      # Express server setup
├── controllers/
│   ├── auth_controller.js         # Authentication
│   ├── pdf_controller.js          # PDF processing
│   └── market_controller.js       # Market data
├── services/
│   ├── pdf_parser.js              # PDF parsing logic
│   ├── sector_classifier.js       # Sector classification
│   └── market_data.js             # Market data fetcher
├── models/
│   ├── user.js                    # User model
│   ├── portfolio.js               # Portfolio model
│   └── transaction.js             # Transaction model
├── utils/
│   └── helpers.js                 # Helper functions
└── package.json                   # Dependencies
```

## Key Technologies

1. **Frontend**:
   - Flutter for cross-platform development
   - Provider/Bloc for state management
   - fl_chart for portfolio visualization
   - shared_preferences for local storage

2. **Backend**:
   - Node.js with Express
   - PDF.js for PDF parsing
   - MongoDB for data storage
   - JWT for authentication

3. **Market Data**:
   - NSE/BSE API integration
   - WebSockets for real-time updates

## Data Flow

1. User uploads CDSL PDF statement to the app
2. PDF is sent to backend for parsing
3. Backend extracts holdings, transactions, and broker information
4. Data is stored in database and sent back to app
5. App fetches current market prices
6. App displays consolidated dashboard with real-time values
7. Analytics engine analyzes sector allocation and suggests rebalancing

## Security Considerations

1. Encrypt all sensitive data in transit and at rest
2. Implement proper authentication and authorization
3. Ensure CDSL statements are processed securely
4. Follow data minimization principles
5. Implement secure error handling and logging

# Investment Tracker App - Project Structure

```
investment_tracker/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # App configuration
│   ├── config/                   # App configuration files
│   │   └── app_config.dart       # Environment variables, API endpoints
│   ├── core/                     # Core functionality
│   │   ├── constants/            # App constants
│   │   ├── errors/               # Error handling
│   │   ├── utils/                # Utility functions
│   │   │   └── pdf_parser.dart   # PDF parsing logic
│   │   └── network/              # Network related code
│   │       └── api_client.dart   # API client for stock data
│   ├── data/
│   │   ├── models/               # Data models
│   │   │   ├── portfolio.dart    # Portfolio model
│   │   │   ├── holding.dart      # Holding model
│   │   │   └── transaction.dart  # Transaction model
│   │   ├── repositories/         # Repository pattern implementation
│   │   │   ├── portfolio_repository.dart
│   │   │   └── market_data_repository.dart
│   │   └── datasources/          # Data sources
│   │       ├── local/            # Local storage
│   │       │   └── database.dart
│   │       └── remote/           # Remote APIs
│   │           └── market_api.dart
│   ├── presentation/             # UI Layer
│   │   ├── screens/              # App screens
│   │   │   ├── dashboard/        # Dashboard screen
│   │   │   ├── portfolio/        # Portfolio details
│   │   │   ├── analysis/         # Portfolio analysis
│   │   │   └── settings/         # App settings
│   │   ├── widgets/              # Reusable widgets
│   │   │   ├── charts/           # Chart widgets
│   │   │   └── cards/            # Card widgets
│   │   └── themes/               # App theming
│   └── logic/                    # Business logic
│       ├── blocs/                # BLoC pattern implementation
│       │   ├── portfolio_bloc/   # Portfolio management
│       │   └── market_bloc/      # Market data handling
│       └── services/             # Business services
│           ├── pdf_service.dart  # PDF processing service
│           └── analysis_service.dart # Portfolio analysis service
├── assets/                       # App assets
│   ├── images/                   # Images
│   └── fonts/                    # Custom fonts
├── test/                         # Test files
│   ├── unit/                     # Unit tests
│   ├── widget/                   # Widget tests
│   └── integration/              # Integration tests
└── pubspec.yaml                  # Dependencies
```

## Key Technologies:

1. **State Management**: Flutter BLoC pattern
2. **Local Storage**: Hive or SQLite
3. **PDF Processing**: pdf.js or pdf-lib.js
4. **Networking**: Dio for HTTP requests
5. **Charts and Visualization**: fl_chart or syncfusion_flutter_charts
6. **Market Data API**: NSE/BSE APIs or third-party providers

## Key Functionalities:

1. **PDF Parsing**:
   - Upload PDF CDSL statement
   - Extract holdings, transactions, and account details
   - Store structured data locally

2. **Portfolio Dashboard**:
   - Current holdings overview
   - Asset allocation visualization
   - Sector-wise distribution
   - Performance metrics

3. **Real-time Market Integration**:
   - Current market value calculation
   - Profit/loss tracking
   - Performance comparison with indices

4. **Portfolio Analysis**:
   - Sector imbalance detection
   - Diversification recommendations
   - Risk assessment
   - Historical performance analysis