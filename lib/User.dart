/// A Finesse Nation User.
///
/// Contains fields that are used when updating notification settings,
/// posting Finesses, and commenting.
class User {
  /// This user's email.
  String email;

  /// This user's password.
  String password;

  /// This user's username.
  String userName;

  /// This user's email.
  String school;

  /// This user's current points.
  int points;

  /// This user's notification preferences.
  bool notifications;

  List<String> upvoted;

  List<String> downvoted;

  /// The current logged in user.
  static User currentUser = User(null, null, null, null, 0, true, [], []);

  /// Creates a new user.
  User(this.email, this.password, this.userName, this.school, this.points,
      this.notifications, this.upvoted, this.downvoted);

  /// Creates a new user from the given [json] object.
  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
      json['emailId'] ?? "",
      json['password'] ?? "",
      json['userName'] ?? "",
      json['school'] ?? "",
      json['points'] ?? 0,
      json['notifications'] ?? true,
      List<String>.from(json['upvoted']) ?? [],
      List<String>.from(json['downvoted']) ?? [],
    );
    return user;
  }
}
