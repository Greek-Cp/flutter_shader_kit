import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/weather_rain_layer.dart';

class WeatherRainDemoPage extends StatefulWidget {
  const WeatherRainDemoPage({super.key});

  @override
  State<WeatherRainDemoPage> createState() => _WeatherRainDemoPageState();
}

class _WeatherRainDemoPageState extends State<WeatherRainDemoPage>
    with TickerProviderStateMixin {
  // Weather condition
  bool _isSunny = false;
  
  // Rain shader settings
  double _rainAmount = 0.85;
  double _maxBlur = 3.0;
  double _minBlur = 0.0;
  double _refraction = 45.0;
  double _speed = 1.2;
  bool _enabled = true;

  late AnimationController _cloudController;
  late AnimationController _temperatureController;
  late AnimationController _weatherTransitionController;
  late AnimationController _pulseController;
  

  // Weather data
  String _cityName = 'Jakarta';
  String _condition = 'Heavy Rain';
  int _temperature = 47;
  int _highTemp = 62;
  int _lowTemp = 41;
  String _description = 'Rainy conditions tonight, continuing through the morning.';

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();

    _temperatureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _weatherTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _temperatureController.dispose();
    _weatherTransitionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleWeather() {
    setState(() {
      _isSunny = !_isSunny;
      
      if (_isSunny) {
        _condition = 'Sunny';
        _temperature = 75;
        _highTemp = 82;
        _lowTemp = 68;
        _description = 'Clear skies with sunshine throughout the day.';
        _weatherTransitionController.forward();
      } else {
        _condition = 'Heavy Rain';
        _temperature = 47;
        _highTemp = 62;
        _lowTemp = 41;
        _description = 'Rainy conditions tonight, continuing through the morning.';
        _weatherTransitionController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _weatherTransitionController,
        builder: (context, child) {
          final currentRainAmount = _isSunny 
              ? _rainAmount * (1 - _weatherTransitionController.value) 
              : _rainAmount;
          final currentEnabled = _weatherTransitionController.value < 0.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildSkyBackground(),
                      _buildClouds(constraints.maxWidth),
                      _buildSunMoon(),
                      LightningLayer(
                        isSunny: _isSunny,
                        enabled: !_isSunny,
                      ),
                       WeatherRainLayer(
                                  useBackdrop: true,
                                  rainAmount:1,
                                  maxBlur: 0,
                                  minBlur: 0,
                                  refraction: 30,
                                  lockToScreen: false,
                                  speed: 10,
                                  
                                  enabled: currentEnabled && _enabled,
                                  child: const SizedBox.expand(),
                                ),
                     
                    ],
                  );
                },
              ),
          
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 60),
                        
                        _buildMainTemperature(),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                             
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildConditionText(),
                                    const SizedBox(height: 12),
                                    _buildHighLowTemp(),
                                    const SizedBox(height: 48),
                                    _buildDescription(),
                                    const SizedBox(height: 40),
                                    _buildHourlyForecast(),
                                    const SizedBox(height: 40),
                                    _build10DayForecast(),
                                    const SizedBox(height: 40),
                                    _buildWeatherToggle(),
                                    const SizedBox(height: 20),
                                    _buildControlPanel(),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                               Positioned.fill(
                                child: WeatherRainLayer(
                                  useBackdrop: true,
                                  rainAmount: currentRainAmount,
                                  maxBlur: _maxBlur,
                                  minBlur: _minBlur,
                                  refraction: _refraction,
                                  lockToScreen: false,
                                  speed: _speed,
                                  
                                  enabled: currentEnabled && _enabled,
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),
          
                   
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkyBackground() {
    return AnimatedBuilder(
      animation: _weatherTransitionController,
      builder: (context, child) {
        const rainyColors = [
          Color(0xFF1a2332),
          Color(0xFF2B4162),
          Color(0xFF3B5A7D),
          Color(0xFF4A6F96),
        ];
        
        const sunnyColors = [
          Color(0xFF1E88E5),
          Color(0xFF42A5F5),
          Color(0xFF64B5F6),
          Color(0xFF90CAF9),
        ];

        final colors = List.generate(4, (index) {
          return Color.lerp(
            rainyColors[index],
            sunnyColors[index],
            _weatherTransitionController.value,
          )!;
        });

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunMoon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_weatherTransitionController, _pulseController]),
      builder: (context, child) {
        if (!_isSunny) return const SizedBox.shrink();
        
        final opacity = _weatherTransitionController.value;
        final pulse = 1.0 + (_pulseController.value * 0.1);
        
        return Positioned(
          top: 100,
          right: 60,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: pulse,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.yellow.shade300,
                      Colors.amber.shade400,
                      Colors.orange.shade300.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClouds(double screenWidth) {
    return AnimatedBuilder(
      animation: Listenable.merge([_cloudController, _weatherTransitionController]),
      builder: (context, child) {
        final cloudOpacityMultiplier = 1.0 - (_weatherTransitionController.value * 0.65);
        
        return Stack(
          children: [
            _buildCloud(
              screenWidth: screenWidth,
              top: 60,
              leftOffset: _cloudController.value * screenWidth * 1.8 - 300,
              scale: 1.6,
              opacity: 0.2 * cloudOpacityMultiplier,
            ),
            _buildCloud(
              screenWidth: screenWidth,
              top: 140,
              leftOffset: _cloudController.value * screenWidth * 1.5 - 250,
              scale: 1.4,
              opacity: 0.35 * cloudOpacityMultiplier,
            ),
            _buildCloud(
              screenWidth: screenWidth,
              top: 100,
              leftOffset: _cloudController.value * screenWidth * 1.3 - 200,
              scale: 1.3,
              opacity: 0.4 * cloudOpacityMultiplier,
            ),
            _buildCloud(
              screenWidth: screenWidth,
              top: 200,
              leftOffset: _cloudController.value * screenWidth * 1.1 - 150,
              scale: 1.2,
              opacity: 0.45 * cloudOpacityMultiplier,
            ),
            _buildCloud(
              screenWidth: screenWidth,
              top: 160,
              leftOffset: _cloudController.value * screenWidth * 0.95 - 100,
              scale: 1.1,
              opacity: 0.5 * cloudOpacityMultiplier,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloud({
    required double screenWidth,
    required double top,
    required double leftOffset,
    required double scale,
    required double opacity,
  }) {
    final totalWidth = screenWidth + 500;
    double normalizedOffset = leftOffset % totalWidth;
    double left = normalizedOffset - 250;
    
    double edgeFadeOpacity = 1.0;
    if (normalizedOffset < 150) {
      edgeFadeOpacity = normalizedOffset / 150;
    } else if (normalizedOffset > totalWidth - 150) {
      edgeFadeOpacity = (totalWidth - normalizedOffset) / 150;
    }

    return Positioned(
      top: top,
      left: left,
      child: Opacity(
        opacity: (opacity * edgeFadeOpacity).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: const Size(260, 110),
            painter: _CloudPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTemperature() {
    return Center(
      child: AnimatedBuilder(
        animation: _temperatureController,
        builder: (context, child) {
          final temp = _temperature + (_temperatureController.value * 2).toInt();
          return Column(
            children: [
              Text(
                '$temp°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 110,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                  letterSpacing: -4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConditionText() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          _condition,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHighLowTemp() {
    return Center(
      child: Text(
        'H:$_highTemp° L:$_lowTemp°',
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSunny ? Icons.wb_sunny_rounded : Icons.cloud_rounded,
                  color: _isSunny ? Colors.amber.shade300 : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final hours = _isSunny ? [
      {'time': 'Now', 'icon': Icons.wb_sunny, 'temp': '75°', 'rain': '0%'},
      {'time': '1PM', 'icon': Icons.wb_sunny, 'temp': '77°', 'rain': '0%'},
      {'time': '2PM', 'icon': Icons.wb_sunny_outlined, 'temp': '79°', 'rain': '5%'},
      {'time': '3PM', 'icon': Icons.wb_sunny, 'temp': '80°', 'rain': '0%'},
      {'time': '4PM', 'icon': Icons.wb_sunny, 'temp': '78°', 'rain': '0%'},
      {'time': '5PM', 'icon': Icons.wb_sunny_outlined, 'temp': '76°', 'rain': '10%'},
    ] : [
      {'time': 'Now', 'icon': Icons.cloud, 'temp': '47°', 'rain': '80%'},
      {'time': '11PM', 'icon': Icons.cloud, 'temp': '45°', 'rain': '60%'},
      {'time': '12AM', 'icon': Icons.cloud_outlined, 'temp': '44°', 'rain': '50%'},
      {'time': '1AM', 'icon': Icons.cloud_outlined, 'temp': '43°', 'rain': '60%'},
      {'time': '2AM', 'icon': Icons.cloud, 'temp': '41°', 'rain': '40%'},
      {'time': '3AM', 'icon': Icons.cloud, 'temp': '40°', 'rain': '60%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white.withOpacity(0.7), size: 18),
              const SizedBox(width: 10),
              Text(
                'HOURLY FORECAST',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 130,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hours.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final hour = hours[index];
                  final isNow = hour['time'] == 'Now';
                  return Container(
                    width: 75,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isNow ? Colors.white.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          hour['time'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: isNow ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        Icon(
                          hour['icon'] as IconData,
                          color: _isSunny ? Colors.amber.shade300 : Colors.white.withOpacity(0.9),
                          size: 30,
                        ),
                        Text(
                          hour['rain'] as String,
                          style: TextStyle(
                            color: const Color(0xFF6EC6FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          hour['temp'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build10DayForecast() {
    final days = _isSunny ? [
      {'day': 'Today', 'icon': Icons.wb_sunny, 'rain': '0%', 'low': '68°', 'high': '82°', 'range': 0.9},
      {'day': 'Tue', 'icon': Icons.wb_sunny, 'rain': '5%', 'low': '70°', 'high': '85°', 'range': 0.95},
      {'day': 'Wed', 'icon': Icons.wb_sunny_outlined, 'rain': '10%', 'low': '68°', 'high': '80°', 'range': 0.85},
      {'day': 'Thu', 'icon': Icons.cloud_outlined, 'rain': '30%', 'low': '65°', 'high': '75°', 'range': 0.7},
      {'day': 'Fri', 'icon': Icons.cloud, 'rain': '60%', 'low': '60°', 'high': '70°', 'range': 0.6},
      {'day': 'Sat', 'icon': Icons.wb_sunny, 'rain': '10%', 'low': '66°', 'high': '78°', 'range': 0.8},
      {'day': 'Sun', 'icon': Icons.wb_sunny, 'rain': '5%', 'low': '68°', 'high': '82°', 'range': 0.9},
    ] : [
      {'day': 'Today', 'icon': Icons.cloud, 'rain': '80%', 'low': '41°', 'high': '62°', 'range': 0.7},
      {'day': 'Tue', 'icon': Icons.cloud_outlined, 'rain': '60%', 'low': '38°', 'high': '56°', 'range': 0.6},
      {'day': 'Wed', 'icon': Icons.cloud, 'rain': '80%', 'low': '41°', 'high': '54°', 'range': 0.5},
      {'day': 'Thu', 'icon': Icons.cloud, 'rain': '75%', 'low': '42°', 'high': '57°', 'range': 0.6},
      {'day': 'Fri', 'icon': Icons.wb_sunny_outlined, 'rain': '20%', 'low': '45°', 'high': '65°', 'range': 0.8},
      {'day': 'Sat', 'icon': Icons.wb_sunny, 'rain': '10%', 'low': '48°', 'high': '70°', 'range': 0.85},
      {'day': 'Sun', 'icon': Icons.wb_sunny, 'rain': '5%', 'low': '50°', 'high': '72°', 'range': 0.9},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.7), size: 18),
              const SizedBox(width: 10),
              Text(
                '10-DAY FORECAST',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: List.generate(days.length, (index) {
                  final day = days[index];
                  final isToday = day['day'] == 'Today';
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isToday ? Colors.white.withOpacity(0.08) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 55,
                              child: Text(
                                day['day'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              day['icon'] as IconData,
                              color: (day['icon'] == Icons.wb_sunny || day['icon'] == Icons.wb_sunny_outlined) 
                                  ? Colors.amber.shade300
                                  : Colors.white.withOpacity(0.9),
                              size: 26,
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 40,
                              child: Text(
                                day['rain'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF6EC6FF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              day['low'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 85,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 85 * (day['range'] as double),
                                      height: 5,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF42A5F5),
                                            Color(0xFFFFB74D),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 36,
                              child: Text(
                                day['high'] as String,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < days.length - 1)
                        Divider(
                          color: Colors.white.withOpacity(0.15),
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isSunny ? Icons.wb_sunny_rounded : Icons.cloud_rounded,
                  color: _isSunny ? Colors.amber.shade300 : Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Weather Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _toggleWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSunny 
                      ? const Color(0xFF1976D2)
                      : const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSunny ? Icons.cloud_rounded : Icons.wb_sunny_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isSunny ? 'Rainy' : 'Sunny',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'RAIN EFFECT SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.35),
                      inactiveThumbColor: Colors.white.withOpacity(0.5),
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSlider(
                label: 'Rain Amount',
                value: _rainAmount,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => setState(() => _rainAmount = v),
              ),
              const SizedBox(height: 4),
              _buildSlider(
                label: 'Speed',
                value: _speed,
                min: 0,
                max: 3,
                divisions: 30,
                onChanged: (v) => setState(() => _speed = v),
              ),
              const SizedBox(height: 4),
              _buildSlider(
                label: 'Max Blur',
                value: _maxBlur,
                min: 0,
                max: 20,
                divisions: 40,
                onChanged: (v) => setState(() => _maxBlur = v),
              ),
              const SizedBox(height: 4),
              _buildSlider(
                label: 'Refraction',
                value: _refraction,
                min: 0,
                max: 100,
                divisions: 50,
                onChanged: (v) => setState(() => _refraction = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.white.withOpacity(0.9),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

}

class LightningLayer extends StatefulWidget {
  final bool isSunny;
  final bool enabled;

  const LightningLayer({super.key, required this.isSunny, required this.enabled});

  @override
  State<LightningLayer> createState() => _LightningLayerState();
}

class _LightningLayerState extends State<LightningLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _maybeSchedule();
  }

  @override
  void didUpdateWidget(covariant LightningLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled || oldWidget.isSunny != widget.isSunny) {
      if (widget.enabled) {
        _maybeSchedule();
      } else {
        _timer?.cancel();
      }
    }
  }

  void _maybeSchedule() {
    _timer?.cancel();
    if (!mounted || !widget.enabled) return;
    final bool isRainy = !widget.isSunny;
    final int minMs = isRainy ? 1000 : 4000;
    final int maxMs = isRainy ? 2300 : 9000;
    final int delay = minMs + _random.nextInt(maxMs - minMs);
    _timer = Timer(Duration(milliseconds: delay), _trigger);
  }

  void _trigger() {
    if (!mounted || !widget.enabled) return;
    _controller.forward(from: 0.0).whenComplete(() {
      if (mounted) {
        _maybeSchedule();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double flash = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 18,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.35)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 12,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.35, end: 0.0)
                .chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 70,
          ),
        ]).transform(_controller.value);

        final double flashOpacity = (widget.isSunny ? 0.40 : 0.30) * flash;

        if (flashOpacity <= 0) return const SizedBox.shrink();

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.white.withOpacity(flashOpacity * 0.18),
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.2),
                    radius: 1.5,
                    colors: [
                      Colors.white.withOpacity(flashOpacity),
                      Colors.white.withOpacity(flashOpacity * 0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 1.0],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final circles = [
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.38, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.62, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.55),
    ];

    final radii = [
      size.height * 0.42,
      size.height * 0.58,
      size.height * 0.65,
      size.height * 0.55,
      size.height * 0.42,
    ];

    for (int i = 0; i < circles.length; i++) {
      canvas.drawCircle(circles[i], radii[i], paint);
    }

    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.32, size.height * 0.68),
      width: size.width * 0.5,
      height: size.height * 0.6,
    ));
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.68, size.height * 0.68),
      width: size.width * 0.5,
      height: size.height * 0.6,
    ));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
