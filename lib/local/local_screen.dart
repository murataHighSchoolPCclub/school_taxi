import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_taxi/student/student.dart';
import 'package:school_taxi/student/student_reserve.dart';

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
  bool _isPriceLocked = false; // 初期状態はロックされていない
  int _currentValue = 0;

  final TextEditingController _localController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // TabController を宣言します
  late TabController _tabController;

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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 左寄せに

                  children: [

                    Text(
                      '自治体名：${widget.jititai}', // 文字列補間を使用
                      style: TextStyle(fontSize: 27.0),
                    ),
                  ],
                ),
              )
            ],
          ),
          // タブ 2 のコンテンツ
          Center(
            child: Text('タブ 2 のコンテンツ'),
          ),
          // タブ 3 のコンテンツ
          Center(
            child: Text('タブ 3 のコンテンツ'),
          ),
        ],
      ),
    );
  }
}
