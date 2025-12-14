import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Info',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const BatteryPage(),
    );
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  final Battery _battery = Battery();

  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (mounted) {
        setState(() {
          _batteryState = state;
          _getBatteryLevel(); // Обновляем уровень при смене статуса
        });
      }
    });
  }

  Future<void> _getBatteryLevel() async {
    final int level = await _battery.batteryLevel;
    if (mounted) { 
      setState(() {
        _batteryLevel = level;
      });
    }
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Информация о батарее')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Уровень заряда:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$_batteryLevel%',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBatteryLevelColor(_batteryLevel),
              ),
            ),
            const SizedBox(height: 30),
            _getBatteryStateIcon(_batteryState),
            const SizedBox(height: 10),
            Text(
              _getRussianStateName(_batteryState),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: _getBatteryLevel,
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRussianStateName(BatteryState state) {
    switch (state) {
      case BatteryState.full:
        return 'Полностью заряжена';
      case BatteryState.charging:
        return 'Заряжается';
      case BatteryState.discharging:
        return 'Разряжается';
      case BatteryState.connectedNotCharging:
        return 'Подключено, не заряжается'; 
      case BatteryState.unknown:
        return 'Неизвестно';
    }
  }

  Color _getBatteryLevelColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
  
  Widget _getBatteryStateIcon(BatteryState state) {
    switch (state) {
      case BatteryState.full:
        return const Icon(Icons.battery_full, size: 50, color: Colors.green);
      case BatteryState.charging:
        return const Icon(Icons.battery_charging_full, size: 50, color: Colors.blueAccent);
      case BatteryState.discharging:
        return const Icon(Icons.battery_std, size: 50, color: Colors.orange);
      default:
        return const Icon(Icons.battery_unknown, size: 50, color: Colors.grey);
    }
  }
}
