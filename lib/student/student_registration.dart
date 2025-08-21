import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student/student.dart';

import 'student_reserve.dart';

import '../button.dart';

class StudentRegistrationPage extends ConsumerStatefulWidget {
  const StudentRegistrationPage({super.key, required this.title});

  final String title;

  @override
  StudentRegistrationPageState createState() => StudentRegistrationPageState();
}
class StudentRegistrationPageState extends ConsumerState<StudentRegistrationPage> {
  String? selectedValue1;
  String? selectedValue2;
  String? selectedValue3;
  String? selectedValue4;
  String? selectedValue5;

  bool showError1=false;
  bool showError2=false;
  bool showError3=false;
  bool showError4=false;
  bool showError5=false;
  
  


  final TextEditingController _localController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _invitationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title , style: TextStyle( color: Colors.white,)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),

      ),


      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    list: ["村田高校"],
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
                    list: ["guest"],
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
                    list: ["password"],
                    value: selectedValue4,
                    showError: showError4,
                    onChanged: (value) {
                      setState(() {
                        selectedValue4 = value;
                        showError4 = false;

                      });
                    }, controller: _passwordController,
                  ),

                  DropdownButtonMenu(
                    title:"招待コード",
                    list: ["invitation"],
                    value: selectedValue5,
                    showError: showError5,
                    onChanged: (value) {
                      setState(() {
                        selectedValue5 = value;
                        showError5 = false;

                      });
                    }, controller: _invitationController,
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
                                showError3 = selectedValue3 == null;
                                showError4 = selectedValue4 == null;
                                showError5 = selectedValue5 == null;
                              });
                              if(!(selectedValue1 == null ||
                                  selectedValue2 == null ||
                                  selectedValue3 == null ||
                                  selectedValue4 == null ||
                                  selectedValue5 == null )){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPage(title: "生徒")));

                              }
                            },
                            child: Text("新規登録", style: TextStyle(color: Colors.white, fontSize: 30),)
                        ),
                      ),

                    ],
                  ),




                ],


              )
            ],
          ),
        ),
      ),
    );
  }
}