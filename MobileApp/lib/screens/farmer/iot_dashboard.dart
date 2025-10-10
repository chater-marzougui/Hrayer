import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:async';

class IoTDashboardCard extends StatefulWidget {
  final String backendUrl;

  const IoTDashboardCard({
    super.key,
    this.backendUrl = 'wss://wie-act-1faad7d7a3cf.herokuapp.com',
  });

  @override
  State<IoTDashboardCard> createState() => _IoTDashboardCardState();
}

class _IoTDashboardCardState extends State<IoTDashboardCard> {
  WebSocketChannel? _channel;
  List<SensorReading> _readings = [];
  String _status = 'Connecting...';
  bool _showTemp = true;
  bool _showHumidity = true;
  bool _showMoisture = true;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(widget.backendUrl),
      );

      setState(() {
        _status = 'Connected 🟢';
      });

      _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          setState(() {
            _status = 'Connection error 🔴';
          });
          _reconnect();
        },
        onDone: () {
          _reconnect();
        },
      );
    } catch (e) {
      setState(() {
        _status = 'Connection failed 🔴';
      });
      _reconnect();
    }
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      _connectWebSocket();
    });
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = json.decode(message);
      
      if (data['type'] == 'init') {
        setState(() {
          _readings = (data['data'] as List)
              .map((e) => SensorReading.fromJson(e))
              .toList();
          _status = 'Connected 🟢 Live';
        });
      } else if (data['type'] == 'newReading') {
        setState(() {
          _readings.add(SensorReading.fromJson(data['data']));
          _status = 'Connected 🟢 Live';
        });
      } else if (data['type'] == 'clear') {
        setState(() {
          _readings.clear();
        });
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  Future<void> _clearData() async {
    // Send clear request (you can implement HTTP call here if needed)
    setState(() {
      _readings.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final latest = _readings.isNotEmpty ? _readings.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildMetricsGrid(latest),
                const SizedBox(height: 24),
                _buildChartControls(),
                const SizedBox(height: 16),
                _buildChart(),
                const SizedBox(height: 16),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESP8266 Greenhouse',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _readings.isEmpty
                        ? 'Waiting for readings...'
                        : 'Total readings: ${_readings.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _clearData,
              icon: const Icon(Icons.delete_outline),
              color: const Color(0xFFE11D48),
              tooltip: 'Clear history',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(SensorReading? latest) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Temperature',
          latest != null ? '${latest.temp.toStringAsFixed(1)} °C' : '-- °C',
          const Color(0xFFEF4444),
        ),
        _buildMetricCard(
          'Humidity',
          latest != null ? '${latest.humidity.toStringAsFixed(1)} %' : '-- %',
          const Color(0xFF2563EB),
        ),
        _buildMetricCard(
          'Soil Moisture',
          latest != null ? latest.moisture.toStringAsFixed(1) : '--',
          const Color(0xFF10B981),
        )
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEEF2FF),
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF94A3B8).withAlpha(62),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartControls() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        const Text(
          'Chart Data:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        _buildToggle('Temperature', const Color(0xFFEF4444), _showTemp, (val) {
          setState(() => _showTemp = val);
        }),
        _buildToggle('Humidity', const Color(0xFF2563EB), _showHumidity, (val) {
          setState(() => _showHumidity = val);
        }),
        _buildToggle('Moisture', const Color(0xFF10B981), _showMoisture, (val) {
          setState(() => _showMoisture = val);
        })
      ],
    );
  }

  Widget _buildToggle(String label, Color color, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: color,
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_readings.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const Text(
          'No data available',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _readings.length) {
                    final time = DateTime.parse(_readings[index].createdAt);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: _buildLineBars(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBars() {
    final List<LineChartBarData> bars = [];

    if (_showTemp) {
      bars.add(LineChartBarData(
        spots: _readings.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.temp);
        }).toList(),
        color: const Color(0xFFEF4444),
        barWidth: 3,
        isCurved: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFFEF4444).withAlpha(38),
        ),
      ));
    }

    if (_showHumidity) {
      bars.add(LineChartBarData(
        spots: _readings.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.humidity);
        }).toList(),
        color: const Color(0xFF2563EB),
        barWidth: 3,
        isCurved: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF2563EB).withAlpha(38),
        ),
      ));
    }

    if (_showMoisture) {
      bars.add(LineChartBarData(
        spots: _readings.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.moisture);
        }).toList(),
        color: const Color(0xFF10B981),
        barWidth: 3,
        isCurved: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF10B981).withAlpha(38),
        ),
      ));
    }
    return bars;
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Real-time updates via WebSocket. Status: $_status',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SensorReading {
  final double temp;
  final double humidity;
  final double moisture;
  final double soilRaw;
  final String createdAt;

  SensorReading({
    required this.temp,
    required this.humidity,
    required this.moisture,
    required this.soilRaw,
    required this.createdAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      temp: (json['temp'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      soilRaw: (json['soilRaw'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class IoTDashboardPage extends StatelessWidget {
  const IoTDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return IoTDashboardCard(
      backendUrl: 'wss://wie-act-1faad7d7a3cf.herokuapp.com',
    );
  }
}