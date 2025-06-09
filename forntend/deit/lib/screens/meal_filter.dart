import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plan.dart';

class MealFilterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final planModel = Provider.of<PlanModel>(context);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: Text('خطة الوجبات', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إجمالي السعرات: ${planModel.totalCalories?.toStringAsFixed(1) ?? '-'} ك.س',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Colors.pink[900],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: planModel.items.length,
                  itemBuilder: (context, index) {
                    final item = planModel.items[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.pink[100],
                            child: Text(
                              '${(item.caloriesPer100g).toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: Colors.pink[900],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'الحصة: ${item.servingSize.toStringAsFixed(0)} غرام',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: Icon(Icons.fastfood, color: Colors.pink[300]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 80), // عشان نترك مكان للتمويج
            ],
          ),

          // التمويج السفلي
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: 80,
                color: Colors.pink[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// الكلاسر الخاص بالتمويج السفلي
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    var firstControlPoint = Offset(size.width / 4, 40);
    var firstEndPoint = Offset(size.width / 2, 20);
    var secondControlPoint = Offset(size.width * 3 / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
