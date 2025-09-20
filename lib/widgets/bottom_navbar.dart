import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Itinerario'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Archivio'),
      ],
    );
  }
}
