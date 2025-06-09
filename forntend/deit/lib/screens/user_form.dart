import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/user.dart';

class UserFormScreen extends StatefulWidget {
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // خرائط الترجمة
  final genderMap = {'ذكر': 'male', 'أنثى': 'female'};
  final activityMap = {
    'منخفض': 'low',
    'خفيف': 'light',
    'متوسط': 'moderate',
    'مرتفع': 'high'
  };
  final goalMap = {
    'فقدان الوزن': 'lose',
    'الحفاظ على الوزن': 'maintain',
    'زيادة الوزن': 'gain'
  };

  // الحقول العربية للعرض
  String _name = '';
  int _age = 18;
  String _genderArabic = 'ذكر';
  double _height = 170.0;
  double _weight = 70.0;
  String _activityArabic = 'متوسط';
  String _goalArabic = 'الحفاظ على الوزن';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _name,
        'age': _age,
        'gender': genderMap[_genderArabic],
        'height': _height,
        'weight': _weight,
        'activity_level': activityMap[_activityArabic],
        'goal': goalMap[_goalArabic],
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      Provider.of<UserModel>(context, listen: false).setUser(data);
      Navigator.pushNamed(context, '/generator');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء المستخدم')),
      );
    }

    setState(() => _loading = false);
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("لماذا نحتاج هذه البيانات؟", style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          "نستخدم هذه المعلومات لحساب احتياجاتك من السعرات بدقة، ومساعدتك في اختيار الخطة الأنسب لهدفك، سواء كان فقدان الوزن أو الحفاظ عليه أو زيادته.",
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            child: Text("فهمت", style: TextStyle(color: Colors.pink[400])),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('بيانات المستخدم', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildInput(
                          child: TextFormField(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'الاسم'),
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                            onSaved: (v) => _name = v!.trim(),
                          ),
                        ),
                        buildInput(
                          child: TextFormField(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'العمر'),
                            keyboardType: TextInputType.number,
                            initialValue: '18',
                            validator: (v) {
                              final age = int.tryParse(v!);
                              return (age == null || age < 1) ? 'عمر غير صالح' : null;
                            },
                            onSaved: (v) => _age = int.parse(v!),
                          ),
                        ),
                        buildInput(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'الجنس'),
                            value: _genderArabic,
                            items: genderMap.keys
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _genderArabic = v!),
                          ),
                        ),
                        buildInput(
                          child: TextFormField(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'الطول (سم)'),
                            keyboardType: TextInputType.number,
                            initialValue: '170',
                            validator: (v) {
                              final h = double.tryParse(v!);
                              return (h == null || h <= 0) ? 'طول غير صالح' : null;
                            },
                            onSaved: (v) => _height = double.parse(v!),
                          ),
                        ),
                        buildInput(
                          child: TextFormField(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'الوزن (كغ)'),
                            keyboardType: TextInputType.number,
                            initialValue: '70',
                            validator: (v) {
                              final w = double.tryParse(v!);
                              return (w == null || w <= 0) ? 'وزن غير صالح' : null;
                            },
                            onSaved: (v) => _weight = double.parse(v!),
                          ),
                        ),
                        buildInput(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'النشاط'),
                            value: _activityArabic,
                            items: activityMap.keys
                                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                                .toList(),
                            onChanged: (v) => setState(() => _activityArabic = v!),
                          ),
                        ),
                        buildInput(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(border: InputBorder.none, labelText: 'الهدف'),
                            value: _goalArabic,
                            items: goalMap.keys
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _goalArabic = v!),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('إرسال'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
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
              ),
            ],
          ),

          // زر حول (ثابت فوق التمويج)
          Positioned(
            bottom: 100,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.info_outline, size: 30, color: Colors.pink[300]),
              onPressed: _showInfoDialog,
              tooltip: "حول هذه البيانات",
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

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    var firstControlPoint = Offset(size.width / 4, 40);
    var firstEndPoint = Offset(size.width / 2, 20);
    var secondControlPoint = Offset(size.width * 3 / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
