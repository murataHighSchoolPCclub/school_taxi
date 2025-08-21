import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student/student.dart';
import 'package:school_taxi/student/student_registration.dart';
import 'package:school_taxi/student/student_reserve.dart';

import '../button.dart';
import 'local_login.dart';
import 'local_screen.dart';

class LocalPage extends ConsumerStatefulWidget {
  const LocalPage({super.key, required this.title});

  final String title;

  @override
  LocalPageState createState() => LocalPageState();
}
class LocalPageState extends ConsumerState<LocalPage> {
  String? selectedValue1;
  String? selectedValue2;
  String? selectedValue3;
  String? selectedValue4;

  bool showError1=false;
  bool showError2=false;
  bool showError3=false;
  bool showError4=false;

  final TextEditingController _localController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title , style: TextStyle(color: Colors.white,)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),

      ),


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              child: Image.asset('images/local.jpg'),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  DropdownButtonMenu(
                    title:"自治体名",
                    list: ["宮城県村田町"],
                    value: selectedValue1,
                    showError: showError1,
                    onChanged: (value) {
                      setState(() {
                        selectedValue1 = value;
                        showError1 = false;

                      });
                    }, controller: _localController,
                  ),

                  DropdownButtonMenu(
                    title:"学校",
                    list: ["あう"],
                    value: selectedValue2,
                    showError: showError2,
                    onChanged: (value) {
                      setState(() {
                        selectedValue2 = value;
                        showError2 = false;

                      });
                    }, controller: _schoolController,
                  ),

                  DropdownButtonMenu(
                    title:"ログインID",
                    list: ["あs"],
                    value: selectedValue3,
                    showError: showError3,
                    onChanged: (value) {
                      setState(() {
                        selectedValue3 = value;
                        showError3 = false;

                      });
                    }, controller: _loginController,
                  ),

                  DropdownButtonMenu(
                    title:"パスワード",
                    list: ["あい"],
                    value: selectedValue4,
                    showError: showError4,
                    onChanged: (value) {
                      setState(() {
                        selectedValue4 = value;
                        showError4 = false;

                      });
                    }, controller: _passwordController,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      SizedBox( height: 70,
                        child: ElevatedButton(
                            style:  ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                            onPressed: (){
                              setState(() {
                                showError1 = selectedValue1 == null;
                                showError2 = selectedValue2 == null;
                              });
                              if(!(selectedValue1 == null ||
                                  selectedValue2 == null )){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LocalLoginPage(title: "新規登録")));
                              }
                            },
                            child: Text("新規登録", style: TextStyle(color: Colors.white, fontSize: 30),)
                        ),
                      ),

                      SizedBox( height: 70,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                            onPressed: (){
                              setState(() {
                                showError1 = selectedValue1 == null;
                                showError2 = selectedValue2 == null;
                                showError3 = selectedValue3 == null;
                                showError4 = selectedValue4 == null;
                              });
                              if(!(selectedValue1 == null ||
                                  selectedValue2 == null ||
                                  selectedValue3 == null ||
                                  selectedValue4 == null )){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LocalMainPage(title: "管理画面", jititai: '$selectedValue1',)));

                              }
                            },
                            child: Text("ログイン", style: TextStyle(color: Colors.white, fontSize: 30)  )
                        ),
                      ),
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