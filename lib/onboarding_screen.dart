import 'package:ai_plant_app/presentation/auth/auth.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 414,
            height: MediaQuery.of(context).size.height,
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x191F1F1F),
                  blurRadius: 140,
                  offset: Offset(0, 60),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 75,
                  top: 293,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Let’s ',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 24,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: 'Identify',
                          style: TextStyle(
                            color: Color(0xFF61AF2B),
                            fontSize: 24,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: ' with us ',
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
                const Positioned(
                  left: 75,
                  top: 349,
                  child: Text(
                    'Everything about healthy plant\nmakes the plant better',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 75, right: 80),
                    child: Center(
                      child: Container(
                        width: 192,
                        height: 68,
                        decoration: ShapeDecoration(
                          color: Color(0xFF427E3B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 500,
                  left: 170,
                  child: Image.asset("assets/images/onboard_2.png"),
                ),
                Positioned(
                  right: 170,
                  child: Image.asset("assets/images/onboard_1.png"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
