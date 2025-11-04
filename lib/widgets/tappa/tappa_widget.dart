import 'package:flutter/material.dart';
import 'package:cicer_ai/models/tappa_data.dart';
import 'tappa_widget_controller.dart';
import 'tappa_widget_view.dart';

class TappaWidget extends StatefulWidget {
  final TappaData tappaData;
  final int tappaIndex;
  final VoidCallback onDelete;
  final Function(String id, TappaData updatedData) onUpdate;
  final bool showControls;
  final bool canDelete;
  final DateTime? minDate;
  final String? Function(DateTime? selectedDate)? getMinTime;

  const TappaWidget({
    super.key,
    required this.tappaData,
    required this.tappaIndex,
    required this.onDelete,
    required this.onUpdate,
    this.showControls = true,
    this.canDelete = true,
    this.minDate,
    this.getMinTime,
  });

  @override
  State<TappaWidget> createState() => _TappaWidgetState();
}

class _TappaWidgetState extends State<TappaWidget> {
  late final TappaWidgetController controller;

  @override
  void initState() {
    super.initState();
    controller = TappaWidgetController(
      widget.tappaData,
      setState,
      (updatedData) => widget.onUpdate(widget.tappaData.id, updatedData),
      minDate: widget.minDate,
      getMinTime: widget.getMinTime,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TappaWidgetView(
      controller: controller,
      tappaIndex: widget.tappaIndex,
      onDelete: widget.onDelete,
      showControls: widget.showControls,
      canDelete: widget.canDelete,
    );
  }
}