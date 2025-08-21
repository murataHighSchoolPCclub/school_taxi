import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/class.dart';

import '../student/student_regestration.dart';

import '../button.dart';
import 'local_screen.dart';

class LocalSchoolPage extends ConsumerStatefulWidget {
  const LocalSchoolPage({super.key, required this.title});

  final String title;

  @override
  LocalSchoolPageState createState() => LocalSchoolPageState();
}
class LocalSchoolPageState extends ConsumerState<LocalSchoolPage> {
  final TextEditingController _localSchoolController = TextEditingController();

  String? selectedValue;
  RegistrationInfo? _selectedRegistration;

  final TextEditingController _individualDropdownController = TextEditingController();
  RegistrationInfo? _selectedIndividualRegistration;

  void _updateStudentListForSelectedSchool(String? schoolName) {
    setState(() { // UIの再描画をトリガーするために setState を呼び出す
      // 1. 選択された学校名を状態変数に保存
      _selectedSchoolName = schoolName;

      // 2. 選択された学校名に基づいて生徒リストをフィルタリング
      if (schoolName != null && schoolName.isNotEmpty) {
        // _registrations リスト (全生徒情報) から、
        // schoolName プロパティが選択された学校名と一致する要素のみを抽出して新しいリストを作成
        _filteredStudentsBySchool = _registrations
            .where((info) => info.schoolName == schoolName)
            .toList();
      } else {
        // 学校名が選択されていない (null または空文字の) 場合は、
        // 表示する生徒リストを空にする
        _filteredStudentsBySchool = [];
      }
      _filteredStudentsCount = _filteredStudentsBySchool.length;
    });
  }

  // 学校名を選択するためのコントローラーと状態
  final TextEditingController _schoolDropdownController = TextEditingController();
  String? _selectedSchoolName; // 選択された学校名を保持

  final List<RegistrationInfo> _registrations = [
    RegistrationInfo(id: 'natori', phoneNumber: '090-1234-5678', address: '東京都千代田区1-1-1', schoolName: '名取高校'),
    RegistrationInfo(id: 'siroisi', phoneNumber: '080-8765-4321', address: '大阪府大阪市中央区2-2-2', schoolName: '白石高校'),
    RegistrationInfo(id: 'sibata', phoneNumber: '070-1122-3344', address: '愛知県名古屋市中村区3-3-3', schoolName: '柴田高校'),
    RegistrationInfo(id: 'murata', phoneNumber: '090-5555-0000', address: '北海道札幌市北区4-4-4', schoolName: '村田高校'),
  ];

  List<String> _availableSchoolNames = [];

  // 選択された学校の生徒リスト
  List<RegistrationInfo> _filteredStudentsBySchool = [

  ];

  int _totalRegistrationsCount = 0; // 全登録情報数
  int _filteredStudentsCount = 0;   // フィルタリングされた生徒数

  @override
  void initState() {
    super.initState();
    _availableSchoolNames = _registrations.map((info) => info.schoolName).toSet().toList();
    _availableSchoolNames.sort();

    // --- initState で全登録情報数を初期化 ---
    _totalRegistrationsCount = _registrations.length;

    // 初期状態でフィルタリングされた生徒数は0 (または特定の学校を初期選択する場合はその数)
    _filteredStudentsCount = _filteredStudentsBySchool.length;
  }





  final TextEditingController _dropdownController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '登録情報',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: SingleChildScrollView( // コンテンツが多くなる可能性があるので SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. 個別登録情報の選択セクション (既存の機能) ---
            Text(
              '個別の登録情報を選択してください:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            DropdownMenu<RegistrationInfo>(
              controller: _individualDropdownController,
              expandedInsets: EdgeInsets.zero,
              label: const Text('個人を選択'),
              initialSelection: _selectedIndividualRegistration,
              dropdownMenuEntries: _registrations.map((RegistrationInfo info) {
                return DropdownMenuEntry<RegistrationInfo>(
                  value: info,
                  label: info.displayString, // 例: "090-0001-0001 - 第一小学校"
                );
              }).toList(),
              onSelected: (RegistrationInfo? newValue) {
                setState(() {
                  _selectedIndividualRegistration = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            // 選択された個別の情報を表示するセクション
            if (_selectedIndividualRegistration != null)
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '選択された個人の情報:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow(Icons.phone, '電話番号: ', _selectedIndividualRegistration!.phoneNumber),
                      _buildInfoRow(Icons.location_on, '住所: ', _selectedIndividualRegistration!.address),
                      _buildInfoRow(Icons.account_balance, '学校名: ', _selectedIndividualRegistration!.schoolName),
                      _buildInfoRow(Icons.perm_identity, 'ID: ', _selectedIndividualRegistration!.id),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '上のドロップダウンから個人の情報を選択してください。',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

            Divider(thickness: 1.5, height: 40), // 区切り線

            // --- 2. 学校を選択して生徒リストを表示するセクション (新しい機能) ---
            Text(
              '学校を選択して生徒一覧を表示:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            if (_availableSchoolNames.isNotEmpty)
              DropdownMenu<String>( // 学校名は文字列で選択
                controller: _schoolDropdownController,
                expandedInsets: EdgeInsets.zero,
                label: const Text('学校を選択'),
                initialSelection: _selectedSchoolName,
                dropdownMenuEntries: _availableSchoolNames.map((String schoolName) {
                  return DropdownMenuEntry<String>(
                    value: schoolName,
                    label: schoolName,
                  );
                }).toList(),
                onSelected: (String? newValue) {
                  _updateStudentListForSelectedSchool(newValue);
                },
              )
            else
              Text('登録されている学校がありません。'),

            SizedBox(height: 20),

            // 選択された学校の生徒リスト表示
            if (_selectedSchoolName != null && _selectedSchoolName!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedSchoolName}の生徒一覧 (${_filteredStudentsBySchool.length}名):',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (_filteredStudentsBySchool.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true, // SingleChildScrollView の中で使うため
                      physics: NeverScrollableScrollPhysics(), // SingleChildScrollView の中で使うため
                      itemCount: _filteredStudentsBySchool.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudentsBySchool[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            leading: CircleAvatar(child: Text(student.id.substring(0,1).toUpperCase())),
                            title: Text(student.phoneNumber),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("住所: ${student.address}"),
                                // Text("ID: ${student.id}"), // 必要ならIDも
                              ],
                            ),
                            // タップで個別情報にフォーカスするなども可能
                            // onTap: () {
                            //   setState(() {
                            //     _selectedIndividualRegistration = student;
                            //     // _individualDropdownController.text = student.displayString; // 更新は難しいかも
                            //   });
                            // },
                          ),
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('この学校には登録されている生徒がいません。'),
                    ),
                ],
              )
            else if (_availableSchoolNames.isNotEmpty) // 学校は選択できるが、まだ何も選択していない場合
              Text(
                '上のドロップダウンから学校を選択してください。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _individualDropdownController.dispose();
    _schoolDropdownController.dispose();
    super.dispose();
  }
}


