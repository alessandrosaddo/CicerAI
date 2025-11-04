import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cicer_ai/widgets/bottom_navbar.dart';

void main() {
  Widget createTestWidget({
    required int selectedIndex,
    required Function(int) onItemTapped,
  }) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: MyBottomNavigationBar(
          selectedIndex: selectedIndex,
          onItemTapped: onItemTapped,
        ),
      ),
    );
  }

  group('MyBottomNavigationBar - Test UI', () {
    testWidgets('Mostra tre tab: Cerca, Itinerario, Archivio', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (_) {},
        ),
      );

      // Verifica presenza delle tre tab
      expect(find.text('Cerca'), findsOneWidget);
      expect(find.text('Itinerario'), findsOneWidget);
      expect(find.text('Archivio'), findsOneWidget);
    });

    testWidgets('Mostra le icone corrette per ogni tab', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (_) {},
        ),
      );

      // Verifica presenza delle icone
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('Prima tab è selezionata di default', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (_) {},
        ),
      );

      final BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));

      expect(navbar.currentIndex, 0);
    });

    testWidgets('Seconda tab può essere selezionata', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 1,
          onItemTapped: (_) {},
        ),
      );

      final BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));

      expect(navbar.currentIndex, 1);
    });

    testWidgets('Terza tab può essere selezionata', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 2,
          onItemTapped: (_) {},
        ),
      );

      final BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));

      expect(navbar.currentIndex, 2);
    });
  });

  group('MyBottomNavigationBar - Test Interazioni', () {
    testWidgets('Tap sulla prima tab chiama onItemTapped con index 0',
            (tester) async {
          int? tappedIndex;

          await tester.pumpWidget(
            createTestWidget(
              selectedIndex: 0,
              onItemTapped: (index) => tappedIndex = index,
            ),
          );

          // Tap sulla prima tab
          await tester.tap(find.text('Cerca'));
          await tester.pump();

          expect(tappedIndex, 0);
        });

    testWidgets('Tap sulla seconda tab chiama onItemTapped con index 1',
            (tester) async {
          int? tappedIndex;

          await tester.pumpWidget(
            createTestWidget(
              selectedIndex: 0,
              onItemTapped: (index) => tappedIndex = index,
            ),
          );

          // Tap sulla seconda tab
          await tester.tap(find.text('Itinerario'));
          await tester.pump();

          expect(tappedIndex, 1);
        });

    testWidgets('Tap sulla terza tab chiama onItemTapped con index 2',
            (tester) async {
          int? tappedIndex;

          await tester.pumpWidget(
            createTestWidget(
              selectedIndex: 0,
              onItemTapped: (index) => tappedIndex = index,
            ),
          );

          // Tap sulla terza tab
          await tester.tap(find.text('Archivio'));
          await tester.pump();

          expect(tappedIndex, 2);
        });

    testWidgets('Cambiare selezione aggiorna la UI', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                bottomNavigationBar: MyBottomNavigationBar(
                  selectedIndex: selectedIndex,
                  onItemTapped: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),
              ),
            );
          },
        ),
      );

      // Verifica stato iniziale
      BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));
      expect(navbar.currentIndex, 0);

      // Tap sulla seconda tab
      await tester.tap(find.text('Itinerario'));
      await tester.pumpAndSettle();

      // Verifica che l'indice sia cambiato
      navbar = tester.widget(find.byType(BottomNavigationBar));
      expect(navbar.currentIndex, 1);

      // Tap sulla terza tab
      await tester.tap(find.text('Archivio'));
      await tester.pumpAndSettle();

      // Verifica che l'indice sia cambiato
      navbar = tester.widget(find.byType(BottomNavigationBar));
      expect(navbar.currentIndex, 2);
    });
  });

  group('MyBottomNavigationBar - Test Struttura', () {
    testWidgets('Ha esattamente 3 elementi', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (_) {},
        ),
      );

      final BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));

      expect(navbar.items.length, 3);
    });

    testWidgets('Ogni elemento ha icona e label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (_) {},
        ),
      );

      final BottomNavigationBar navbar =
      tester.widget(find.byType(BottomNavigationBar));

      // Verifica primo elemento
      expect(navbar.items[0].icon, isA<Icon>());
      expect(navbar.items[0].label, 'Cerca');

      // Verifica secondo elemento
      expect(navbar.items[1].icon, isA<Icon>());
      expect(navbar.items[1].label, 'Itinerario');

      // Verifica terzo elemento
      expect(navbar.items[2].icon, isA<Icon>());
      expect(navbar.items[2].label, 'Archivio');
    });
  });
}