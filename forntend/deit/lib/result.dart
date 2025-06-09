import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<dynamic> exercises = [];
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final gender = args['gender'];
    final goal = args['goal'];
    _fetchExercises(gender, goal);
  }

  Future<void> _fetchExercises(String gender, String goal) async {
    final url = Uri.parse('http://127.0.0.1:8000/exercises?gender=$gender&goal=$goal');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        exercises = decoded['results'] ?? [];
        print(decoded['results']);

        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل التمارين')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('التمارين المقترحة'),
      ),
      extendBody: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final ex = exercises[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 4,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.pink[200],
                                child: Icon(Icons.fitness_center, color: Colors.white),
                              ),
                              title: Text(
                                ex['name'] ?? 'تمرين غير معروف',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("التصنيف: ${ex['category'] ?? 'غير محدد'}"),
                                  Text("المستوى: ${ex['level'] ?? 'غير محدد'}"),
                                  Text("الأداة: ${ex['equipment'] ?? 'بدون معدات'}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  height: 80,
                  color: Colors.pink[200],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
        size.width * 0.25, 40, size.width * 0.5, 20);
    path.quadraticBezierTo(
        size.width * 0.75, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
