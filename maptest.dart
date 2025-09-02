import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';

// --- 重要: Google Maps API キーを設定してください ---
// Google Cloud Platform (GCP) で取得した API キーに置き換えてください。
// このキーは Directions API と Maps SDK for Android/iOS の両方で必要です。
const String googleApiKey = "AIzaSyD2yynVK5hLpnzJbDiJMzCVSglHtzlS-uQ";
// ----------------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ルート案内アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];

  String _routeInfo = "";

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.681236, 139.767125), // 初期位置: 東京駅
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndGetCurrentLocation();
  }

  Future<void> _requestLocationPermissionAndGetCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              '位置情報の権限が拒否されました。設定から許可してください。')),
        );
      }
      // 必要に応じて、ユーザーに設定を開くよう促すダイアログを表示
      // openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _originController.text = "現在地"; // UI上での表示
        _markers.add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: "現在地"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 15),
          ),
        );
      });
    } catch (e) {
      debugPrint("現在地の取得に失敗: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('現在地の取得に失敗しました: $e')),
        );
      }
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    if (address.toLowerCase() == "現在地" && _currentPosition != null) {
      return _currentPosition;
    }
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint("住所からの座標取得に失敗 ($address): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('住所「$address」の座標取得に失敗しました。')),
        );
      }
    }
    return null;
  }

  Future<void> _getDirections() async {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目的地を入力してください。')),
      );
      return;
    }

    LatLng? originLatLng;
    if (_originController.text.isEmpty ||
        _originController.text.toLowerCase() == "現在地") {
      if (_currentPosition == null) {
        await _requestLocationPermissionAndGetCurrentLocation(); // 再度取得を試みる
        if (_currentPosition == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('出発地 (現在地) を取得できませんでした。')),
            );
          }
          return;
        }
      }
      originLatLng = _currentPosition;
    } else {
      originLatLng = await _getLatLngFromAddress(_originController.text);
    }

    final destinationLatLng = await _getLatLngFromAddress(
        _destinationController.text);

    if (originLatLng == null || destinationLatLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('出発地または目的地の座標を取得できませんでした。')),
        );
      }
      return;
    }

    setState(() {
      _markers.clear(); // 既存のマーカーをクリア
      _polylines.clear(); // 既存のポリラインをクリア
      _polylineCoordinates.clear();
      _routeInfo = "ルート検索中...";

      // 出発地と目的地のマーカーを追加
      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: originLatLng!,
        infoWindow: InfoWindow(title: '出発地: ${_originController.text}'),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng!,
        infoWindow: InfoWindow(title: '目的地: ${_destinationController.text}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });

    // Google Directions API へのリクエストURL
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originLatLng
        .latitude},${originLatLng.longitude}&destination=${destinationLatLng
        .latitude},${destinationLatLng
        .longitude}&mode=driving&optimize=true&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'OK' &&
            decodedResponse['routes'] != null &&
            decodedResponse['routes'].isNotEmpty) {
          final route = decodedResponse['routes'][0];
          final points = route['overview_polyline']['points'];
          final leg = route['legs'][0]; // 最初の区間情報を取得

          _polylineCoordinates =
              PolylinePoints().decodePolyline(points).map((point) =>
                  LatLng(point.latitude, point.longitude)).toList();

          if (_polylineCoordinates.isNotEmpty) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _polylineCoordinates,
                  color: Colors.blueAccent,
                  width: 5,
                ),
              );
              _routeInfo =
              "距離: ${leg['distance']['text']}, 所要時間: ${leg['duration']['text']}";
            });

            // ルート全体が見えるようにカメラを調整
            LatLngBounds bounds = _getBounds(_polylineCoordinates);
            _mapController?.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50));
          } else {
            setState(() {
              _routeInfo = "ルートが見つかりませんでした (ポリラインなし)。";
            });
          }
        } else {
          debugPrint(
              'Directions API Error: ${decodedResponse['status']} - ${decodedResponse['error_message']}');
          setState(() {
            _routeInfo = "ルート検索エラー: ${decodedResponse['status']}";
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                  'ルート検索エラー: ${decodedResponse['status']}')),
            );
          }
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        setState(() {
          _routeInfo = "ルート検索リクエストエラー: ${response.statusCode}";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                'ルート検索リクエストエラー: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("ルート検索中に例外発生: $e");
      setState(() {
        _routeInfo = "ルート検索中にエラーが発生しました。";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルート検索中にエラーが発生しました。')),
        );
      }
    }
  }

  // ポリラインの座標リストから適切なLatLngBoundsを計算するヘルパー関数
  LatLngBounds _getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: _initialCameraPosition.target,
        northeast: _initialCameraPosition.target,
      );
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルート案内'),
        actions: [
          if (_currentPosition == null) // 現在地がまだ取得できていない場合のみ表示
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _requestLocationPermissionAndGetCurrentLocation,
              tooltip: "現在地を再取得",
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _originController,
              decoration: InputDecoration(
                  labelText: '出発地 (空欄で現在地)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _originController.clear(),
                  )
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                  labelText: '目的地',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _destinationController.clear(),
                  )
              ),
              onSubmitted: (_) => _getDirections(),
            ),
          ),
          ElevatedButton(
            onPressed: _getDirections,
            child: const Text('ルート検索'),
          ),
          if (_routeInfo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_routeInfo, style: const TextStyle(fontSize: 16)),
            ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                // 初期位置に現在地マーカーがあれば表示
                if (_currentPosition != null &&
                    _markers.any((m) =>
                    m.markerId.value ==
                        "currentLocation")) {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _currentPosition!, zoom: 15),
                    ),
                  );
                }
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              // 現在地ボタンを表示 (SDKが処理)
              myLocationButtonEnabled: true,
              // 現在地ボタンを有効化
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
