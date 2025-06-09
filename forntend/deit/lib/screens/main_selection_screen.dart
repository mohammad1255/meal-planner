import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للمؤثرات الصوتية والاهتزاز

class MainSelectionScreen extends StatelessWidget {
  const MainSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // الجزء العلوي مع التمويج والرمز
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 260,
                  color: Colors.pink[300],
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30), // رفع النص
                    child: Text(
                      'اختر خطتك الآن',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 20,
                child: Icon(
                  Icons.local_dining,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // الأزرار
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedButton(
                  icon: Icons.fitness_center,
                  label: 'خطة اللياقة',
                  color: Colors.pink[400]!,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/fitness');

                  },
                ),
                SizedBox(height: 20),
                AnimatedButton(
                  icon: Icons.restaurant_menu,
                  label: 'خطة الحمية',
                  color: Colors.pink[100]!,
                  textColor: Colors.pink[900]!,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/choose');

                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateWithEffects(BuildContext context, Widget page) async {
    // اهتزاز خفيف
    HapticFeedback.lightImpact();

    // مؤثر صوتي بسيط
    SystemSound.play(SystemSoundType.click);

    // الانتقال مع Fade
    Navigator.of(context).push(FadeRoute(page: page));
  }
}

// زر أنيق
class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const AnimatedButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: TextStyle(fontSize: 20, fontFamily: 'Cairo'),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }
}

// Route بانتقال ناعم (Fade)
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

// تمويج
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 120);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
