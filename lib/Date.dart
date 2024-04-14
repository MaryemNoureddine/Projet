import 'package:flutter/material.dart';
import 'accueil.dart'; // Importez le package intl pour formater la date

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Date Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Voici la date actuelle :',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              DateWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class DateWidget extends StatefulWidget {
  @override
  _DateWidgetState createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _updateDate();
  }

  void _updateDate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentDate,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
