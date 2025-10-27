import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'themes/app_theme.dart';
import 'widgets/custom_appbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/itinerary/itinerary_response.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      locale: WidgetsBinding.instance.platformDispatcher.locale,

      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  ItineraryResponse? _currentItinerary;
  bool _isLoadingItinerary = false;
  String? _itineraryError;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleItineraryGeneration(
      ItineraryResponse? itinerary,
      bool isLoading,
      String? error,
      ) {
    setState(() {
      _currentItinerary = itinerary;
      _isLoadingItinerary = isLoading;
      _itineraryError = error;

      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onItineraryGenerated: _handleItineraryGeneration),
          ItineraryScreen(
            itinerario: _currentItinerary,
            isLoading: _isLoadingItinerary,
            errorMessage: _itineraryError,
          ),
          HistoryScreen(),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}