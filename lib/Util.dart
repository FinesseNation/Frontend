import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/User.dart';

/// Utility functions used by multiple files.
class Util {
  /// Returns a string containing a more readable/practical
  /// representation of [timePosted] based on the current time.
  ///
  /// ```dart
  /// DateTime today = DateTime.now();
  /// DateTime fiftyDaysAgo = today.subtract(Duration(days: 50));
  /// timeSince(fiftyDaysAgo) == '50 days ago'
  /// ```
  static String timeSince(DateTime timePosted) {
    DateTime currTime = DateTime.now();
    Duration difference = currTime.difference(timePosted);
    int seconds = difference.inSeconds;
    int minutes = difference.inMinutes;
    int hours = difference.inHours;
    int days = difference.inDays;

    if (days < 1) {
      if (hours < 1) {
        if (minutes < 1) {
          if (seconds < 0) {
            return "now";
          } else {
            return "now";
          }
        } else {
          if (minutes == 1) {
            return minutes.toString() + " minute ago";
          } else {
            return minutes.toString() + " minutes ago";
          }
        }
      } else {
        if (hours == 1) {
          return hours.toString() + " hour ago";
        } else {
          return hours.toString() + " hours ago";
        }
      }
    } else {
      if (days == 1) {
        return days.toString() + " day ago";
      } else {
        return days.toString() + " days ago";
      }
    }
  }

  static void handleVote(int index, List<bool> isSelected, Finesse fin) {
    List<String> upvoted = User.currentUser.upvoted;
    List<String> downvoted = User.currentUser.downvoted;
    for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
      if (buttonIndex == index) {
        // button that was pressed
        if (index == 0) {
          // upvote
          if (isSelected[buttonIndex]) {
            upvoted.remove(fin.eventId);
            fin.downvote();
          } else {
            upvoted.add(fin.eventId);
            fin.upvote();
          }
        } else {
          // downvote
          if (isSelected[buttonIndex]) {
            downvoted.remove(fin.eventId);
            fin.upvote();
          } else {
            downvoted.add(fin.eventId);
            fin.downvote();
          }
        }
        isSelected[buttonIndex] = !isSelected[buttonIndex];
      } else {
        // button that wasn't pressed
        if (index == 0) {
          // upvote
          if (isSelected[buttonIndex]) {
            downvoted.remove(fin.eventId);
            fin.upvote();
          }
        } else {
          // downvote
          if (isSelected[buttonIndex]) {
            upvoted.remove(fin.eventId);
            fin.downvote();
          }
        }
        isSelected[buttonIndex] = false;
      }
    }
    Network.setVotes();
    Network.updateFinesse(fin);
  }
}
