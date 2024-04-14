import 'package:flutter/material.dart';
import 'package:flutterfirebaseapp/accueil.dart';
import 'Todolist.dart'; // Import de Todolist.dart ici

class HistoriquePage extends StatefulWidget {
  final Map<TimeOfDay, List<String>> todosByTime; // Modifier ici

  // Modifier ici
  const HistoriquePage(
      {Key? key,
      required this.todosByTime,
      required Map<TimeOfDay, List<String>> taches})
      : super(key: key);

  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<Tache> taches = []; // Liste des tâches à faire
  int tachesFaites = 0;

  @override
  void initState() {
    super.initState();
    // Ajouter des tâches fictives à des fins de démonstration
    widget.todosByTime.forEach((time, tasks) {
      tasks.forEach((task) {
        taches.add(Tache(task, false));
      });
    });
    // Calculer le nombre de tâches faites
    tachesFaites = taches.where((tache) => tache.fait).length;
  }

  // Méthode appelée lorsqu'un utilisateur appuie sur un carré pour marquer une tâche comme faite
  void toggleTache(int index) {
    setState(() {
      taches[index].fait = !taches[index].fait;
      // Recalculer le nombre de tâches faites
      tachesFaites = taches.where((tache) => tache.fait).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double pourcentage =
        taches.isEmpty ? 0.0 : (tachesFaites / taches.length) * 100;
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des tâches'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Liste des tâches à faire
          Expanded(
            child: ListView.builder(
              itemCount: taches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: IconButton(
                    icon: taches[index].fait
                        ? Icon(Icons.check)
                        : Icon(Icons.close),
                    onPressed: () {
                      if (!taches[index].fait) {
                        toggleTache(index);
                      }
                    },
                  ),
                  title: Text(taches[index].nom),
                );
              },
            ),
          ),
          // Pourcentage de réussite des tâches
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pourcentage de réussite : ${pourcentage.toStringAsFixed(2)}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Message d'encouragement en fonction du pourcentage de réussite
          if (pourcentage == 100)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Félicitations ! Vous avez accompli toutes vos tâches !',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
          else if (pourcentage > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Continuez comme ça !',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          // Bouton pour passer à la page suivante
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccueilPage()), // Naviguer vers AccueilPage
              );
            },
            child: Text('Passer à la page d accueil'),
          ),
        ],
      ),
    );
  }
}

class Tache {
  String nom;
  bool fait;

  Tache(this.nom, this.fait);
}
