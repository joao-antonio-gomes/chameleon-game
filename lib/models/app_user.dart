class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;

  AppUser(
      {required this.uid,
      required this.email,
      required this.displayName,
      required this.photoURL});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
