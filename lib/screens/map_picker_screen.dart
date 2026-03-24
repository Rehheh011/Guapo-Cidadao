import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerScreen({super.key, this.initialLatitude, this.initialLongitude});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = LatLng(
      widget.initialLatitude ?? -23.55052,
      widget.initialLongitude ?? -46.633308,
    );
  }

  void _onTapTap(TapPosition _, LatLng latlng) {
    setState(() {
      _selectedLatLng = latlng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione no mapa'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedLatLng);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _selectedLatLng,
                zoom: 15,
                onTap: _onTapTap,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'br.gov.flutter_teste_aplicacao',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLatLng,
                      width: 60,
                      height: 60,
                      builder: (context) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selecionado: ${_selectedLatLng.latitude.toStringAsFixed(6)}, ${_selectedLatLng.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(_selectedLatLng),
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
