import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student/screens/calendar_screen.dart';

class StudentReservePage extends ConsumerStatefulWidget {
  const StudentReservePage({super.key, required this.title});

  final String title;

  @override
  StudentReservePageState createState() => StudentReservePageState();
}

class StudentReservePageState extends ConsumerState<StudentReservePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: 60,
          title: Center(
            child: FittedBox(fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 30, color: Colors.white)),
                    SizedBox(width: 60,),
                  ],
                )
            ),
          ),
        ),
        body: CalendarScreen(userId: "dummyUserId")
    );
  }
}