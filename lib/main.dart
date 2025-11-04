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
import 'services/database_service.dart';

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
      home: const MainNavigation(),
    );
  }
}

// State class per gestire lo stato dell'itinerario
class ItineraryState {
  final ItineraryResponse? itinerary;
  final bool isLoading;
  final String? error;

  const ItineraryState({
    this.itinerary,
    this.isLoading = false,
    this.error,
  });

  ItineraryState copyWith({
    ItineraryResponse? itinerary,
    bool? isLoading,
    String? error,
  }) {
    return ItineraryState(
      itinerary: itinerary ?? this.itinerary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final ValueNotifier<ItineraryState> _itineraryState = ValueNotifier(
    const ItineraryState(),
  );

  final DatabaseService _db = DatabaseService();
  final GlobalKey<HistoryScreenState> _historyScreenKey = GlobalKey();

  @override
  void dispose() {
    _itineraryState.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Gestisce la generazione di un nuovo itinerario
  void _handleItineraryGeneration(
      ItineraryResponse? itinerary,
      bool isLoading,
      String? error,
      ) {
    _itineraryState.value = ItineraryState(
      itinerary: itinerary,
      isLoading: isLoading,
      error: error,
    );

    // Passa automaticamente alla schermata itinerario
    setState(() => _selectedIndex = 1);
  }


  Future<void> _handleSavedItinerarySelected(int itineraryId) async {
    _itineraryState.value = const ItineraryState(isLoading: true);
    setState(() => _selectedIndex = 1);

    try {
      final savedItinerary = await _db.getItineraryById(itineraryId);

      if (savedItinerary != null) {
        final itinerary = savedItinerary.toItineraryResponse();
        _itineraryState.value = ItineraryState(itinerary: itinerary);
      } else {
        _itineraryState.value = const ItineraryState(
          error: 'Impossibile caricare l\'itinerario',
        );
      }
    } catch (e) {
      debugPrint('Errore caricamento itinerario: $e');
      _itineraryState.value = const ItineraryState(
        error: 'Errore durante il caricamento',
      );
    }
  }


  void _handleItinerarySaved() {
    debugPrint('Itinerario salvato, ricarico la history...');
    _historyScreenKey.currentState?.reloadItineraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onItineraryGenerated: _handleItineraryGeneration),

          // Usa ValueListenableBuilder per reagire ai cambiamenti
          ValueListenableBuilder<ItineraryState>(
            valueListenable: _itineraryState,
            builder: (context, state, _) {
              return ItineraryScreen(
                itinerario: state.itinerary,
                isLoading: state.isLoading,
                errorMessage: state.error,
                onItinerarySaved: _handleItinerarySaved,
              );
            },
          ),

          HistoryScreen(
            key: _historyScreenKey,
            onItinerarySelected: _handleSavedItinerarySelected,
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}