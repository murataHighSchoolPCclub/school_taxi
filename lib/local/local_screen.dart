import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:school_taxi/student/student.dart';
import 'package:school_taxi/student/student_regestration.dart';
import '../class.dart';
import '../button.dart';

class LocalMainPage extends ConsumerStatefulWidget {
  const LocalMainPage({super.key, required this.title ,required this.jititai});

  final String title;
  final String jititai;





  @override
  LocalMainPageState createState() => LocalMainPageState();
}

// SingleTickerProviderStateMixin を追加します
class LocalMainPageState extends ConsumerState<LocalMainPage> with SingleTickerProviderStateMixin {
  String? selectedValue;
  bool showError = false;
  bool _isPriceLocked = true; // 初期状態はロックされていない
  int _priceValue = 0;
  int _monthValue = 0;
  int _yearValue = 0;
  int schoolNumber = 0;

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

  final TextEditingController _localSchoolController = TextEditingController();


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







  final TextEditingController _dropdownController = TextEditingController();




  // TabController を宣言します
  late TabController _tabController;

  final List<RideRecord> sampleRecords = List.generate(
    10, // 10件のサンプルデータ
        (index) => RideRecord(
      date: DateTime.now().subtract(Duration(days: index)),
      vehicle: 'MH1', // 車両はMH1のみ
      distance: 20.5 + (index * 2.3),
      passengers: (index % 4) + 1, // 1から4人
    ),
  );

  @override
  void initState() {
    super.initState();
    // TabController を初期化します
    _tabController = TabController(length: 3, vsync: this);

    super.initState();
    _availableSchoolNames = _registrations.map((info) => info.schoolName).toSet().toList();
    _availableSchoolNames.sort();

    // --- initState で全登録情報数を初期化 ---
    _totalRegistrationsCount = _registrations.length;

    // 初期状態でフィルタリングされた生徒数は0 (または特定の学校を初期選択する場合はその数)
    _filteredStudentsCount = _filteredStudentsBySchool.length;
  }

  @override
  void dispose() {
    // TabController を破棄します
    _tabController.dispose();
    super.dispose();
  }

  void _customAddNewSchool() {
    print("メイン画面: カスタム新規登録アクション！");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('メイン画面：カスタム新規登録が実行されました！')),
    );
    // 実際の処理
  }

  void _customEditSchool(DummyRegistrationInfo? school) {
    if (school != null) {
      print("メイン画面: カスタム編集アクション！対象: ${school.displayString}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メイン画面：カスタム編集 (${school.displayString})が実行されました！')),
      );
      // 実際の処理
    } else {
      print("メイン画面: カスタム編集アクション！対象が選択されていません。");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メイン画面：編集する学校が選択されていません。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        // AppBar の bottom プロパティに TabBar を設定します
        bottom: TabBar(
          controller: _tabController, // 作成した TabController を指定します
          labelColor: Colors.white, // 選択されているタブのテキスト色
          unselectedLabelColor: Colors.white70, // 選択されていないタブのテキスト色
          indicatorColor: Colors.white, // インジケータの色
          tabs: const [
            Tab(text: '自治体'), // 1つ目のタブ
            Tab(text: '学校'), // 2つ目のタブ
            Tab(text: 'タクシー'), // 3つ目のタブ
          ],
        ),
      ),
      // TabBarView を body に設定し、各タブに対応するコンテンツを表示します
      body: TabBarView(
        controller: _tabController, // AppBar と同じ TabController を指定します
        children: <Widget>[
          // タブ 1 のコンテンツ
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せに

              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        '自治体名：${widget.jititai}', // 文字列補間を使用
                        style: TextStyle(fontSize: 27.0),
                      ),
                    ),
                    // このRowウィジェットが配置される親ウィジェット (例: Column の children の一つ) の中で使用します。
                    // 必要な状態変数 (_currentValue, _isPriceLocked) は
                    // LocalMainPageState のメンバとして定義されていることを前提とします。

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // 子ウィジェットを垂直方向の中央に揃える
                      children: [
                        Text(
                          '料金設定：',
                          style: TextStyle(fontSize: 27.0),
                        ),
                        SizedBox(width: 8), // テキストとピッカーの間に少しスペース
                        SizedBox(
                          width: 100, // ピッカーの幅を調整 (例: 100)
                          height: 50, // ピッカーの高さを調整 (例: 120, itemExtent の約3-4倍が目安)
                          child: AbsorbPointer(
                            absorbing: _isPriceLocked,
                            child: Opacity(
                              opacity: _isPriceLocked ? 0.5 : 1.0,
                              child: CupertinoPicker(
                                itemExtent: 30, // 各アイテムの高さ (SizedBoxのheightと関連して調整)

                                scrollController: FixedExtentScrollController(
                                  initialItem: _priceValue ~/ 10, // _currentValueを10で割ったインデックス
                                ),
                                onSelectedItemChanged: (int index) {
                                  if (!_isPriceLocked) {
                                    setState(() {
                                      _priceValue = index * 10;
                                    });
                                  }
                                },
                                looping: true,
                                children: List.generate(101, (i) {
                                  return Center(
                                    child: Text(
                                      '${i * 10}',
                                      style: TextStyle(fontSize: 20.0), // ピッカー内の文字サイズ調整
                                    ),
                                  );
                                }), // 循環スクロールを無効にする場合 (任意)
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // ピッカーと「円」の間に少しスペース
                        Text(
                          '円',
                          style: TextStyle(fontSize: 27.0),
                        ),
                        Spacer(), // 「円」とボタンの間に可変スペースを挿入し、ボタンを右端に寄せる
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isPriceLocked = !_isPriceLocked;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPriceLocked ? Colors.grey[400] : Colors.orange,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            _isPriceLocked ? '解除' : '決定',
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '利用履歴：',
                          style: TextStyle(fontSize: 27.0),
                        ),
                        SizedBox(
                          width: 80,
                          height: 50,
                          child: CupertinoPicker(
                            itemExtent: 30,

                            scrollController: FixedExtentScrollController(initialItem: 0),

                            children: List.generate(6, (i) => Center(child: Text('${i+2025}'))),
                            onSelectedItemChanged: (value) {
                              setState(() {
                                _yearValue = value;
                              });
                            },

                          ),
                        ),
                        Text(
                          '年',
                          style: TextStyle(fontSize: 27.0),
                        ),
                        SizedBox(
                          width: 60,
                          height: 50,
                          child: CupertinoPicker(
                            itemExtent: 30,
                            scrollController: FixedExtentScrollController(initialItem: 0),

                            children: List.generate(12, (i) => Center(child: Text('${i+1}'))),
                            onSelectedItemChanged: (value) {
                              setState(() {
                                _monthValue = value;
                              });
                            },

                          ),
                        ),
                        Text(
                          '月',
                          style: TextStyle(fontSize: 27.0),
                        ),




                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    ScrollableRideTable(records: sampleRecords),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        '自治体→MHタクシー：', // 文字列補間を使用
                        style: TextStyle(fontSize: 27.0),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        '自治体→KHタクシー：', // 文字列補間を使用
                        style: TextStyle(fontSize: 27.0),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        '利用者→自治体：', // 文字列補間を使用
                        style: TextStyle(fontSize: 27.0),
                      ),
                    ),
                  ],
                ),







              ],
            ),
          ),
          // タブ 2 のコンテンツ
          SingleChildScrollView(
            child: Column(
              children: [
                StaticSchoolInfoTabContent(


                ),


              ],
            ),

          ),


          // タブ 3 のコンテンツ
          SingleChildScrollView(
            child: Column(
              children: [
                StaticTaxiInfoTabContent(


                ),


              ],
            ),

          ),
        ],
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
}
