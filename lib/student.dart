import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student_regestration.dart';

import 'button.dart';

class StudentPage extends ConsumerStatefulWidget {
  const StudentPage({super.key, required this.title});

  final String title;

  @override
  StudentPageState createState() => StudentPageState();
}
class StudentPageState extends ConsumerState<StudentPage> {
  String? selectedValue;
  bool showError=false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text(widget.title) ,),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
                child: Image.asset('images/school.jpg'),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  DropdownButtonMenu(
                    title:"自治体名",
                    list: ["あいう"],
                    value: selectedValue,
                    showError: showError,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        showError = false;

                      });
                    },
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                      onPressed: (){
                        setState(() {
                          showError = selectedValue == null;
                        });
                      },
                      child: Text("新規登録")
                  ),
                  


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 70,
                        width: MediaQuery.of(context).size.width * 1/3,
                          child: NavigateButton(title: "新規登録", next: StudentRegestrationPage(title: "新規登録"), buttonColor: Colors.red, textColor: Colors.white)),
                      SizedBox(
                          height: 70,
                          width: MediaQuery.of(context).size.width * 1/3,
                          child: NavigateButton(title: "ログイン", next: StudentRegestrationPage(title: "ログイン"), buttonColor: Colors.blue, textColor: Colors.white)),
                    ],
                  ),
                ],


              ),
            )
          ],
        ),
      ),
    );
  }
}