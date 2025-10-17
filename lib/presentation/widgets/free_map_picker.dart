import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

/// Resultado que devuelve el selector
class LocationResult {
  final double lat;
  final double lng;
  final String address;

  const LocationResult({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

/// Selector de ubicación 100% free:
/// - MapLibre (tiles de MapTiler con key gratis)
/// - Geocoding: MapTiler (primario) + Photon (fallback)
/// - Reverse: Nominatim
class FreeMapPicker extends StatefulWidget {
  final String maptilerApiKey; // https://cloud.maptiler.com/ (plan free)
  final ml.LatLng? initial; // coord inicial (opcional)
  final String? initialAddress; // etiqueta inicial (opcional)
  final String title;

  const FreeMapPicker({
    super.key,
    required this.maptilerApiKey,
    this.initial,
    this.initialAddress,
    this.title = 'Seleccionar ubicación',
  });

  /// Abre como modal flotante y retorna LocationResult
  static Future<LocationResult?> show(
    BuildContext context, {
    required String maptilerApiKey,
    ml.LatLng? initial,
    String? initialAddress,
    String title = 'Seleccionar ubicación',
  }) {
    return showModalBottomSheet<LocationResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: FreeMapPicker(
            maptilerApiKey: maptilerApiKey,
            initial: initial,
            initialAddress: initialAddress,
            title: title,
          ),
        ),
      ),
    );
  }

  @override
  State<FreeMapPicker> createState() => _FreeMapPickerState();
}

class _FreeMapPickerState extends State<FreeMapPicker> {
  // Estado
  late double _lat;
  late double _lng;
  String _address = '';
  bool _loadingAddr = false;

  // Controladores
  ml.MaplibreMapController? _controller;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _reverseDebounce;

  // Quito por defecto
  static const _defaultQuito = ml.LatLng(-0.1807, -78.4678);

  String get _styleUrl =>
      'https://api.maptiler.com/maps/streets/style.json?key=${widget.maptilerApiKey}';

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? _defaultQuito;
    _lat = init.latitude;
    _lng = init.longitude;
    _address = widget.initialAddress ?? '';
    if (_address.isEmpty) _reverseGeocode(_lat, _lng);
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ===== Helpers de mapa/ubicación =====

  Future<void> _moveTo(double lat, double lng, {double zoom = 16}) async {
    setState(() {
      _lat = lat;
      _lng = lng;
    });
    final c = _controller;
    if (c != null) {
      await c.animateCamera(
        ml.CameraUpdate.newCameraPosition(
          ml.CameraPosition(target: ml.LatLng(lat, lng), zoom: zoom),
        ),
      );
    }
  }

  Future<void> _goToMyLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permiso de ubicación denegado permanentemente. Abre Ajustes.',
            ),
          ),
        );
      }
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      return;
    }

    if (perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _moveTo(pos.latitude, pos.longitude, zoom: 16);
        _reverseGeocode(pos.latitude, pos.longitude);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener tu ubicación. Revisa el GPS.'),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se requiere permiso de ubicación para centrar el mapa.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _loadingAddr = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
      );
      final res = await http.get(
        url,
        headers: {'User-Agent': 'klax-crm/1.0 (contacto@tu-dominio.com)'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _address = (data['display_name'] as String?) ?? '($lat, $lng)';
      } else {
        _address = '($lat, $lng)';
      }
    } catch (_) {
      _address = '($lat, $lng)';
    } finally {
      if (mounted) setState(() => _loadingAddr = false);
    }
  }

  // ===== Búsqueda: MapTiler (primario) + Photon (fallback) =====

  Future<List<_Suggestion>> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    // 1) MapTiler Geocoding (requiere tu key — free)
    try {
      final url = Uri.parse(
        'https://api.maptiler.com/geocoding/${Uri.encodeComponent(query)}.json'
        '?key=${widget.maptilerApiKey}&language=es&limit=6',
      );
      final res = await http.get(
        url,
        headers: {'User-Agent': 'klax-crm/1.0 (contacto@tu-dominio.com)'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final feats = (data['features'] as List?) ?? [];
        if (feats.isNotEmpty) {
          return feats
              .map((f) {
                final props =
                    f['place_name'] as String? ??
                    (f['text'] as String? ?? 'Resultado');
                final coords = (f['center'] as List?) ?? [0, 0];
                final lng = (coords[0] as num).toDouble();
                final lat = (coords[1] as num).toDouble();
                return _Suggestion(text: props, lat: lat, lng: lng);
              })
              .cast<_Suggestion>()
              .toList();
        }
      }
    } catch (_) {
      // sigue a Photon
    }

    // 2) Photon (gratis)
    try {
      final url = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=6&lang=es',
      );
      final res = await http.get(
        url,
        headers: {'User-Agent': 'klax-crm/1.0 (contacto@tu-dominio.com)'},
      );
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      final feats = (data['features'] as List?) ?? [];
      return feats
          .map((f) {
            final props = f['properties'] ?? {};
            final coords = (f['geometry']?['coordinates'] as List?) ?? [0, 0];
            final lng = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();
            final label =
                props['name'] ??
                props['street'] ??
                props['city'] ??
                props['country'] ??
                'Resultado';
            final context = [
              props['city'],
              props['county'],
              props['state'],
              props['country'],
            ].where((e) => e != null).join(', ');
            return _Suggestion(
              text: context.isNotEmpty ? '$label, $context' : '$label',
              lat: lat,
              lng: lng,
            );
          })
          .cast<_Suggestion>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _selectSuggestion(_Suggestion s) async {
    await _moveTo(s.lat!, s.lng!, zoom: 16);
    setState(() => _address = s.text);
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Mi ubicación',
            onPressed: _goToMyLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TypeAheadField<_Suggestion>(
              suggestionsCallback: _searchPlaces,
              debounceDuration: const Duration(milliseconds: 280),
              hideOnEmpty: true,
              hideOnLoading: false,
              hideWithKeyboard: false,
              loadingBuilder: (_) => const ListTile(
                leading: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text('Buscando...'),
              ),
              builder: (context, controller, focusNode) {
                _searchCtrl.value = controller.value;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    final items = await _searchPlaces(value);
                    if (items.isNotEmpty) _selectSuggestion(items.first);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar dirección o lugar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              itemBuilder: (_, s) => ListTile(
                leading: const Icon(Icons.place),
                title: Text(
                  s.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onSelected: _selectSuggestion,
              emptyBuilder: (_) =>
                  const ListTile(title: Text('Sin resultados')),
              errorBuilder: (_, __) =>
                  const ListTile(title: Text('Error buscando.')),
            ),
          ),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ml.MaplibreMap(
                  styleString: _styleUrl,
                  initialCameraPosition: ml.CameraPosition(
                    target: ml.LatLng(_lat, _lng),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  compassEnabled: false,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,

                  // Atrapar gestos dentro del modal/bottomsheet
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },

                  // Para leer la cámara desde el controller
                  trackCameraPosition: true,

                  onMapCreated: (c) {
                    _controller = c;

                    // Movimiento de cámara en vivo
                    _controller!.addListener(() {
                      final cp = _controller!.cameraPosition;
                      final moving = _controller!.isCameraMoving;
                      if (cp != null && moving) {
                        setState(() {
                          _lat = cp.target.latitude;
                          _lng = cp.target.longitude;
                        });
                      }
                    });
                  },

                  // Al detener la cámara -> reverse geocode con debounce
                  onCameraIdle: () {
                    final cp = _controller?.cameraPosition;
                    if (cp == null) return;
                    _reverseDebounce?.cancel();
                    _reverseDebounce = Timer(
                      const Duration(milliseconds: 350),
                      () {
                        _reverseGeocode(
                          cp.target.latitude,
                          cp.target.longitude,
                        );
                      },
                    );
                  },
                ),

                // Pin centrado
                const IgnorePointer(child: Icon(Icons.location_on, size: 40)),

                // Address chip
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16 + 56,
                  child: _AddressChip(
                    text: _loadingAddr ? 'Buscando dirección…' : _address,
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Usar esta ubicación'),
                onPressed: () {
                  Navigator.of(context).pop(
                    LocationResult(
                      lat: _lat,
                      lng: _lng,
                      address: _address.isEmpty ? '($_lat, $_lng)' : _address,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final String text;
  final double? lat, lng;

  _Suggestion({required this.text, this.lat, this.lng});
}

class _AddressChip extends StatelessWidget {
  final String text;

  const _AddressChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Text(
          text.isEmpty ? '—' : text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
