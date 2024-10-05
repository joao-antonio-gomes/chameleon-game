
class Exercise {
  final String id;
  final String name;
  final String description;
  final String howTo;
  final String urlImage;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.howTo,
    required this.urlImage,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      howTo: json['howTo'],
      urlImage: json['urlImage'],
    );
  }
}