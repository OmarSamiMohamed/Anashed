import 'package:anashed/core/widgets/category.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AnashedApp());
}

class AnashedApp extends StatelessWidget {
  const AnashedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> anashedList = [
      {
        "name": "قول الصوارم",
        "image": "assets/photos/image.jpg",
        "sound": "sounds/qaoulswalem.mp3",
      },
      {
        "name": "ربنا رب القلوب",
        "image": "assets/photos/photo2.jpg",
        "sound": "sounds/rabAlklob.mp3",
      },
      {
        "name": "قلبي في المدينة",
        "image": "assets/photos/photo3.jpg",
        "sound": "sounds/qalpifelmadinah.mp3",
      },
      {
        "name": "نور الله فجرا",
        "image": "assets/photos/photo4.jpg",
        "sound": "sounds/nourAllah.mp3",
      },
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anashed',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily:
            'Cairo', // إذا كنت تستخدم خط القاهرة، وإلا سيستعمل الافتراضي
      ),
      home: Scaffold(
        // خلفية داكنة عميقة وعصرية جداً لتطبيقات الصوتيات
        backgroundColor: const Color(0xFF0F172A),

        appBar: AppBar(
          title: const Text(
            "أناشيد | Anashed",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF59E0B), // لون ذهبي هادئ
              letterSpacing: 0.8,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(
            0xFF1E293B,
          ), // أغمق قليلاً من الخلفية ليفصل الـ AppBar
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                20,
              ), // انحناء خفيف أسفل الـ AppBar ليعطيه لمسة عصرية
            ),
          ),
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نص ترحيبي وجذاب قبل قائمة الأناشيد
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
              child: Text(
                "قائمتك المفضلة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // القائمة الأساسية للأناشيد
            Expanded(
              child: ListView.builder(
                physics:
                    const BouncingScrollPhysics(), // تأثير تمرير ناعم (iOS style)
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                itemCount: anashedList.length,
                itemBuilder: (context, index) {
                  final item = anashedList[index];
                  return CategoryItem(
                    songName: item["name"]!,
                    imagePath: item["image"]!,
                    songPath: item["sound"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
