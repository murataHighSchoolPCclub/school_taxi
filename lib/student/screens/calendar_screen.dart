
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reservation_form.dart';

class CalendarScreen extends StatefulWidget {
  CalendarScreen({super.key, required this.userId});
  final String userId;

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _events = <DateTime, List<String>>{};
  DateTime _focused = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final snap = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: widget.userId)
        .get();

    final ev = <DateTime, List<String>>{};
    for (var d in snap.docs) {
      final m = d.data();
      final dates = List<String>.from(m['dates']).map(DateTime.parse);
      for (var dt in dates) {
        final k = DateTime(dt.year, dt.month, dt.day);
        ev.putIfAbsent(k, () => []);
        if (m['goSchool'] == true) {
          ev[k]!.add('go'); // 登校マーク
        }
        if (m['backSchool'] == true) {
          final t = m['backTime'] ?? '';
          ev[k]!.add('back:$t'); // 下校と時間
        }
      }
    }
    setState(() => _events
      ..clear()
      ..addAll(ev));
  }

  Future<Map<String, dynamic>?> _fetchReservationFor(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final snap = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: widget.userId)
        .where('dates', arrayContains: dateStr)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      return {'id': doc.id, ...doc.data()};
    } else {
      return null;
    }
  }

  Future<void> _openForm(DateTime date) async {
    final k = DateTime(date.year, date.month, date.day);
    final old = await _fetchReservationFor(k);

    final res = await showModalBottomSheet(
      context: context,
      builder: (_) => ReservationForm(
        selectedDate: k,
        goSchool: old?['goSchool'] ?? false,
        backSchool: old?['backSchool'] ?? false,
        backTime: old?['backTime'],
      ),
    );

    if (res != null) {
      final id = old?['id'];
      final docRef = id != null
          ? FirebaseFirestore.instance.collection('reservations').doc(id)
          : FirebaseFirestore.instance.collection('reservations').doc();

      await docRef.set({
        'userId': widget.userId,
        'dates': [k.toIso8601String().substring(0, 10)],
        'goSchool': res['goSchool'],
        'backSchool': res['backSchool'],
        'backTime': res['backTime'],
        'createdAt': DateTime.now(),
      });

      await _loadEvents();
    }
  }

  @override
  Widget build(BuildContext c) => Column(
    children: [
      TableCalendar(
        locale: 'ja_JP',
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focused,
        onDaySelected: (d, f) {
          setState(() {
            _openForm(d);
            _focused = f;
          });
        },
        rowHeight: 80,
        headerStyle: HeaderStyle(titleCentered: true, titleTextStyle: TextStyle(fontSize: 30), formatButtonVisible: false),
        daysOfWeekHeight: 32,
        daysOfWeekStyle: DaysOfWeekStyle(decoration: BoxDecoration(border: Border.all(color: Colors.grey))),
        calendarBuilders: CalendarBuilders(
          outsideBuilder: (ctx, d, f) {
            return Container(
              width: MediaQuery.of(context).size.width * 1 / 7,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                border: Border.all(color: Colors.grey),
              ),
              child: Center(child: Text('${d.day}',style: TextStyle(color: Colors.grey))),
            );
          },
          todayBuilder: (ctx, d, f) {
            final k = DateTime(d.year, d.month, d.day);
            final texts = _events[k] ?? [];
            return Container(
              width: MediaQuery.of(context).size.width * 1 / 7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
              ),
              child: Column(children: [
                Text('${d.day}'),
                if (texts.contains('go'))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Center(child: Text('登校', style: TextStyle(fontSize: 10))),
                    ),
                  ),
                if (texts.any((e) => e.startsWith('back')))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Text(
                          '下校\n${texts.firstWhere((e) => e.startsWith('back')).split(':')[1]}:${texts.firstWhere((e) => e.startsWith('back')).split(':')[2]}',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ]),
            );
          },
          defaultBuilder: (ctx, d, f) {
            final k = DateTime(d.year, d.month, d.day);
            final texts = _events[k] ?? [];
            return Container(
              width: MediaQuery.of(context).size.width * 1 / 7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(children: [
                Text('${d.day}'),
                if (texts.contains('go'))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Center(child: Text('登校', style: TextStyle(fontSize: 10))),
                    ),
                  ),
                if (texts.any((e) => e.startsWith('back')))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Text(
                          '下校\n${texts.firstWhere((e) => e.startsWith('back')).split(':')[1]}:${texts.firstWhere((e) => e.startsWith('back')).split(':')[2]}',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ]),
            );
          },
          selectedBuilder: (ctx, d, f) {
            final k = DateTime(d.year, d.month, d.day);
            final texts = _events[k] ?? [];
            return Container(
              width: MediaQuery.of(context).size.width * 1 / 7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(child: Text('${d.day}'))
                ),
                ...texts.map((t) => Container(
                    width: MediaQuery.of(context).size.width * 1 / 8,
                    margin: EdgeInsets.only(top: 2),
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 10), textAlign: TextAlign.center)
                ),
                ),
              ]),
            );
          },
        ),
      ),
    ],
  );
}