import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyOrderWidget extends StatelessWidget {
  final String message;
  const EmptyOrderWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: Lottie.asset('assets/lottiefiles/empty.json', repeat: true),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
