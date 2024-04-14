import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'Todolist.dart'; // Importez la classe TodoListScreen depuis Todolist.dart
import 'historique.dart'; // Importez la classe HistoriquePage depuis historique.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accueil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccueilPage(),
    );
  }
}

class AccueilPage extends StatefulWidget {
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  DateTime today = DateTime.now(); // State variable for selected date
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay; // Update selected date on user interaction
    });

    // Navigate to TodoListScreen when a day is selected
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoListScreen()),
    );
  }

  String formattedDate = '';
  String cityName = '';
  String weatherDescription = '';
  double temperatureCelsius = 0.0;
  String weatherIcon = '';

  @override
  void initState() {
    super.initState();
    getDate();
    getLocationAndWeather();
  }

  void getDate() {
    DateTime now = DateTime.now();
    formattedDate = '${now.day}/${now.month}/${now.year}';
  }

  Future<void> getLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await fetchWeather(position.latitude, position.longitude);
      await fetchCityName(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    String apiKey = '87ce8839d867f61a10eeee50d0bac988';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        temperatureCelsius = (data['main']['temp'] - 273.15);
        weatherDescription = data['weather'][0]['description'];
        weatherIcon = data['weather'][0]['icon'];
      });
    } else {
      setState(() {
        weatherDescription = 'Failed to load weather data';
      });
    }
  }

  Future<void> fetchCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      setState(() {
        cityName = placemarks.isNotEmpty
            ? placemarks[0].locality ?? 'Unknown'
            : 'Unknown';
      });
    } catch (e) {
      print('Error getting city name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: SingleChildScrollView(
        // Wrap your Column with SingleChildScrollView
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: content(),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoriquePage(
                                        todosByTime: {},
                                        taches: {},
                                      )),
                            );
                          },
                          child: Text('historique'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: const Color.fromRGBO(255, 152, 0, 1),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Chatbot
                          },
                          child: Text('Chatbot'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
              "Selected Day: ${today.toString().split(' ')[0]}"), // Display selected date
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TableCalendar(
              locale: "en_US",
              rowHeight: 40,
              headerStyle:
                  HeaderStyle(formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
            ),
          ),
          SizedBox(height: 8),
          Flexible(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoListScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text(
                'Liste des tâches',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  placemarkFromCoordinates(double latitude, double longitude) {}
}

class Placemark {
  get locality => null;
}
