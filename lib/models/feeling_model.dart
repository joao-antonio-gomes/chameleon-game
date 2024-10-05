class Feeling {
  final String id;
  final String feeling;
  final String data;

  Feeling({
    required this.id,
    required this.feeling,
    required this.data,
  });

  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      id: json['id'],
      feeling: json['feeling'],
      data: json['data'],
    );
  }
}