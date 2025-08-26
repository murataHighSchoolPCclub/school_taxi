import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/class.dart';

import '../student/student_regestration.dart';

import '../button.dart';
import 'local_screen.dart';

class NewSchoolCreationPage extends StatefulWidget {
  const NewSchoolCreationPage({Key? key}) : super(key: key);

  @override
  _NewSchoolCreationPageState createState() => _NewSchoolCreationPageState();
}

class _NewSchoolCreationPageState extends State<NewSchoolCreationPage> {
  final _formKey = GlobalKey<FormState>(); // フォームの状態を管理するキー

  // 各入力フィールド用のコントローラー
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _schoolNameController.dispose();
    _idController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) { // フォームのバリデーションを実行
      // バリデーションが通ったら新しい学校情報を作成
      final newSchoolInfo = RegistrationInfo(
        id: _idController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
      );

      // 作成した情報を結果として前の画面に返す
      Navigator.of(context).pop(newSchoolInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規学校作成'),
        backgroundColor: Colors.orange, // テーマに合わせる
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // ボタンを横幅いっぱいに
            children: <Widget>[
              Text(
                '新しい学校の情報を入力してください:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _schoolNameController,
                decoration: InputDecoration(
                  labelText: '学校名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '学校名を入力してください。';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '学校ID',
                  hintText: '例: sakurasho',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.perm_identity),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '学校IDを入力してください。';
                  }
                  // 必要であれば、IDの形式や重複チェックのバリデーションも追加
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: '電話番号',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '電話番号を入力してください。';
                  }
                  // 簡単な電話番号形式のチェック (例)
                  // if (!RegExp(r'^\d{2,4}-\d{2,4}-\d{3,4}$').hasMatch(value.trim())) {
                  //   return '有効な電話番号の形式で入力してください (例: 090-1234-5678)';
                  // }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '住所',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '住所を入力してください。';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('登録する'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


