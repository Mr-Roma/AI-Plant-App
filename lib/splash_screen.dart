import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 414,
            height: MediaQuery.of(context).size.height,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x191F1F1F),
                  blurRadius: 140,
                  offset: Offset(0, 60),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 140,
                  top: 883,
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Color(0xFFB3B3B3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 127,
                  top: 495,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Plant',
                          style: TextStyle(
                            color: Color(0xFF61AF2B),
                            fontSize: 24,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: ' Friendly',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 24,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
