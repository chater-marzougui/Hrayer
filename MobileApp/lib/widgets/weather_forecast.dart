import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';

class WeatherWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const WeatherWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use provided coordinates or default to a location
      final lat = widget.latitude ?? 36.8065; // Default to Tunis
      final lon = widget.longitude ?? 10.1815;

      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
              '?latitude=$lat'
              '&longitude=$lon'
              '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation'
              '&daily=sunrise,sunset'
              '&timezone=auto'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? _buildLoadingState(theme, loc)
          : _error != null
          ? _buildErrorState(theme, loc)
          : _buildWeatherContent(theme, loc),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations loc) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              loc.loadingWeather,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations loc) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              loc.weatherError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchWeatherData,
              child: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(ThemeData theme, AppLocalizations loc) {
    final weather = _weatherData!;

    return Column(
      children: [
        // Header with location and main temperature
        _buildHeader(theme, loc, weather),
        const SizedBox(height: 20),

        // Weather details row
        _buildDetailsRow(theme, loc, weather),
        const SizedBox(height: 20),

        // Sunrise/sunset arc
        _buildSunArc(theme, loc, weather),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations loc, WeatherData weather) {
    return Row(
      children: [
        // Location
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.locationName ?? "",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Weather icon and temperature
        Row(
          children: [
            _buildWeatherIcon(weather.weatherCode, 32),
            const SizedBox(width: 8),
            Text(
              '${weather.temperature.round()}°',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsRow(ThemeData theme, AppLocalizations loc, WeatherData weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailItem(
          theme,
          Icons.thermostat,
          '${weather.temperature.round()}°',
          loc.temperature,
        ),
        _buildDetailItem(
          theme,
          Icons.water_drop,
          '${weather.humidity.round()}%',
          loc.humidity,
        ),
        _buildDetailItem(
          theme,
          Icons.air,
          '${weather.windSpeed.round()} ${loc.windSpeedUnit}',
          loc.wind,
        ),
        _buildDetailItem(
          theme,
          Icons.umbrella,
          '${weather.precipitation.toStringAsFixed(1)} ${loc.precipitationUnit}',
          loc.precipitation,
        ),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSunArc(ThemeData theme, AppLocalizations loc, WeatherData weather) {
    final now = DateTime.now();
    final sunrise = weather.sunrise;
    final sunset = weather.sunset;

    // Calculate progress through the day
    double progress = 0.5; // Default to noon
    if (now.isAfter(sunrise) && now.isBefore(sunset)) {
      final totalDaylight = sunset.difference(sunrise).inMinutes;
      final elapsedDaylight = now.difference(sunrise).inMinutes;
      progress = elapsedDaylight / totalDaylight;
    } else if (now.isAfter(sunset)) {
      progress = 1.0;
    } else if (now.isBefore(sunrise)) {
      progress = 0.0;
    }

    return Column(
      children: [
        // Arc with sun position
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: SunArcPainter(
              progress: progress,
              primaryColor: theme.primaryColor,
              backgroundColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
            ),
            child: Container(),
          ),
        ),

        // Sunrise and sunset times
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    _formatTime(weather.sunrise),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loc.sunrise,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    _formatTime(weather.sunset),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loc.sunset,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon(int weatherCode, double size) {
    IconData iconData;
    Color color = Colors.orange;

    switch (weatherCode) {
      case 0: // Clear sky
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 1:
      case 2:
      case 3: // Mainly clear, partly cloudy, and overcast
        iconData = Icons.wb_cloudy;
        color = Colors.grey;
        break;
      case 45:
      case 48: // Fog
        iconData = Icons.foggy;
        color = Colors.grey;
        break;
      case 51:
      case 53:
      case 55: // Drizzle
        iconData = Icons.grain;
        color = Colors.blue;
        break;
      case 61:
      case 63:
      case 65: // Rain
        iconData = Icons.umbrella;
        color = Colors.blue;
        break;
      case 71:
      case 73:
      case 75: // Snow
        iconData = Icons.ac_unit;
        color = Colors.lightBlue;
        break;
      case 95:
      case 96:
      case 99: // Thunderstorm
        iconData = Icons.thunderstorm;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.wb_sunny;
        color = Colors.orange;
    }

    return Icon(iconData, size: size, color: color);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
class SunArcPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  SunArcPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height + size.width * 0.5 - 50);
    final radius = size.width * 0.55 - 10;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 5 / 4,
      math.pi / 2,
      false,
      backgroundPaint,
    );

    // Draw dotted line
    final dottedPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final pathLength = math.pi * radius / 2; // Quarter circle arc length
    final dashCount = 10;
    final dashLength = pathLength / dashCount / 2;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = math.pi * 5 / 4 + (i * 2 * dashLength / radius);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength / radius,
        false,
        dottedPaint,
      );
    }

    // Draw sun position
    // Draw sun position
    final sunAngle = math.pi * 5 / 4 + (progress * math.pi / 2);
    final sunX = center.dx + radius * math.cos(sunAngle);
    final sunY = center.dy + radius * math.sin(sunAngle);

    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(sunX, sunY), 6, sunPaint);

// Draw sun rays
    final rayPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final rayAngle = (i * math.pi / 4);
      final rayStart = Offset(
        sunX + 8 * math.cos(rayAngle),
        sunY + 8 * math.sin(rayAngle),
      );
      final rayEnd = Offset(
        sunX + 12 * math.cos(rayAngle),
        sunY + 12 * math.sin(rayAngle),
      );
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];

    return WeatherData(
      temperature: current['temperature_2m']?.toDouble() ?? 0.0,
      humidity: current['relative_humidity_2m']?.toDouble() ?? 0.0,
      windSpeed: current['wind_speed_10m']?.toDouble() ?? 0.0,
      precipitation: current['precipitation']?.toDouble() ?? 0.0,
      weatherCode: current['weather_code']?.toInt() ?? 0,
      sunrise: DateTime.parse(daily['sunrise'][0]),
      sunset: DateTime.parse(daily['sunset'][0]),
    );
  }
}