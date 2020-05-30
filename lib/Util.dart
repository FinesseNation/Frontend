import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/User.dart';

/// Utility functions used by multiple files.

/// Updates vote info for [currentUser] and [fin].
void handleVote(int index, List<bool> isSelected, Finesse fin) {
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
  setVotes();
  updateFinesse(fin);
}
