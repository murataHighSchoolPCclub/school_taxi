// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  runApp(const RouteApp());
}

class RouteApp extends StatelessWidget {
  const RouteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const RouteHomePage(),
    );
  }
}

class RouteHomePage extends StatefulWidget {
  const RouteHomePage({super.key});
  @override
  State<RouteHomePage> createState() => _RouteHomePageState();
}

class _RouteHomePageState extends State<RouteHomePage> {
  LatLng? _current;
  List<LatLng> _route = [];
  List<String> _steps = [];
  bool _loading = false;
  String _status = "";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _status = "位置情報の権限を許可してください");
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _current = LatLng(pos.latitude, pos.longitude);
    });
  }

  /// Firestoreから予約順で最大3件の住所を取得
  Future<List<String>> _fetchAddressesFromFirebase() async {
    final reservationsSnap = await FirebaseFirestore.instance
        .collection("reservations")
        .limit(3)
        .get();

    List<String> addresses = [];
    for (var resDoc in reservationsSnap.docs) {
      final data = resDoc.data();
      final userId = data["UserId"];
      if (userId == null) continue;

      final userDoc =
          await FirebaseFirestore.instance.collection("Users").doc(userId).get();

      if (userDoc.exists && userDoc.data()!.containsKey("Address")) {
        addresses.add(userDoc["Address"]);
      }
    }
    return addresses;
  }

  /// ジオコーディング (住所→座標)
  Future<LatLng?> _geocode(String address) async {
    final email = dotenv.env['EMAIL'] ?? "test@example.com";
    final url =
        "https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1&email=$email";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
      }
    }
    return null;
  }

  /// ルート計算
  Future<void> _buildRoute() async {
    if (_current == null) {
      setState(() => _status = "現在地が取得できていません");
      return;
    }

    setState(() {
      _loading = true;
      _status = "Firestoreから住所を取得中…";
      _route = [];
      _steps = [];
    });

    try {
      final addresses = await _fetchAddressesFromFirebase();
      if (addresses.isEmpty) {
        setState(() => _status = "予約がありません");
        return;
      }

      setState(() => _status = "住所を座標に変換中…");
      final coords = <LatLng>[];
      for (var addr in addresses) {
        final c = await _geocode(addr);
        if (c != null) coords.add(c);
      }
      if (coords.isEmpty) {
        setState(() => _status = "座標が取得できませんでした");
        return;
      }

      // OSRM Trip APIで最適ルート計算
      final all = [_current!, ...coords];
      final coordStr = all.map((c) => "${c.longitude},${c.latitude}").join(";");
      final url =
          "https://router.project-osrm.org/trip/v1/driving/$coordStr?source=first&roundtrip=false&steps=true&overview=full";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        setState(() => _status = "OSRMエラー: ${res.statusCode}");
        return;
      }

      final data = jsonDecode(res.body);
      final routeGeometry = data["trips"][0]["geometry"];
      final steps = data["trips"][0]["legs"]
          .expand((leg) => leg["steps"])
          .map<String>((s) => s["maneuver"]["instruction"].toString())
          .toList();

      setState(() {
        _route = _decodePolyline(routeGeometry);
        _steps = steps;
        _status = "ルート計算完了";
      });
    } catch (e) {
      setState(() => _status = "エラー: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// ポリラインデコード
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("最適ルート案内")),
      body: Column(children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _current ?? LatLng(35.681, 139.767),
              initialZoom: 12,
            ),
            children: [
              TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
              if (_current != null)
                MarkerLayer(markers: [
                  Marker(
                      point: _current!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue))
                ]),
              if (_route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(points: _route, strokeWidth: 5, color: Colors.red)
                ]),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Text(_status),
        ElevatedButton.icon(
          onPressed: _loading ? null : _buildRoute,
          icon: const Icon(Icons.alt_route),
          label: const Text("最適ルートを検索"),
        ),
        Expanded(
          child: ListView(
            children: _steps.map((s) => ListTile(title: Text(s))).toList(),
          ),
        )
      ]),
    );
  }
}
