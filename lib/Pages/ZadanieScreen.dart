import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class ZadanieScreen extends StatefulWidget {
  final int idZadanie;

  const ZadanieScreen({super.key, required this.idZadanie});

  @override
  State<ZadanieScreen> createState() => _ZadanieScreenState();
}

class _ZadanieScreenState extends State<ZadanieScreen> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _zadanieFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _zadanieFuture = _apiService.fetchZadanieDetails(widget.idZadanie);
    });
  }

  // Метод выбора и отправки файлов теперь находится ВНУТРИ класса State
  Future<void> _pickAndUploadFiles() async {
    try {
      final List<XFile> result = await openFiles();

      if (result.isNotEmpty) {
        setState(() => _isUploading = true);

        List<String> paths = result.map((file) => file.path).toList();

        await _apiService.wyslijZadanie(widget.idZadanie, paths);

        setState(() => _isUploading = false);
        _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Zadanie zostało wysłane")),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd podczas wysyłania: $e")),
        );
      }
    }
  }

  Future<void> _deleteFile(int idPlik) async {
    try {
      await _apiService.usunPlikZadania(widget.idZadanie, idPlik);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plik został usunięty")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nie udało się usunąć pliku")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły zadania"),
      ),
      body: FutureBuilder<dynamic>(
        future: _zadanieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final responseBody = snapshot.data;
          final data = (responseBody is Map<String, dynamic>) ? responseBody : <String, dynamic>{};

          final zadanie = data['zadanie'] ?? {};
          final List pliki = data['pliki'] ?? [];
          final ocena = data['ocena'];

          final String nazwaZadania = zadanie['nazwaZadania'] ?? 'Zadanie';
          final String tresc = zadanie['tresc'] ?? 'Brak opisu';
          final String termin = zadanie['TerminOddania'] ?? '';
          final String status = zadanie['pivot']?['status'] ?? 'Nie wysłano';

          final String skalaOceny = ocena != null ? (ocena['skalaOceny'] ?? '-') : 'Brak oceny';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                nazwaZadania,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(status, style: const TextStyle(color: Colors.white)),
                    backgroundColor: status == 'Wysłane' ? Colors.green : Colors.orange,
                  ),
                ],
              ),
              if (termin.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text("Termin oddania: $termin", style: const TextStyle(color: Colors.grey)),
              ],
              const Divider(height: 24),

              const Text("Treść zadania:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(tresc, style: const TextStyle(fontSize: 15)),
              const Divider(height: 24),

              const Text("Ocena:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                skalaOceny,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ocena != null ? Colors.green : Colors.grey),
              ),
              const Divider(height: 24),

              const Text("Twoje pliki / rozwiązania:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              pliki.isEmpty
                  ? const Text("Brak przesłanych plików", style: TextStyle(color: Colors.grey))
                  : Column(
                children: pliki.map((plik) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(plik['nazwa'].toString().split('/').last),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFile(plik['idPlik']),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _pickAndUploadFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text("Wybierz pliki i wyślij zadanie", style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      ),
    );
  }
}