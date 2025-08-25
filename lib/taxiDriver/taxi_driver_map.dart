import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'dart:async';
// import 'package:url_launcher/url_launcher.dart'; // OpenStreetMapのサイトを開く場合は必要

class TaxiDriverMapPage extends StatefulWidget {
  const TaxiDriverMapPage({super.key, required this.title});

  final String title;

  @override
  TaxiDriverMapPageState createState() => TaxiDriverMapPageState();
}

class TaxiDriverMapPageState extends State<TaxiDriverMapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  latlong.LatLng _currentPosition = const latlong.LatLng(35.681236, 139.767125);
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<Marker> _markers = [];
  bool _isMapReady = false;
  bool _isLoading = true;

  final double _minZoom = 5.0;
  final double _maxZoom = 18.0;
  final double _initialZoom = 15.0;

  late AnimationController _animationController;
  Animation<double>? _latAnimation, _lngAnimation, _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _initializeMap();
  }

  // 修正点 1: _initializeMap に try-finally を追加
  Future<void> _initializeMap() async {
    try {
      await _determinePositionAndSetupLocationStream();
    } catch (e) {
      print("Error during map initialization: $e");
      _showSnackBar("位置情報を取得できませんでした。ネットワークを確認してください。");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // どのような状況でもローディングを終了
        });
      }
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // 修正点 2: _determinePositionAndSetupLocationStream の初期位置取得にタイムアウト追加など
  Future<void> _determinePositionAndSetupLocationStream() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled. Please enable them in settings.');
      // _isLoading = false; // ここではisLoadingを直接変更しない (initializeMapのfinallyで処理)
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied. Please enable them in app settings.');
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // 15秒のタイムアウトを設定
      );
      if (mounted) {
        setState(() {
          _currentPosition = latlong.LatLng(
              initialPosition.latitude, initialPosition.longitude);
          _updateMarker();
          if (_isMapReady) {
            _animatedMapMove(_currentPosition, _initialZoom);
          }
        });
      }
    } catch (e) {
      print("Error getting initial position: $e");
      _showSnackBar("Could not get initial location. Using default. Check GPS signal.");
      // 初期位置取得に失敗しても、デフォルト位置(_currentPosition の初期値)で地図表示を試みる
      // _isLoading は _initializeMap の finally で false になる
      if (mounted && _isMapReady) { // マップが準備できていればデフォルト位置で移動
        _animatedMapMove(_currentPosition, _initialZoom);
      }
      _updateMarker(); // デフォルト位置でマーカーを更新
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
          (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = latlong.LatLng(position.latitude, position.longitude);
            _updateMarker();
            if (_isMapReady) {
              _mapController.move(_currentPosition, _mapController.camera.zoom);
            }
          });
        }
      },
      onError: (error) {
        print("Error in location stream: $error");
        _showSnackBar("Error getting location updates.");
      },
    );
  }

  void _updateMarker() {
    _markers.clear();
    _markers.add(
      Marker(
          width: 100.0,
          height: 100.0,
          point: _currentPosition,
          child: Tooltip(
            message: 'My Location\nLat: ${_currentPosition.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition.longitude.toStringAsFixed(4)}',
            preferBelow: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person_pin_circle, color: Theme.of(context).colorScheme.primary, size: 36.0),
                ),
              ],
            ),
          )
      ),
    );
  }

  void _onMapReady() {
    if (mounted) {
      setState(() {
        _isMapReady = true;
      });
      // 初期位置がデフォルトと異なる場合、または初期位置取得に失敗した場合でも
      // _isLoading が false になった後に地図の中心を更新する
      // _initializeMap内のfinallyで_isLoadingがfalseになった後、
      // ここで_animatedMapMoveが呼ばれることで、初期位置への移動が試みられる
      _animatedMapMove(_currentPosition, _mapController.camera.zoom < _minZoom ? _initialZoom : _mapController.camera.zoom);
    }
  }

  void _animatedMapMove(latlong.LatLng destLocation, double destZoom) {
    if (!_isMapReady || !mounted) return;

    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    _animationController.reset();

    _latAnimation = latTween.animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _lngAnimation = lngTween.animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _zoomAnimation = zoomTween.animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.addListener(() {
      if (_latAnimation != null && _lngAnimation != null && _zoomAnimation != null && mounted) {
        _mapController.move(
          latlong.LatLng(_latAnimation!.value, _lngAnimation!.value),
          _zoomAnimation!.value,
        );
      }
    });

    _animationController.forward();
  }

  void _centerOnMyLocation() {
    if (_isMapReady) {
      double targetZoom = _mapController.camera.zoom;
      if (targetZoom < _minZoom || targetZoom > _maxZoom) targetZoom = _initialZoom;
      _animatedMapMove(_currentPosition, targetZoom);
    }
  }

  void _zoomIn() {
    if (!_isMapReady) return;
    double currentZoom = _mapController.camera.zoom;
    if (currentZoom < _maxZoom) {
      _animatedMapMove(_mapController.camera.center, currentZoom + 1.0);
    } else {
      _showSnackBar("これ以上拡大できません。");
    }
  }

  void _zoomOut() {
    if (!_isMapReady) return;
    double currentZoom = _mapController.camera.zoom;
    if (currentZoom > _minZoom) {
      _animatedMapMove(_mapController.camera.center, currentZoom - 1.0);
    } else {
      _showSnackBar("これ以上縮小できません。");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        toolbarHeight: 60,
        title: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(widget.title,
                    style: TextStyle(fontSize: 30, color: colorScheme.onPrimary)),
                const SizedBox(width: 60),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition, // 初期表示時の中心はデフォルト値
              initialZoom: _initialZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              onMapReady: _onMapReady,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.school_taxi',
              ),
              MarkerLayer(markers: _markers),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async {
                      // final Uri osmCopyrightUri = Uri.parse('https://openstreetmap.org/copyright');
                      // if (await canLaunchUrl(osmCopyrightUri)) {
                      //   await launchUrl(osmCopyrightUri);
                      // } else {
                      //   _showSnackBar('Could not launch OpenStreetMap copyright page');
                      // }
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSurface.withOpacity(0.8)),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: (MediaQuery.of(context).padding.bottom) + 80 + 16 + 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton.small(
                  heroTag: "zoom_in_button",
                  onPressed: _zoomIn,
                  tooltip: 'Zoom in',
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  elevation: 4,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: "zoom_out_button",
                  onPressed: _zoomOut,
                  tooltip: 'Zoom out',
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  elevation: 4,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnMyLocation,
        tooltip: 'Center on my location',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
