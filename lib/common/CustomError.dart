import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop("comingBack");
        return Future.value(true); // Return true to allow the back press
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Expanded(
              child: Container(
                width: double.infinity, // Set width to fill the screen horizontally
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/error_illustration.jpg'),
                    Text(
                      kDebugMode
                          ? errorDetails.summary.toString()
                          : 'Oups! Something went wrong!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: kDebugMode ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 21),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      kDebugMode
                          ? 'https://docs.flutter.dev/testing/errors'
                          : "We encountered an error and we've notified our engineering team about it. Sorry for the inconvenience caused.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}