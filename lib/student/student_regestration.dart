import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StudentRegestrationPage extends ConsumerStatefulWidget {
  const StudentRegestrationPage({super.key, required this.title});

  final String title;

  @override
  StudentRegestrationPageState createState() => StudentRegestrationPageState();
}

class StudentRegestrationPageState extends ConsumerState<StudentRegestrationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CalendarWithLocalStorage(),

      // ← カレンダーを表示
    );


  }
}

class CalendarWithLocalStorage extends StatefulWidget {
  @override
  _CalendarWithLocalStorageState createState() =>
      _CalendarWithLocalStorageState();
}

class _CalendarWithLocalStorageState extends State<CalendarWithLocalStorage> {
  DateTime _selectedDay = DateTime.now();
  Map<String, List<String>> _reservations = {};

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('reservations');
    if (jsonStr != null) {
      setState(() {
        _reservations = Map<String, List<String>>.from(
          json.decode(jsonStr).map((k, v) => MapEntry(k, List<String>.from(v))),
        );
      });
    }
  }

  Future<void> _saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_reservations);
    await prefs.setString('reservations', jsonStr);
  }

  Future<void> _selectTime(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final taken = _reservations[dateKey] ?? [];

    final selectedTime = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('${DateFormat('y/MM/dd (E)','ja_JP').format(date)}  時間を選択'),
        children: List.generate(14, (i) {
          final hour = i + 6;
          final time = '${hour.toString().padLeft(2, '0')}:00';
          final isTaken = taken.contains(time);
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, time),
            child: Text(
              time + (isTaken ? "（予約済み）" : ""),
              style: TextStyle(color: isTaken ? Colors.red : Colors.black),
            ),
          );
        }),
      ),
    );

    if (selectedTime != null) {
      final isTaken = taken.contains(selectedTime);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(isTaken ? "キャンセル確認" : "予約確認"),
          content: Text(
              '${DateFormat('yyyy/MM/dd (EEEE)', 'ja_JP').format(date)} $selectedTime を${isTaken ? "キャンセル" : "予約"}しますか？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('戻る')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isTaken ? 'キャンセル' : '予約'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() {
          final list = _reservations[dateKey] ?? [];
          if (isTaken) {
            list.remove(selectedTime);
          } else {
            list.add(selectedTime);
          }
          _reservations[dateKey] = list;
        });
        await _saveReservations();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$selectedTime を${isTaken ? "キャンセル" : "予約"}しました'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2050, 1, 1),

            focusedDay: _selectedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final key = DateFormat('yyyy-MM-dd').format(date);
                if (_reservations[key]?.isNotEmpty ?? false) {
                  return Positioned(
                    bottom: 1,
                    child: Icon(Icons.text_fields, size: 6, color: Colors.green),
                  );
                }
                return null;
              },
            ),
            onDaySelected: (selected, _) {
              setState(() => _selectedDay = selected);
              _selectTime(selected);
            },
          ),
        ),
      ],
    );
  }
}