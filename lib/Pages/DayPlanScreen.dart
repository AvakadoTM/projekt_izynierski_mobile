import 'package:flutter/material.dart';

class DayPlanScreen extends StatelessWidget {
  final String dayName;
  final List<dynamic> plan;
  final String groupName;

  const DayPlanScreen({
    super.key,
    required this.dayName,
    required this.plan,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {

    // Фильтруем занятия конкретно для выбранного дня недели
    final dayClasses = plan.where((item) {

      final props = item['extendedProps'] ?? {};
      return props['dzientygodnia']?.toString().toLowerCase() == dayName.toLowerCase();
    }).toList();

    // Список стандартных часов сетки (с 8:00 до 20:00)
    final List<String> hours = [
      '8:00', '9:00', '10:00', '11:00', '12:00', '13:00',
      '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Шапка с группой
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Grupa: $groupName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(height: 1),

          // Почасовая сетка расписания
          Expanded(
            child: ListView.builder(
              itemCount: hours.length - 1,
              itemBuilder: (context, index) {
                String startHourStr = hours[index];
                String endHourStr = hours[index + 1];

                // Ищем занятие, которое попадает в этот временной слот
                var matchedClass = dayClasses.firstWhere((item) {
                  String start = item['start']?.toString() ?? '';
                  if (start.contains('T')) {
                    String timePart = start.split('T')[1].substring(0, 5); // "HH:MM"
                    return timePart.startsWith(startHourStr.split(':')[0].padLeft(2, '0'));
                  }
                  return false;
                }, orElse: () => {});

                bool hasClass = matchedClass.isNotEmpty;
                final props = matchedClass['extendedProps'] ?? {};

                return Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                  ),
                  child: Row(
                    children: [
                      // Колонка времени слева
                      Container(
                        width: 75,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey.shade400)),
                          color: Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(startHourStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text(endHourStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Блок занятия справа (если есть)
                      Expanded(
                        child: hasClass
                            ? Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade600, // Цвет карточки занятия (как на вашем скриншоте)
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                matchedClass['title'] ?? 'Zajęcia',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Sala: ${props['numersali'] ?? '-'} | ${props['tytulNaukowy'] ?? ''} ${props['imie'] ?? ''} ${props['nazwisko'] ?? ''}",
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                            : Container(
                          color: Colors.green, // Пустой слот (зеленый фон сетки из вашего макета)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}