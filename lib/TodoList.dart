import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutterfirebaseapp/historique.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Map<TimeOfDay, List<String>> todosByTime = {}; // Map des tâches par temps
  TextEditingController _taskController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeLocalNotifications();
  }

  Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();
    var android = AndroidInitializationSettings('app_icon');
    var ios = IOSInitializationSettings();
    var platform = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(platform);
  }

  Future<void> scheduleNotification(String task, TimeOfDay time) async {
    var android = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: ios);
    var scheduledTime = tz.TZDateTime.now(tz.local).add(
      Duration(
        hours: time.hour,
        minutes: time.minute,
      ),
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Tâche à faire',
      'Il est temps de compléter votre tâche: $task',
      scheduledTime,
      platform,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          // Première ligne - Deux colonnes
          Row(
            children: [
              // Première colonne - Bloc pour décrire la tâche
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ajouter une tâche :',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: 'Entrez votre tâche ici',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Deuxième colonne - Bloc pour sélectionner l'heure de la tâche
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sélectionner l\'heure de la tâche :',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _selectedTime = selectedTime;
                            });
                          }
                        },
                        child: Text(
                          'Heure : ${_selectedTime.hour}:${_selectedTime.minute}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Deuxième ligne - Bouton Ajouter
          ElevatedButton(
            onPressed: () {
              final task = _taskController.text;
              final time = _selectedTime;
              if (!todosByTime.containsKey(time)) {
                todosByTime[time] = [];
              }
              todosByTime[time]!.add(task);
              scheduleNotification(task, time);
              _taskController.clear();
              setState(() {}); // Pour reconstruire la liste des tâches
            },
            child: Text('Ajouter la tâche'),
          ),
          // Troisième ligne - Liste des tâches et heures associées
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: todosByTime.keys.map((time) {
                  return ListTile(
                    title: Text('${time.hour}:${time.minute}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          todosByTime[time]!.map((task) => Text(task)).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Quatrième ligne - Boutons de navigation
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                        context); // Revenir à la page précédente (AccueilPage)
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(
                    'Accueil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoriquePage(
                                todosByTime: todosByTime,
                                taches: {},
                              )), // Utilisez HistoriquePage() pour naviguer vers la page HistoriquePage et passez les données todosByTime
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(
                    'Historique',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
