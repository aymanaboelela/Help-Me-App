import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomRatingBar extends StatefulWidget {
  const CustomRatingBar({super.key, required this.ratingCallback});

  final Function(double) ratingCallback;
  @override
  State<CustomRatingBar> createState() => _CustomRatingBarState();
}

class _CustomRatingBarState extends State<CustomRatingBar> {
  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: 3,
      glow: true,
      minRating: 1,
      direction: Axis.horizontal,
      itemCount: 5,
      itemSize: 40,
      itemBuilder: (context, _) => Column(
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
        ],
      ),
      onRatingUpdate: (rating) {
        setState(() {
          widget.ratingCallback(rating);
        });
      },
    );
  }
}
