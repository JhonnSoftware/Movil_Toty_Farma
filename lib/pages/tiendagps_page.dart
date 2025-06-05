import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class TiendaGpsPage extends StatefulWidget {
  const TiendaGpsPage({Key? key}) : super(key: key);

  @override
  State<TiendaGpsPage> createState() => _TiendaGpsPageState();
}

class _TiendaGpsPageState extends State<TiendaGpsPage> {
  LatLng? ubicacionUsuario;
  LatLng? ubicacionTienda;
  GoogleMapController? mapController;
  Set<Polyline> polylines = {};
  final String apiKey = "AIzaSyBIZrptkE0IGakPhzMzMpq4PaW_gw_D1vk"; // ← tu API KEY

  @override
  void initState() {
    super.initState();
    obtenerUbicacionUsuario();
    obtenerUbicacionTienda();
  }

  Future<void> obtenerUbicacionUsuario() async {
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        print("🔒 Servicio de ubicación desactivado.");
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          print("🔒 Permiso de ubicación denegado.");
          return;
        }
      }
      if (permiso == LocationPermission.deniedForever) {
        print("🔒 Permiso denegado permanentemente.");
        return;
      }

      final posicion = await Geolocator.getCurrentPosition();
      print("📍 Usuario: ${posicion.latitude}, ${posicion.longitude}");

      setState(() {
        ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ubicación actual: ${posicion.latitude}, ${posicion.longitude}")),
      );

      if (ubicacionTienda != null) {
        obtenerRuta();
      }
    } catch (e) {
      print("❌ Error al obtener ubicación del usuario: $e");
    }
  }

  Future<void> obtenerUbicacionTienda() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tienda')
          .doc('principal')
          .get();

      final data = doc.data();
      if (data != null && data['tienda'] != null) {
        final geo = data['tienda'] as GeoPoint;
        setState(() {
          ubicacionTienda = LatLng(geo.latitude, geo.longitude);
        });

        if (ubicacionUsuario != null) {
          obtenerRuta();
        }
      } else {
        print("❌ El documento 'tienda/principal' no tiene campo 'tienda'");
      }
    } catch (e) {
      print("❌ Error al obtener ubicación de la tienda: $e");
    }
  }

  Future<void> obtenerRuta() async {
    final origen = "${ubicacionUsuario!.latitude},${ubicacionUsuario!.longitude}";
    final destino = "${ubicacionTienda!.latitude},${ubicacionTienda!.longitude}";
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=$origen&destination=$destino&key=$apiKey&mode=driving",
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final rutas = data["routes"];

      if (rutas != null && rutas.isNotEmpty) {
        final puntos = rutas[0]["overview_polyline"]["points"];
        final ruta = decodePolyline(puntos);

        setState(() {
          polylines = {
            Polyline(
              polylineId: const PolylineId("ruta"),
              color: const Color.fromARGB(255, 32, 233, 38),
              width: 5,
              points: ruta,
            ),
          };
        });
      } else {
        print("❌ No se encontraron rutas.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo trazar una ruta válida.")),
        );
      }
    } else {
      print("❌ Error en la API. Código: ${res.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al obtener ruta desde Google Maps.")),
      );
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubicación GPS de la tienda")),
      body: (ubicacionUsuario == null || ubicacionTienda == null)
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-12.0464, -77.0428), // Centro de Lima
                zoom: 11, // Mostrar Lima completa
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("usuario"),
                  position: ubicacionUsuario!,
                  infoWindow: const InfoWindow(title: "Tu ubicación"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                ),
                Marker(
                  markerId: const MarkerId("tienda"),
                  position: ubicacionTienda!,
                  infoWindow: const InfoWindow(title: "TotyFarma - Tienda Principal"),
                  icon: BitmapDescriptor.defaultMarker,
                ),
              },
              polylines: polylines,
              onMapCreated: (controller) => mapController = controller,
            ),
    );
  }
}
