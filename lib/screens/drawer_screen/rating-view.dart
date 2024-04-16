import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_my/screens/drawer_screen/custom_riting_star.dart';
import 'package:in_app_review/in_app_review.dart';

enum Availability { loading, available, unavailable }

class RatingView extends StatefulWidget {
  const RatingView({Key? key}) : super(key: key);
  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = 'com.helpme.help';
  String _microsoftStoreId = '';
  Availability availability = Availability.loading;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        try {
          final isAvailable = await _inAppReview.isAvailable();

          setState(() {
            availability = isAvailable && !Platform.isAndroid
                ? Availability.available
                : Availability.unavailable;
          });
        } catch (_) {
          setState(() => availability = Availability.unavailable);
        }
      },
    );
  }

  void showNoInternetSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Center(
          child: Text(
            "تم ارسال تقيمك للتطبيق",
            style: GoogleFonts.cairo(
              color: Colors.white,
            ),
          ),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
        microsoftStoreId: _microsoftStoreId,
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "  قم بتقييم التطبيق  🥰",
              style: GoogleFonts.cairo(fontSize: 20),
            ),
            Center(
              child: CustomRatingBar(
                ratingCallback: (rating) {
                  if (rating == 5) {
                    _openStoreListing();
                  } else {
                    showNoInternetSnackbar(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
