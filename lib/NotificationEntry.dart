import 'package:finesse_nation/Finesse.dart';

enum NotificationType { post, comment }

class NotificationEntry {
  String title;

  String body;

  Finesse finesse;

  NotificationType type;

  bool isUnread;

  NotificationEntry(this.title, this.body, this.finesse, this.type,
      {this.isUnread = true});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntry &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body &&
          finesse == other.finesse &&
          type == other.type;

  @override
  int get hashCode =>
      title.hashCode ^ body.hashCode ^ finesse.hashCode ^ type.hashCode;
}
