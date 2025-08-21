import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:school_taxi/local/local_school.dart';
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
  }

  @override
  void dispose() {
    // TabController を破棄します
    _tabController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '登録済みの学校：$schoolNumber',
                  style: TextStyle(fontSize: 27.0),
                ),
                NavigateButton(
                    title: '登録済みの学校',
                    next: LocalSchoolPage(title: '登録学校詳細',),
                    buttonColor: Colors.orange,
                    textColor: Colors.white
                ),

              ],
            ),
          ),

          // タブ 3 のコンテンツ
          SingleChildScrollView(
            child: Center(
              child: Text('タブ 3 のコンテンツ'),
            ),
          ),
        ],
      ),
    );
  }
}
