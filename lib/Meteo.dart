import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meteo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MeteoPage(),
    );
  }
}

class MeteoPage extends StatefulWidget {
  @override
  _MeteoPageState createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  String cityName = 'Tunis';
  String apiKey =
      '87ce8839d867f61a10eeee50d0bac988'; // Remplacez par votre propre clé API OpenWeatherMap
  String weatherDescription = '';
  double temperatureCelsius = 0.0;
  String weatherIcon = '';

  Future<void> fetchWeather() async {
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        temperatureCelsius =
            (data['main']['temp'] - 273.15); // Convert to Celsius
        weatherDescription = data['weather'][0]['description'];
        weatherIcon = data['weather'][0]['icon'];
      });
    } else {
      setState(() {
        weatherDescription = 'Failed to load weather data';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Weather in $cityName:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: ${temperatureCelsius.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Weather: $weatherDescription',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            weatherIcon.isNotEmpty
                ? Image.network(
                    'https://openweathermap.org/img/w/$weatherIcon.png',
                    width: 100,
                    height: 100,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
