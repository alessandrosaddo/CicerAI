import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  static bool permessiRifiutati = false;

  static Future<String?> getCurrentCity({BuildContext? context}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permessiRifiutati && context != null && context.mounted) {
          allertPermessi(context);
        }
        permessiRifiutati = true;
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        if (context != null && context.mounted) {
          allertPermessi(context);
        }
        return null;
      }

      permessiRifiutati = false;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return placemarks.first.locality;
    } catch (e) {
      debugPrint('Errore nel recupero della posizione: $e');
      return null;
    }
  }


  static void allertPermessi(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permessi negati"),
        content: const Text(
          "Impossibile ottenere la posizione.\nConsenti l'accesso alla posizione nelle impostazioni.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text("Impostazioni"),
          ),
        ],
      ),
    );
  }

}
