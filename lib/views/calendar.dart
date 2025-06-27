import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProviderCalendar extends StatefulWidget {
  const ProviderCalendar({super.key});

  @override
  State<ProviderCalendar> createState() => _ProviderCalendarState();
}

class _ProviderCalendarState extends State<ProviderCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TableCalendar<String>(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  title: Text('No events for this day'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
