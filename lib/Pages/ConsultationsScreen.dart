import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<dynamic>> _consultationsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  void _loadConsultations() {
    setState(() {
      _consultationsFuture = _apiService.fetchKonsultacje(searchQuery: _searchQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konsultacje"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Szukaj wykładowcy...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _loadConsultations();
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _loadConsultations();
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _consultationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Błąd: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final List consultations = snapshot.data ?? [];

                if (consultations.isEmpty) {
                  return const Center(
                    child: Text("Nie znaleziono konsultacji", style: TextStyle(fontSize: 16)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: consultations.length,
                  itemBuilder: (context, index) {
                    final item = consultations[index];
                    return _buildConsultationCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> item) {
    final String tytul = item['TytulNaukowy'] ?? '';
    final String name = item['name'] ?? '';
    final String surname = item['surname'] ?? '';
    final String teacherFullName = "$tytul $name $surname".trim();


    final String date = item['data'] ?? '';
    final String timeStart = item['GodzinaRozpoczecia'] ?? '';
    final String timeEnd = item['GodzinaZakonczenia'] ?? '';
    final String timeRange = (timeStart.isNotEmpty && timeEnd.isNotEmpty)
        ? "${timeStart.substring(0, 5)} - ${timeEnd.substring(0, 5)}"
        : timeStart;


    final String sala = item['numerSali'] ?? '';
    final String budynek = item['nazwa'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teacherFullName.isNotEmpty ? teacherFullName : "Wykładowca",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.room, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  "Sala: $sala ($budynek)",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(date,style: TextStyle(color: Colors.black),),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(timeRange,style: TextStyle(color: Colors.black),),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}