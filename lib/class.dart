import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat を使うために必要

// データモデル (前のステップで定義)
class RideRecord {
  final DateTime date;
  final String vehicle;
  final double distance;
  final int passengers;

  RideRecord({
    required this.date,
    required this.vehicle,
    required this.distance,
    required this.passengers,
  });
}

class ScrollableRideTable extends StatefulWidget {
  final List<RideRecord> records;

  const ScrollableRideTable({Key? key, required this.records}) : super(key: key);

  @override
  _ScrollableRideTableState createState() => _ScrollableRideTableState();
}

class _ScrollableRideTableState extends State<ScrollableRideTable> {
  final DateFormat _dateFormatter = DateFormat('yyyy/MM/dd');
  final double _rowHeight = 50.0; // 各行の高さ (調整可能)
  final int _visibleRows = 5;    // 表示する行数

  // 各列の幅の割合 (TableColumnWidth.fraction) を指定
  final Map<int, TableColumnWidth> _columnWidths = {
    0: FractionColumnWidth(0.25), // 日付
    1: FractionColumnWidth(0.20), // 車両
    2: FractionColumnWidth(0.30), // 運行距離
    3: FractionColumnWidth(0.25), // 乗車人数
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        _buildScrollableBody(),
      ],
    );
  }

  // ヘッダー行を構築
  Widget _buildHeader() {
    return Table(
      columnWidths: _columnWidths,
      border: TableBorder(
        horizontalInside: BorderSide(width: 1, color: Colors.grey.shade300),
        bottom: BorderSide(width: 2, color: Colors.grey.shade600), // ヘッダーの下線を太く
      ),
      children: [
        TableRow(
          children: [
            _buildHeaderCell('日付'),
            _buildHeaderCell('車両'),
            _buildHeaderCell('運行距離'),
            _buildHeaderCell('乗車人数'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      height: _rowHeight,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // スクロール可能なデータ行部分を構築
  Widget _buildScrollableBody() {
    if (widget.records.isEmpty) {
      return Container(
        height: _rowHeight * _visibleRows,
        alignment: Alignment.center,
        child: Text('データがありません'),
      );
    }

    return SizedBox(
      height: _rowHeight * _visibleRows, // 表示する行数分の高さを確保
      child: SingleChildScrollView(
        child: Table(
          columnWidths: _columnWidths,
          border: TableBorder.all(width: 1, color: Colors.grey.shade300), // セルごとの罫線
          children: widget.records.map((record) {
            return TableRow(
              children: [
                _buildDataCell(_dateFormatter.format(record.date)),
                _buildDataCell(record.vehicle),
                _buildDataCell('${record.distance.toStringAsFixed(1)} km'),
                _buildDataCell('${record.passengers} 人'),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      height: _rowHeight,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      alignment: Alignment.center, // データも中央揃えにする場合
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}




/// 登録情報を表現するデータクラスです。
class RegistrationInfo {
  /// 一意の識別子。
  final String id;

  /// 電話番号。
  final String phoneNumber;

  /// 住所。
  final String address;

  final String schoolName;

  /// [RegistrationInfo] の新しいインスタンスを作成します。
  ///
  /// すべてのパラメータは必須です。
  RegistrationInfo({
    required this.id,
    required this.phoneNumber,
    required this.address,
    required this.schoolName,
  });

  /// DropdownMenuなどのUIコンポーネントで表示するための整形済み文字列を返します。
  ///
  /// 例: "090-1111-1111 - 東京都渋谷区..."
  String get displayString => '$phoneNumber - $schoolName';

  /// このオブジェクトが他のオブジェクトと等しいかどうかを判断します。
  ///
  /// [id] プロパティが一致する場合に true を返します。
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 同じインスタンスなら true
    return other is RegistrationInfo && // 型が同じか
        runtimeType == other.runtimeType &&
        id == other.id; // id が同じか
  }

  /// このオブジェクトのハッシュコードを返します。
  ///
  /// [id] のハッシュコードに基づいています。
  @override
  int get hashCode => id.hashCode;
}







// ダミーデータモデル (ウィジェット内で使用)


// ダミーデータモデル
class DummyRegistrationInfo {
  final String id;
  final String displayString;
  final String phoneNumber;
  final String address;
  final String schoolName;

  DummyRegistrationInfo({
    required this.id,
    required this.displayString,
    this.phoneNumber = "090-xxxx-xxxx",
    this.address = "ダミー住所",
    this.schoolName = "ダミー学校名",
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DummyRegistrationInfo &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class StaticSchoolInfoTabContent extends StatefulWidget {
  // オプションで外部からFABのアクションを注入できるようにする
  final VoidCallback? onAddPressed;
  final ValueChanged<DummyRegistrationInfo?>? onEditPressed; // 編集対象を渡せるようにする

  const StaticSchoolInfoTabContent({
    Key? key,
    this.onAddPressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  _StaticSchoolInfoTabContentState createState() =>
      _StaticSchoolInfoTabContentState();
}

class _StaticSchoolInfoTabContentState
    extends State<StaticSchoolInfoTabContent> {
  final List<DummyRegistrationInfo> _dummySchools = [
    DummyRegistrationInfo(id: 's_001', schoolName: 'さくら小学校', displayString: 'さくら小学校 (03-1234-xxxx)', phoneNumber: '03-1234-5678', address: '東京都さくら区1-1'),
    DummyRegistrationInfo(id: 's_002', schoolName: 'ひまわり中学校', displayString: 'ひまわり中学校 (045-987-xxxx)', phoneNumber: '045-987-6543', address: '神奈川県ひまわり市2-2'),
    DummyRegistrationInfo(id: 's_003', schoolName: 'もみじ高等学校', displayString: 'もみじ高等学校 (048-111-xxxx)', phoneNumber: '048-111-2222', address: '埼玉県もみじ市3-3'),
  ];

  DummyRegistrationInfo? _selectedSchool;
  List<DummyRegistrationInfo> _dummyStudents = [];

  @override
  void initState() {
    super.initState();
    if (_dummySchools.isNotEmpty) {
      _selectedSchool = _dummySchools.first;
      _updateDummyStudents(_selectedSchool);
    }
  }

  void _updateDummyStudents(DummyRegistrationInfo? school) {
    if (school == null) {
      _dummyStudents = [];
    } else {
      _dummyStudents = [
        DummyRegistrationInfo(
            id: '${school.id}_student1',
            schoolName: school.schoolName,
            displayString: '${school.schoolName} 生徒X',
            phoneNumber: '090-XXXX-001X',
            address: '${school.address} 学生寮X'),
        DummyRegistrationInfo(
            id: '${school.id}_student2',
            schoolName: school.schoolName,
            displayString: '${school.schoolName} 生徒Y',
            phoneNumber: '090-YYYY-001Y',
            address: '${school.address} 学生寮Y'),
      ];
    }
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold を削除し、UIコンテンツのルートを返す
    // (このウィジェットは TabBarView の children に直接配置されることを想定)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '学校の登録情報を選択してください:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          DropdownMenu<DummyRegistrationInfo>(
            width: MediaQuery.of(context).size.width - 40, // 幅を明示的に指定
            label: const Text('学校を選択'),
            initialSelection: _selectedSchool,
            dropdownMenuEntries:
            _dummySchools.map((DummyRegistrationInfo school) {
              return DropdownMenuEntry<DummyRegistrationInfo>(
                value: school,
                label: school.displayString,
              );
            }).toList(),
            onSelected: (DummyRegistrationInfo? newValue) {
              setState(() {
                _selectedSchool = newValue;
                _updateDummyStudents(newValue);
              });
              print('選択された学校: ${newValue?.displayString}');
            },
          ),
          SizedBox(height: 20),
          if (_selectedSchool != null)
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('選択された学校の情報:',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    _buildInfoRow(context, Icons.phone, '電話番号: ',
                        _selectedSchool!.phoneNumber),
                    _buildInfoRow(context, Icons.location_on, '住所: ',
                        _selectedSchool!.address),
                    _buildInfoRow(context, Icons.account_balance, '学校名: ',
                        _selectedSchool!.schoolName),
                    _buildInfoRow(
                        context, Icons.perm_identity, 'ID: ', _selectedSchool!.id),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom:20.0, top: 10.0),
              child: Text("学校を選択してください。", style: Theme.of(context).textTheme.bodyLarge),
            ),
          Divider(thickness: 1.5, height: 40),
          Text('選択した学校の生徒一覧を表示:',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          if (_selectedSchool != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_selectedSchool?.schoolName ?? "学校"}の生徒一覧 (${_dummyStudents.length}名):',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                if (_dummyStudents.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _dummyStudents.length,
                    itemBuilder: (context, index) {
                      final student = _dummyStudents[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                            leading: CircleAvatar(
                                child: Text(student.id.isNotEmpty ? student.id.substring(student.id.length -2, student.id.length).toUpperCase() : "・" )),
                            title: Text(student.displayString),
                            subtitle: Text("電話: ${student.phoneNumber}\n住所: ${student.address}"),
                            onTap: () {
                              print('ダミー生徒タップ: ${student.displayString}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${student.displayString} さんがタップされました。')),
                              );
                            }
                        ),
                      );
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("この学校には生徒のダミーデータがありません。"),
                  )
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text("まず学校を選択してください。"),
            ),
        ],
      ),
    );
  }

  // このウィジェットに関連するFABのUI定義 (呼び出し元で使用)
  Widget buildFloatingActionButtons(BuildContext context) { // contextが必要なら渡す
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: widget.onAddPressed ?? () {
            print('新規登録 (デフォルト動作)');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('新規登録ボタンが押されました (デフォルト)')),
            );
          },
          heroTag: 'content_add_fab', // HeroTagは呼び出し側でユニーク性を担保する
          tooltip: '学校を新規登録',
          child: const Icon(Icons.add),
          backgroundColor: Colors.orange,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () {
            if (widget.onEditPressed != null) {
              widget.onEditPressed!(_selectedSchool); // 現在選択中の学校を渡す
            } else {
              print('編集 (デフォルト動作) - 対象: ${_selectedSchool?.displayString}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('編集ボタン：${_selectedSchool?.displayString ?? "未選択"} (デフォルト)')),
              );
            }
          },
          heroTag: 'content_edit_fab', // HeroTagは呼び出し側でユニーク性を担保する
          tooltip: '選択した学校情報を編集',
          child: const Icon(Icons.edit),
          backgroundColor: Colors.blue,
        ),
      ],
    );
  }
}
