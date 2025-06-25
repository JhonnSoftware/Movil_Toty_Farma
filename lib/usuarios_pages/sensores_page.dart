import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class SensoresPage extends StatefulWidget {
  const SensoresPage({super.key});

  @override
  State<SensoresPage> createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  String acelerometro = '';
  String giroscopio = '';
  String magnetometro = '';
  String userAccel = '';

  StreamSubscription? _accelerometerSub;
  StreamSubscription? _gyroscopeSub;
  StreamSubscription? _magnetometerSub;
  StreamSubscription? _userAccelSub;

  @override
  void initState() {
    super.initState();

    _accelerometerSub = accelerometerEvents.listen((e) {
      if (!mounted) return;
      setState(() {
        acelerometro =
            'X: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    _gyroscopeSub = gyroscopeEvents.listen((e) {
      if (!mounted) return;
      setState(() {
        giroscopio =
            'X: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    _magnetometerSub = magnetometerEvents.listen((e) {
      if (!mounted) return;
      setState(() {
        magnetometro =
            'X: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    _userAccelSub = userAccelerometerEvents.listen((e) {
      if (!mounted) return;
      setState(() {
        userAccel =
            'X: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _magnetometerSub?.cancel();
    _userAccelSub?.cancel();
    super.dispose();
  }

  Widget buildSensorCard(String title, IconData icon, String data, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: color),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(data.isEmpty ? 'Esperando datos...' : data,
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensores del Móvil'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildSensorCard('Acelerómetro', Icons.speed, acelerometro, Colors.orange),
            buildSensorCard('Giroscopio', Icons.sync, giroscopio, Colors.blue),
            buildSensorCard('Magnetómetro', Icons.explore, magnetometro, Colors.purple),
            buildSensorCard('Aceleración del Usuario', Icons.directions_run, userAccel, Colors.green),
          ],
        ),
      ),
    );
  }
}
