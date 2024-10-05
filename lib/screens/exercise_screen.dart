import 'package:chameleon/models/exercise_model.dart';
import 'package:chameleon/models/feeling_model.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  ExerciseScreen({super.key});

  final Exercise exercise = Exercise(
    id: '1',
    name: 'Puxada Alta Pronada',
    description: 'Treino 1',
    howTo:
        'Segure a barra com as palmas das mãos voltadas para você, com as mãos afastadas na largura dos ombros. Mantenha os braços estendidos e os pés afastados na largura dos ombros. Puxe a barra em direção ao peito, mantendo os cotovelos elevados e afastados dos lados do corpo. Retorne a barra à posição inicial.',
    urlImage: 'https://via.placeholder.com/150',
  );

  final List<Feeling> feelings = [
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
    Feeling(
      id: '1',
      feeling:
          'Estou me sentindo bem, mas com um pouco de dor no ombro direito.',
      data: '2022-01-01',
    ),
    Feeling(id: '2', feeling: 'Estou me sentindo bem.', data: '2022-01-02'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: Column(
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              exercise.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Foi clicado");
        },
        child: const Icon(Icons.arrow_back),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 250,
                minWidth: double.infinity,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        print("Elevated button");
                      },
                      child: const Text("Enviar foto")),
                  ElevatedButton(
                      onPressed: () {
                        print("Elevated button");
                      },
                      child: const Text("Remover foto")),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Como fazer?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(exercise.howTo),
            const Padding(
                padding: EdgeInsets.all(10),
                child: Divider(color: Colors.black)),
            const Text(
              "Como estou me sentindo?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: List.generate(
                    feelings.length,
                    (index) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(feelings[index].feeling),
                      subtitle: Text(feelings[index].data),
                      leading: const Icon(Icons.double_arrow),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          print("Delete");
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.all(10),
                child: Divider(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
