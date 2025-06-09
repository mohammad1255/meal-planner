import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan.dart';

class CustomTargetScreen extends StatefulWidget {
  @override
  _CustomTargetScreenState createState() => _CustomTargetScreenState();
}

class _CustomTargetScreenState extends State<CustomTargetScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  final methodMap = {'خوارزمية جينية': 'genetic', 'خوارزمية جشعة': 'greedy'};
  String _methodArabic = 'خوارزمية جينية';
  int _numMeals = 5;

  Future<void> _submit() async {
    final target = double.tryParse(_controller.text);
    if (target == null) return;

    setState(() => _loading = true);
    final res = await http.post(
      Uri.parse('http://127.0.0.1:8000/plans/run'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'target_calories': target,
        'method': methodMap[_methodArabic],
        'num_meals': _numMeals,
      }),
    );
    final planMap = jsonDecode(res.body);
    Provider.of<PlanModel>(context, listen: false).setPlan(planMap);
    setState(() => _loading = false);
    Navigator.pushNamed(context, '/plan');
  }

  Widget buildInput({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('تخصيص السعرات الحرارية', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.pink[300],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      buildInput(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'السعرات المطلوبة',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      buildInput(
                        child: DropdownButtonFormField<String>(
                          value: _methodArabic,
                          decoration: InputDecoration(
                            labelText: 'الخوارزمية',
                            border: InputBorder.none,
                          ),
                          items: methodMap.keys
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) => setState(() => _methodArabic = v!),
                        ),
                      ),
                      buildInput(
                        child: TextFormField(
                          initialValue: '$_numMeals',
                          decoration: InputDecoration(
                            labelText: 'عدد الوجبات',
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _numMeals = int.tryParse(v) ?? 5,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('احصل على الخطة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
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

// التمويج السفلي
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
