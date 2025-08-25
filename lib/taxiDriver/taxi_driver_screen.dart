import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/button.dart';
import 'package:school_taxi/taxiDriver/taxi_driver_map.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../student/screens/calendar_screen.dart';



class TaxiDriverMainPage extends ConsumerStatefulWidget {
  const TaxiDriverMainPage({super.key, required this.title});

  final String title;

  @override
  TaxiDriverMainPageState createState() => TaxiDriverMainPageState();
}

class TaxiDriverMainPageState extends ConsumerState<TaxiDriverMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Center(
              child:
              CalendarScreen(userId: "dummyUserId")

          ),
          NavigateButton(title: '本日のルート', next: TaxiDriverMapPage(title: '本日のルート'), buttonColor: Colors.green, textColor: Colors.white)
        ],
      ) // ← カレンダーを表示

    );
  }
}

