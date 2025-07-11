import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student_regestration.dart';

import 'button.dart';

class TaxiDriverPage extends ConsumerStatefulWidget {
  const TaxiDriverPage({super.key, required this.title});

  final String title;

  @override
  TaxiDriverPageState createState() => TaxiDriverPageState();
}
class TaxiDriverPageState extends ConsumerState<TaxiDriverPage> {
  String? selectedValue;
  bool showError=false;

  final TextEditingController _localController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title , style: TextStyle( color: Colors.white,)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),

      ),


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              child: Image.asset('images/taxi_driver.jpg'),
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
                    }, controller: _localController,
                  ),

                  DropdownButtonMenu(
                    title:"学校",
                    list: ["あう"],
                    value: selectedValue,
                    showError: showError,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        showError = false;

                      });
                    }, controller: _schoolController,
                  ),

                  DropdownButtonMenu(
                    title:"ログインID",
                    list: ["あs"],
                    value: selectedValue,
                    showError: showError,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        showError = false;

                      });
                    }, controller: _loginController,
                  ),

                  DropdownButtonMenu(
                    title:"パスワード",
                    list: ["あい"],
                    value: selectedValue,
                    showError: showError,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        showError = false;

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
                                showError = selectedValue == null;
                              });
                            },
                            child: Text("新規登録", style: TextStyle(color: Colors.white, fontSize: 30),)
                        ),
                      ),

                      SizedBox( height: 70,
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