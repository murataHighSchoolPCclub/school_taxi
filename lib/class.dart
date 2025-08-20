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



