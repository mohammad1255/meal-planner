import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/plan.dart';

class PlanGeneratorScreen extends StatefulWidget {
  @override
  _PlanGeneratorScreenState createState() => _PlanGeneratorScreenState();
}

class _PlanGeneratorScreenState extends State<PlanGeneratorScreen> {
  final methodMap = {'خوارزمية جينية': 'genetic', 'خوارزمية جشعة': 'greedy'};
  String _methodArabic = 'خوارزمية جينية';
  int _numMeals = 5;
  bool _loading = false;

  Future<void> _generate() async {
    final user = Provider.of<UserModel>(context, listen: false);
    if (user.id == null) return;

    setState(() => _loading = true);
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/plans/run'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': user.id,
        'method': methodMap[_methodArabic],
        'num_meals': _numMeals,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      Provider.of<PlanModel>(context, listen: false).setPlan(data);
      Navigator.pushNamed(context, '/plan');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل توليد الخطة')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: Text('توليد خطة وجبات', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر الخوارزمية:',
                  style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _methodArabic,
                    decoration: InputDecoration(border: InputBorder.none),
                    items: methodMap.keys
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _methodArabic = val!),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'عدد الوجبات:',
                  style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _numMeals.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_numMeals',
                        onChanged: (val) =>
                            setState(() => _numMeals = val.toInt()),
                        activeColor: Colors.pink[300],
                      ),
                    ),
                    Text('$_numMeals',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 36),
                Center(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _generate,
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('ابدأ التوليد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

// التمويج السفلي الموحد
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
