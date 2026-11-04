
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:projekt_izynierski/DataModels/budynek_mapy.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class MapaKampusu extends StatefulWidget {
  const MapaKampusu({super.key});

  @override
  State<MapaKampusu> createState() => _MapaKampusuState();
}

class _MapaKampusuState extends State<MapaKampusu> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  String? _selectedRoom;
  final ApiService _service = ApiService();

  final MapController _mapController = MapController();

  List<BudynekMapy> _budynki = [];
  bool _loading = true;
  String? _error;
  Set<String> _saleZPlanu = {};

  @override
  void initState() {
    super.initState();
    _zaladujBudynki();
  }

  Future<void> _zaladujBudynki() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Pobieranie budynków
      final budynki = await _service.fetchBudynki();

      // Pobieranie planu zajęć
      Set<String> saleZPlanu = {};

      try {
        final planData = await _service.fetchPlanZajec();

        final plan = planData['plan'];

        if (plan is List) {
          for (final zajecie in plan) {
            final zajecieData =
            Map<String, dynamic>.from(zajecie as Map);

            final props = Map<String, dynamic>.from(
              zajecieData['extendedProps'] as Map,
            );

            final idBudynek = props['idBudynek']?.toString();
            final numerSali = props['numersali']?.toString();

            if (idBudynek != null &&
                numerSali != null &&
                idBudynek.isNotEmpty &&
                numerSali.isNotEmpty) {
              saleZPlanu.add('${idBudynek}_$numerSali');
            }
          }
        }
      } catch (e) {
        debugPrint('Nie udało się pobrać planu zajęć: $e');
      }

      if (!mounted) return;

      setState(() {
        _budynki = budynki;
        _saleZPlanu = saleZPlanu;
        _loading = false;

        debugPrint('Sale z planu:');
        debugPrint(_saleZPlanu.toString());
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _pokazBudynek(BudynekMapy budynek) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budynek.nazwa,
                style: Theme.of(context)
                    .textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              Text('Adres: ${budynek.adres}'),

              const SizedBox(height: 16),

              const Text(
                'Dostępne sale:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              if (budynek.numerySal.isEmpty)
                const Text('Brak informacji o salach.')
              else
                ...budynek.numerySal.map((sala) {
                  final selected = sala == _selectedRoom;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(color: Colors.blue)
                          : null,
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.door_front_door,
                        color: selected
                            ? Colors.blue
                            : null,
                      ),
                      title: Text(
                        'Sala $sala',
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? Colors.blue
                              : null,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      )
                          : null,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _wybierzSale(BudynekMapy budynek, String? numerSali) {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedRoom = numerSali;
      _searchQuery = '';
      _searchController.clear();
    });

    _mapController.move(
      LatLng(
        budynek.szerokosc,
        budynek.dlugosc,
      ),
      18,
    );

    _pokazBudynek(budynek);
  }

  void _pokazListeSal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _posortowaneBudynki.length,
              itemBuilder: (context, index) {
                final budynek = _posortowaneBudynki[index];
                final sale = _posortowaneSale(budynek);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      child: Text(
                        budynek.nazwa,
                        style: Theme.of(context)
                            .textTheme.titleMedium,
                      ),
                    ),
                    ...sale.map((numer) {
                      final maZajecia = _saleZPlanu.contains(
                        '${budynek.id}_$numer',
                      );

                      return ListTile(
                        leading: Icon(
                          Icons.meeting_room_outlined,
                          color: maZajecia
                              ? Colors.green
                              : null,
                        ),
                        title: Text('Sala $numer'),
                        subtitle: Text(
                          maZajecia
                              ? 'Są zajęcia w twoim planie'
                              : budynek.adres,
                        ),
                        trailing: maZajecia
                            ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _wybierzSale(budynek, numer);
                        },
                      );
                    }),
                    const Divider(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BudynekMapy> get _wynikiWyszukiwania {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    return _budynki.where((budynek) {
      final nazwaPasuje =
      budynek.nazwa.toLowerCase().contains(query);

      final ulicaPasuje =
      budynek.ulica.toLowerCase().contains(query);

      final numerBudynkuPasuje =
      budynek.nrBudynku.toLowerCase().contains(query);

      final salaPasuje = budynek.numerySal.any(
            (sala) => sala.toLowerCase().contains(query),
      );

      return nazwaPasuje ||
          ulicaPasuje ||
          numerBudynkuPasuje ||
          salaPasuje;
    }).toList();
  }

  List<BudynekMapy> get _posortowaneBudynki {
    final wynik = _budynki.map((budynek) {
      final saleZajeciowe = budynek.numerySal
          .where((numer) =>
          _saleZPlanu.contains('${budynek.id}_$numer'))
          .toList();

      final pozostaleSale = budynek.numerySal
          .where((numer) =>
      !_saleZPlanu.contains('${budynek.id}_$numer'))
          .toList();

      saleZajeciowe.sort();
      pozostaleSale.sort();

      return {
        'budynek': budynek,
        'saleZajeciowe': saleZajeciowe,
        'pozostaleSale': pozostaleSale,
      };
    }).toList();


    wynik.sort((a, b) {
      final aMaZajecia =
          (a['saleZajeciowe'] as List).isNotEmpty;
      final bMaZajecia =
          (b['saleZajeciowe'] as List).isNotEmpty;

      if (aMaZajecia == bMaZajecia) {
        final budynekA = a['budynek'] as BudynekMapy;
        final budynekB = b['budynek'] as BudynekMapy;

        return budynekA.nazwa.compareTo(budynekB.nazwa);
      }

      return aMaZajecia ? -1 : 1;
    });

    return wynik.map((e) => e['budynek'] as BudynekMapy).toList();
  }

  List<String> _posortowaneSale(BudynekMapy budynek) {
    final sale = budynek.numerySal.toList();

    sale.sort((a, b) {
      final aMaZajecia =
      _saleZPlanu.contains('${budynek.id}_$a');
      final bMaZajecia =
      _saleZPlanu.contains('${budynek.id}_$b');

      if (aMaZajecia != bMaZajecia) {
        return aMaZajecia ? -1 : 1;
      }

      return a.compareTo(b);
    });

    return sale;
  }

  @override
  Widget build(BuildContext context) {
    final center = _budynki.isNotEmpty
        ? LatLng(
      _budynki.first.szerokosc,
      _budynki.first.dlugosc,
    )
        : const LatLng(52.2297, 21.0122);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa kampusu'),
        actions: [
          IconButton(
            onPressed: _zaladujBudynki,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież mapę',
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nie udało się pobrać danych mapy.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _zaladujBudynki,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Szukaj budynku lub sali...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Pokaż wszystkie sale',
                    onPressed: _pokazListeSal,
                    icon: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // SEARCH RESULTS
          if (_searchQuery.trim().isNotEmpty)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: _wynikiWyszukiwania.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nie znaleziono wyników.'),
              )
                  : ListView(
                shrinkWrap: true,
                children: _wynikiWyszukiwania
                    .expand((budynek) {
                  final query =
                  _searchQuery.trim().toLowerCase();

                  final sale = budynek.numerySal
                      .where((sala) =>
                      sala.toLowerCase().contains(query))
                      .toList();

                  final budynekPasuje =
                      budynek.nazwa.toLowerCase().contains(query) ||
                          budynek.ulica.toLowerCase().contains(query) ||
                          budynek.nrBudynku.toLowerCase().contains(query);

                  final wyniki = <Widget>[];

                  if (budynekPasuje) {
                    wyniki.add(
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.school),
                        title: Text(budynek.nazwa),
                        subtitle: Text(budynek.adres),
                        onTap: () => _wybierzSale(
                          budynek,
                          null,
                        ),
                      ),
                    );
                  }

                  for (final sala in sale) {
                    wyniki.add(
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.door_front_door,
                        ),
                        title: Text('Sala $sala'),
                        subtitle: Text(budynek.nazwa),
                        onTap: () => _wybierzSale(
                          budynek,
                          sala,
                        ),
                      ),
                    );
                  }

                  return wyniki;
                }).toList(),
              ),
            ),

          // MAP
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _budynki.isNotEmpty
                    ? LatLng(
                  _budynki.first.szerokosc,
                  _budynki.first.dlugosc,
                )
                    : const LatLng(52.2297, 21.0122),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/'
                      '{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'pl.twojauczelnia.app',
                ),

                MarkerLayer(
                  markers: _budynki.map((budynek) {
                    return Marker(
                      point: LatLng(
                        budynek.szerokosc,
                        budynek.dlugosc,
                      ),
                      width: 120,
                      height: 65,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRoom = null;
                          });

                          _pokazBudynek(budynek);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 36,
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                color: Theme.of(context)
                                    .colorScheme.surface,
                                child: Text(
                                  budynek.nazwa,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/Home');
          if (index == 1) Navigator.pushNamed(context, '/Plan');
          if (index == 3) Navigator.pushNamed(context, '/Ustawienia');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Opcje'),
        ],
      ),
    );
  }
}
