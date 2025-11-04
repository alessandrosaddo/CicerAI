import 'package:flutter/material.dart';
import 'package:cicer_ai/models/saved_itinerary.dart';
import 'package:cicer_ai/services/database_service.dart';
import 'package:cicer_ai/themes/colors.dart';

class HistoryScreen extends StatefulWidget {
  final Function(int)? onItinerarySelected;

  const HistoryScreen({
    super.key,
    this.onItinerarySelected,
  });

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<SavedItinerary> _savedItineraries = [];
  List<SavedItinerary> _filteredItineraries = []; // Itinerari filtrati dalla ricerca
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItineraries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ricarica gli itinerari (chiamato dal main quando si salva)
  Future<void> reloadItineraries() async {
    await _loadItineraries();
  }

  // Carica tutti gli itinerari salvati
  Future<void> _loadItineraries() async {
    setState(() => _isLoading = true);

    try {
      final itineraries = await _db.getAllItineraries();

      if (mounted) {
        setState(() {
          _savedItineraries = itineraries;
          _filteredItineraries = itineraries;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Errore caricamento itinerari: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() => _filteredItineraries = _savedItineraries);
      return;
    }

    // query SQL
    try {
      final results = await _db.searchByName(query);
      if (mounted) {
        setState(() => _filteredItineraries = results);
      }
    } catch (e) {
      debugPrint('Errore ricerca: $e');
    }
  }

  Future<void> _deleteItinerary(SavedItinerary itinerary) async {
    final confirmed = await _showDeleteConfirmation(itinerary.name);

    if (confirmed == true) {
      final success = await _db.deleteItinerary(itinerary.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Itinerario "${itinerary.name}" eliminato'),
            backgroundColor: AppColors.widgetBackground(context),
          ),
        );
        _loadItineraries();
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Vuoi eliminare l\'itinerario "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppColors.hintText(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Elimina',
              style: TextStyle(color: AppColors.deleteColorText(context)),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteAllItineraries() async {
    if (_savedItineraries.isEmpty) return;

    final confirmed = await _showDeleteAllConfirmation();
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _db.deleteAllItineraries();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary(context)),
                const SizedBox(width: 8),
                const Text('Tutti gli itinerari sono stati eliminati'),
              ],
            ),
            backgroundColor: AppColors.widgetBackground(context),
            duration: const Duration(seconds: 3),
          ),
        );
        await _loadItineraries();
      }
    } catch (e) {
      debugPrint('❌ Errore eliminazione totale: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Errore durante l\'eliminazione'),
            backgroundColor: AppColors.deleteColorText(context),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteAllConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warningColor(context)),
            const SizedBox(width: 8),
            const Text('Attenzione'),
          ],
        ),
        content: Text(
          'Vuoi eliminare tutti gli itinerari salvati?\nItinerari Totali: ${_savedItineraries.length}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppColors.hintText(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Elimina Tutto',
              style: TextStyle(
                color: AppColors.deleteColorText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Apre un itinerario salvato
  void _openItinerary(SavedItinerary itinerary) {
    widget.onItinerarySelected?.call(itinerary.id!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary(context)),
      );
    }

    if (_savedItineraries.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadItineraries,
            color: AppColors.primary(context),
            child: _filteredItineraries.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItineraries.length,
              itemBuilder: (context, index) {
                return _buildItineraryCard(_filteredItineraries[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Barra di ricerca + pulsante elimina
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca itinerario...',
                hintStyle: TextStyle(color: AppColors.hintText(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.icon(context)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.hintText(context)),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                filled: true,
                fillColor: AppColors.widgetBackground(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.deleteColorText(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deleteColorText(context),
                width: 1.5,
              ),
            ),
            child: IconButton(
              onPressed: _savedItineraries.isEmpty ? null : _deleteAllItineraries,
              icon: Icon(
                Icons.delete_sweep,
                color: _savedItineraries.isEmpty
                    ? AppColors.disabledText(context)
                    : AppColors.deleteColorText(context),
              ),
              tooltip: 'Elimina tutti gli itinerari',
              iconSize: 28,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNoResultsState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.hintText(context)),
              const SizedBox(height: 16),
              Text(
                'Nessun itinerario trovato',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prova con un altro nome',
                style: TextStyle(fontSize: 14, color: AppColors.hintText(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryCard(SavedItinerary itinerary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.widgetBackground(context),
      child: InkWell(
        onTap: () => _openItinerary(itinerary),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_travel,
                  color: AppColors.primary(context),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerary.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.hintText(context)),
                        const SizedBox(width: 4),
                        Text(
                          itinerary.formattedDate,
                          style: TextStyle(fontSize: 14, color: AppColors.hintText(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteItinerary(itinerary),
                icon: Icon(Icons.delete_outline, color: AppColors.deleteColorText(context)),
                tooltip: 'Elimina',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: AppColors.primary(context),size: 30),
            const SizedBox(height: 8),
            Text(
              'Nessun viaggio salvato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genera il tuo itinerario',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.hintText(context)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'e salvalo con',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppColors.hintText(context)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.east_rounded, color: AppColors.hintText(context),size: 20),
                const SizedBox(width: 8),
                Icon(Icons.save_alt, color: AppColors.primary(context),size: 30),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ],
    );
  }
}