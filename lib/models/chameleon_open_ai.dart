class ChameleonOpenAi {
  String theme;
  String category;
  String thread;

  ChameleonOpenAi({
    required this.theme,
    required this.category,
    required this.thread,
  });

  factory ChameleonOpenAi.fromJson(Map<String, dynamic> json) {
    return ChameleonOpenAi(
      theme: json['theme'],
      category: json['category'],
      thread: json['thread'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'category': category,
      'thread': thread,
    };
  }
}
