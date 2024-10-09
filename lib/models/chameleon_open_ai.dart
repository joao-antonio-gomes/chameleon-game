class ChameleonOpenAi {
  String theme;
  String category;

  ChameleonOpenAi({required this.theme, required this.category});

  factory ChameleonOpenAi.fromJson(Map<String, dynamic> json) {
    return ChameleonOpenAi(
      theme: json['theme'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'category': category,
    };
  }
}
