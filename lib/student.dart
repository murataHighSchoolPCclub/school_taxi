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

  final TextEditingController _localController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Center(
          child: FittedBox(fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(widget.title , style: TextStyle(color: Colors.white), ),
                SizedBox(width: 60,)
              ],
            ),
          ),
        ) ,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        centerTitle: true,

      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 270,
                child: Image.asset('images/school.jpg'),
            ),
            Expanded(
              child: FittedBox(
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
                      }, controller: _localController,
                    ),
                
                    DropdownButtonMenu(
                      title:"学校",
                      list: ["あいう"],
                      value: selectedValue,
                      showError: showError,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          showError = false;
                
                        });
                      }, controller: _localController,
                    ),
                
                    DropdownButtonMenu(
                      title:"ログインID",
                      list: ["あいう"],
                      value: selectedValue,
                      showError: showError,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          showError = false;
                
                        });
                      }, controller: _localController,
                    ),
                
                    DropdownButtonMenu(
                      title:"パスワード",
                      list: ["あいう"],
                      value: selectedValue,
                      showError: showError,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          showError = false;
                
                        });
                      }, controller: _localController,
                    ),
                

                
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox( height: 70,
                            child: ElevatedButton(
                              style:  ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                onPressed: (){
                                  setState(() {
                                    showError = selectedValue == null;
                                  });
                                },
                                child: Text("新規登録", style: TextStyle(color: Colors.white, fontSize: 30),)
                            ),
                          ),
                        ),


                
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox( height: 70,
                            child: ElevatedButton(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                                onPressed: (){
                                  setState(() {
                                    showError = selectedValue == null;
                                  });
                                },
                                child: Text("ログイン", style: TextStyle(color: Colors.white, fontSize: 30)  )
                            ),
                          ),
                        ),
                      ],
                    ),
                
                
                
                
                  ],
                
                
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}