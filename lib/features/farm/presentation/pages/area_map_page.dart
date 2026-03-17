import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../domain/entities/farm_area.dart';
import '../../domain/services/farm_area_geometry.dart';
import '../models/area_map_draft.dart';

class AreaMapPageArgs {
  const AreaMapPageArgs({
    required this.initialDraft,
    this.title = 'Desenhar no mapa',
  });

  final AreaMapDraft initialDraft;
  final String title;
}

class AreaMapPage extends StatefulWidget {
  const AreaMapPage({required this.args, super.key});

  final AreaMapPageArgs args;

  @override
  State<AreaMapPage> createState() => _AreaMapPageState();
}

class _AreaMapPageState extends State<AreaMapPage> {
  static const _defaultCenter = LatLng(-14.235004, -51.92528);

  final MapController _mapController = MapController();

  late List<FarmAreaPoint> _points;
  late double _areaM2;
  late double _areaHectares;
  late double _perimeter;
  late bool _isClosed;

  @override
  void initState() {
    super.initState();
    _points = List<FarmAreaPoint>.from(widget.args.initialDraft.points);
    _areaM2 = widget.args.initialDraft.areaM2;
    _areaHectares = widget.args.initialDraft.areaHectares;
    _perimeter = widget.args.initialDraft.perimeter;
    _isClosed = widget.args.initialDraft.isClosed;
  }

  @override
  Widget build(BuildContext context) {
    final polylinePoints = _points
        .map((point) => LatLng(point.lat, point.lng))
        .toList(growable: true);

    if (_isClosed && _points.length >= 3) {
      polylinePoints.add(LatLng(_points.first.lat, _points.first.lng));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.title),
        actions: [
          IconButton(
            tooltip: 'Centralizar desenho',
            onPressed: _points.isEmpty ? null : _centerOnPolygon,
            icon: const Icon(Icons.center_focus_strong),
          ),
          IconButton(
            tooltip: 'Meu local',
            onPressed: _goToCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _points.isEmpty
                  ? _defaultCenter
                  : LatLng(_points.first.lat, _points.first.lng),
              initialZoom: _points.isEmpty ? 4.5 : 17,
              onTap: (_, latLng) => _addPoint(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ruraltudo',
              ),
              if (_isClosed && _points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points
                          .map((point) => LatLng(point.lat, point.lng))
                          .toList(),
                      color: Colors.green.withValues(alpha: 0.25),
                      borderStrokeWidth: 3,
                      borderColor: Colors.green.shade700,
                    ),
                  ],
                ),
              if (polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 3,
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < _points.length; i++)
                    Marker(
                      width: 42,
                      height: 42,
                      point: LatLng(_points[i].lat, _points[i].lng),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade700,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.all(12),
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _instructionText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text('Pontos marcados: ${_points.length}'),
                      if (_isClosed && _points.length >= 3) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Área calculada: ${Formatters.decimal(_areaM2)} m²',
                        ),
                        Text(
                          'Equivale a ${Formatters.hectares(_areaHectares)} ha',
                        ),
                        Text('Perímetro: ${Formatters.decimal(_perimeter)} m'),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _points.length < 3 ? null : _closeArea,
                            icon: const Icon(Icons.polyline),
                            label: const Text('Fechar área'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _points.isEmpty ? null : _undoPoint,
                            icon: const Icon(Icons.undo),
                            label: const Text('Desfazer'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _points.isEmpty ? null : _clearPoints,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Limpar'),
                          ),
                          FilledButton.icon(
                            onPressed: _isClosed && _points.length >= 3
                                ? _saveDraft
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Salvar desenho'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _instructionText {
    if (_points.isEmpty) {
      return 'Toque no mapa para marcar os pontos da área.';
    }
    if (_points.length < 3) {
      return 'Adicione pelo menos 3 pontos para fechar a área.';
    }
    if (!_isClosed) {
      return 'Feche a área para calcular o tamanho.';
    }
    return 'Área fechada. Confira os valores e salve o desenho.';
  }

  void _addPoint(LatLng latLng) {
    setState(() {
      if (_isClosed) _isClosed = false;
      _points = [
        ..._points,
        FarmAreaPoint(lat: latLng.latitude, lng: latLng.longitude),
      ];
      _resetMetrics();
    });
  }

  void _undoPoint() {
    if (_points.isEmpty) return;
    setState(() {
      _points = List<FarmAreaPoint>.from(_points)..removeLast();
      if (_points.length < 3) {
        _isClosed = false;
      }
      _resetMetrics();
    });
  }

  void _clearPoints() {
    setState(() {
      _points = [];
      _isClosed = false;
      _resetMetrics();
    });
  }

  void _closeArea() {
    if (_points.length < 3) {
      AppFeedback.error(context, 'Adicione pelo menos 3 pontos.');
      return;
    }
    final metrics = FarmAreaGeometry.calculate(_points);
    setState(() {
      _isClosed = true;
      _areaM2 = metrics.areaM2;
      _areaHectares = metrics.areaHectares;
      _perimeter = metrics.perimeter;
    });
  }

  void _saveDraft() {
    Navigator.of(context).pop(
      AreaMapDraft(
        points: _points,
        areaM2: _areaM2,
        areaHectares: _areaHectares,
        perimeter: _perimeter,
        isClosed: _isClosed,
      ),
    );
  }

  void _resetMetrics() {
    _areaM2 = 0;
    _areaHectares = 0;
    _perimeter = 0;
  }

  void _centerOnPolygon() {
    if (_points.isEmpty) return;
    final latitudes = _points.map((point) => point.lat);
    final longitudes = _points.map((point) => point.lng);
    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    _mapController.move(center, 17);
  }

  Future<void> _goToCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        AppFeedback.error(
          context,
          'Ative o GPS para centralizar no local atual.',
        );
      }
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        AppFeedback.error(context, 'Permissão de localização não concedida.');
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _mapController.move(LatLng(position.latitude, position.longitude), 17);
    } catch (_) {
      if (mounted) {
        AppFeedback.error(
          context,
          'Não foi possível obter a localização atual.',
        );
      }
    }
  }
}
