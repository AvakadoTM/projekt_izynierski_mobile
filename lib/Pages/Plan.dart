import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';
import 'DayPlanScreen.dart';

class PlanZajecScreen extends StatefulWidget {
  const PlanZajecScreen({super.key});

  @override
  State<PlanZajecScreen> createState() => _PlanZajecScreenState();
}

class _PlanZajecScreenState extends State<PlanZajecScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _plan = [];
  List<dynamic> _listaGrup = [];
  List<dynamic> _listaKierunkow = [];

  int? _selectedKierunekId;
  int? _selectedGrupaId;
  String _currentGroupName = "Ładowanie...";

  final List<String> _days = [
    'Poniedziałek',
    'Wtorek',
    'Środa',
    'Czwartek',
    'Piątek',
    'Sobota',
    'Niedziela'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialPlan();
  }

  Future<void> _loadInitialPlan() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchPlanZajec();
      setState(() {
        _plan = data['plan'] ?? [];
        _listaGrup = data['listagrup'] ?? [];
        _listaKierunkow = data['listakierunkow'] ?? [];


        if (_listaGrup.isNotEmpty) {
          _currentGroupName = "Brak grupy";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd ładowania: $e")),
      );
    }
  }

  Future<void> _loadPlanForGroup(int grupaId, String groupName) async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchPlanZajecForGroup(grupaId);
      setState(() {
        _plan = data['plan'] ?? [];
        _selectedGrupaId = grupaId;
        _currentGroupName = groupName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd ładowania grupy: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan zajęć", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Grupa: $_currentGroupName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),


          Expanded(
            flex: 4,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    title: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.north_east, color: Colors.black87),
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DayPlanScreen(
                            dayName: day,
                            plan: _plan,
                            groupName: _currentGroupName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(thickness: 2),


          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: const Text("Wybierz kierunek", style: TextStyle(color: Colors.black54)),
                        value: _selectedKierunekId,
                        items: _listaKierunkow.map<DropdownMenuItem<int>>((kierunek) {
                          return DropdownMenuItem<int>(
                            value: kierunek['idKierunek'] ?? kierunek['id'] ?? 0,
                            child: Text(kierunek['nazwaKierunku'] ?? kierunek['nazwa'] ?? 'Kierunek'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedKierunekId = val;
                                                      });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: const Text("Wybierz grupę", style: TextStyle(color: Colors.black54)),
                        value: _selectedGrupaId,
                        items: _listaGrup.map<DropdownMenuItem<int>>((grupa) {
                          final gName = grupa['nazwaGrupy'] ?? 'Grupa';
                          return DropdownMenuItem<int>(
                            value: grupa['idGrupaStudenta'] ?? 0,
                            child: Text(gName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selected = _listaGrup.firstWhere(
                                  (g) => (g['idGrupaStudenta'] ?? 0) == val,
                              orElse: () => {},
                            );
                            final gName = selected['nazwaGrupy'] ?? 'Grupa';
                            _loadPlanForGroup(val, gName);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/Home');
          if (index == 2) Navigator.pushReplacementNamed(context, '/Map');
          if (index == 3) Navigator.pushReplacementNamed(context, '/Ustawienia');
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