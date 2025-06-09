import 'package:flutter/material.dart';

class SelectGoalScreen extends StatelessWidget {
  const SelectGoalScreen({super.key});

  void _submitGoal(BuildContext context, String gender, String goal) {
    Navigator.pushNamed(
      context,
      '/result',
      arguments: {'gender': gender, 'goal': goal},
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String gender = args['gender'];

    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Stack(
        children: [
          Column(
            children: [
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink[200]!, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 40,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Text(
                          'اختر الهدف',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    children: [
                      // خسارة الوزن (للانثى فقط)
                      if (gender == 'female')
                        ElevatedButton.icon(
                          icon: Icon(Icons.trending_down),
                          label: Text('خسارة الوزن', style: TextStyle(fontSize: 20, fontFamily: 'Cairo')),
                          onPressed: () => _submitGoal(context, gender, 'lose'),
                          style: _buttonStyle(Colors.teal),
                        ),

                      SizedBox(height: 20),

                      // الحفاظ على الوزن (للذكر فقط)
                      if (gender == 'male')
                        ElevatedButton.icon(
                          icon: Icon(Icons.balance),
                          label: Text('الحفاظ على الوزن', style: TextStyle(fontSize: 20, fontFamily: 'Cairo')),
                          onPressed: () => _submitGoal(context, gender, 'maintain'),
                          style: _buttonStyle(Colors.orange),
                        ),

                      SizedBox(height: 20),

                      // زيادة الوزن (لكل من الذكر والانثى)
                      ElevatedButton.icon(
                        icon: Icon(Icons.trending_up),
                        label: Text('زيادة الوزن', style: TextStyle(fontSize: 20, fontFamily: 'Cairo')),
                        onPressed: () => _submitGoal(context, gender, 'gain'),
                        style: _buttonStyle(Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 60);
    final secondControlPoint = Offset(size.width * 3 / 4, size.height - 120);
    final secondEndPoint = Offset(size.width, size.height - 60);
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
