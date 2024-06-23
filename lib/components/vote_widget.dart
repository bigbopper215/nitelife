import 'package:flutter/material.dart';

class VoteWidget extends StatefulWidget {
  @override
  _VoteWidgetState createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  bool upvoted = false;
  bool downvoted = false;

  Color upvoteColor = Colors.grey;
  Color downvoteColor = Colors.grey;

  void _handleUpvote() {
    setState(() {
      if (upvoted) {
        upvoteColor = Colors.grey; // Change back to default color
      } else {
        upvoteColor = Colors.green; // Change to clicked color
        if (downvoted) {
          downvoteColor = Colors.grey; // Reset downvote color if downvoted
        }
      }
      upvoted = !upvoted; // Toggle upvoted state
    });
  }

  void _handleDownvote() {
    setState(() {
      if (downvoted) {
        downvoteColor = Colors.grey; // Change back to default color
      } else {
        downvoteColor = Colors.red; // Change to clicked color
        if (upvoted) {
          upvoteColor = Colors.grey; // Reset upvote color if upvoted
        }
      }
      downvoted = !downvoted; // Toggle downvoted state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _handleUpvote,
          child: Icon(Icons.arrow_upward, color: upvoteColor),
        ),
        SizedBox(width: 16),
        GestureDetector(
          onTap: _handleDownvote,
          child: Icon(Icons.arrow_downward, color: downvoteColor),
        ),
      ],
    );
  }
}
