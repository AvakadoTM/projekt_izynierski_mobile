
class BudynekMapy {
  final int id;
  final String nazwa;
  final String ulica;
  final String nrBudynku;
  final double szerokosc;
  final double dlugosc;
  final List<String> numerySal;

  const BudynekMapy({
    required this.id,
    required this.nazwa,
    required this.ulica,
    required this.nrBudynku,
    required this.szerokosc,
    required this.dlugosc,
    this.numerySal = const [],
  });

  factory BudynekMapy.fromJson(Map<String, dynamic> json) {
    return BudynekMapy(
      id: int.parse(json['id'].toString()),
      nazwa: json['nazwa']?.toString() ?? '',
      ulica: json['ulica']?.toString() ?? '',
      nrBudynku: json['nrBudynku']?.toString() ?? '',
      szerokosc:
      double.parse(json['szerokosc'].toString()),
      dlugosc:
      double.parse(json['dlugosc'].toString()),
      numerySal: json['numerSali'] == null
          ? []
          : [json['numerSali'].toString()],
    );
  }

  String get adres => '$ulica $nrBudynku'.trim();
}
