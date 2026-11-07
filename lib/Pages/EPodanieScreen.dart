import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class EPodanieScreen extends StatefulWidget {
  const EPodanieScreen({super.key});

  @override
  State<EPodanieScreen> createState() => _EPodanieScreenState();
}

class _EPodanieScreenState extends State<EPodanieScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedType;
  bool _isLoading = false;


  final List<String> _podanieTypes = [
    'Wniosek o stypendium rektora',
    'Wniosek o stypendium socjalne',
    'Podanie o indywidualną organizację studiów (IOS)',
    'Podanie o wydanie zaświadczenia',
    'Inne pismo do dziekanatu',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitPodanie() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz typ podania!')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wprowadź treść podania!',)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.sendPodanieM(
        type: _selectedType!,
        content: _contentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podanie zostało wysłane pomyślnie!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedType = null;
        _contentController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EPodanie"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  hint: const Text(
                    "Wybierz typ podania",
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  dropdownColor: Colors.white,
                  items: _podanieTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedType = val),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Wprowadź treść podania",
                hintStyle: const TextStyle(
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.grey.shade400,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dodaj załączniki",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wybór plików będzie dostępny wkrótce')),
                        );
                      },
                      child: const Text(
                        "Wybierz plik",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),


            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _submitPodanie,
              child: const Text(
                "Wyślij podanie",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}