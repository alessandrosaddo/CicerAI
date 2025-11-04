import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:cicer_ai/themes/map_theme.dart';
import 'itinerary_map_controller.dart';
import 'itinerary_map.dart';


class ItineraryMapView extends StatefulWidget {
  final ItineraryMapController controller;
  final ItineraryMapModel model;

  const ItineraryMapView({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<ItineraryMapView> createState() => _ItineraryMapViewState();
}

class _ItineraryMapViewState extends State<ItineraryMapView> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onModelUpdate);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelUpdate);
    _mapController?.dispose();
    super.dispose();
  }

  void _onModelUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _applyMapStyle(controller);
    widget.controller.setMapController(controller);
  }

  Future<void> _applyMapStyle(GoogleMapController controller) async {
    final mapStyle = MapStyles.getMapStyle(context);
    await controller.setMapStyle(mapStyle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mapController != null) {
      _applyMapStyle(_mapController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mappa Google
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: widget.controller.initialCameraPosition,
          cameraTargetBounds: widget.controller.cameraTargetBounds,
          minMaxZoomPreference: widget.controller.minMaxZoomPreference,
          markers: widget.controller.currentMarkers,
          polylines: widget.controller.currentPolylines,
          onTap: (_) {}, // Previene click accidentali
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,

          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
            ),
          },
        ),

        // Pulsante "Torna alla vista generale" (solo in modalità dettaglio)
        if (widget.controller.isDetailMode) _buildReturnButton(),
      ],
    );
  }

  Widget _buildReturnButton() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary(context).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
        ),
        child: IconButton(
          onPressed: widget.controller.returnToOverview,
          icon: Icon(
            Icons.fullscreen,
            color: AppColors.iconColorMap(context),
            size: 40,
          ),
          padding: const EdgeInsets.all(1),
          tooltip: 'Torna alla vista generale',
        ),
      ),
    );
  }
}