import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _financesFuture;

  @override
  void initState() {
    super.initState();
    _financesFuture = _apiService.fetchFinances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moje finanse"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _financesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }
          /*
          {zaleglosci: [{idPlatnosc: 2, kwota: 450, termin: 2026-04-15 23:59:00.0,
           data: 2026-03-12 10:00:00.0, tytul: Opłata za legitymację semestralną,
            czyOplacone: 0}], oplacone: [{idPlatnosc: 1, kwota: 450,
             termin: 2026-03-31 23:59:00.0, data: 2026-03-10 12:00:00.0,
              tytul: Opłata za legitymację semestralną, czyOplacone: 1}],
               suma: 450, najblizszytermin: 2026-04-15 23:59}*/
          final data = snapshot.data ?? {};
          final String numerKonta = data['numerKonta'] ?? 'Brak';
          final int saldoKonta = data['suma'] ?? '0';
          final List zaleglosci = data['zaleglosci'] ?? [];
          final List historiaOplat = data['oplacone'] ?? [];
          print("$data");
          return ListView(
            children: [
              //Numer konta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.lightGreenAccent.shade400,
                child: const Text(
                  "Numer konta",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  numerKonta,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),

              //Saldo konta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.lightGreenAccent.shade400,
                child: const Text(
                  "Suma do zapłaty",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "$saldoKonta PLN",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),

              //Zaległości finansowe
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.lightGreenAccent.shade400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined),
                        SizedBox(width: 8),
                        Text(
                          "Zaległości finansowe",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_outward),
                  ],
                ),
              ),
              zaleglosci.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                color: Colors.red.shade300,
                child: const Text(
                  "Brak danych",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: zaleglosci.length,
                itemBuilder: (context, index) {
                  final item = zaleglosci[index];
                  return ListTile(
                    title: Text(item['tytul'] ?? ''),
                    trailing: Text("${item['kwota']} PLN" ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),

              //Historia opłat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.lightGreenAccent.shade400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined),
                        SizedBox(width: 8),
                        Text(
                          "Historia opłat",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_outward),
                  ],
                ),
              ),
              historiaOplat.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                color: Colors.red.shade300,
                child: const Text(
                  "Brak danych",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historiaOplat.length,
                itemBuilder: (context, index) {
                  final item = historiaOplat[index];
                  return ListTile(
                    title: Text(item['tytul'] ?? ''),
                    subtitle: Text(item['data'] ?? ''),
                    trailing: Text("${item['kwota']} PLN" ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}