import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Nickname.dart'; // Import the Nickname screen

class StudentVerification extends StatefulWidget {
  const StudentVerification({super.key, required void Function() onVerificationComplete});

  @override
  _StudentVerificationState createState() => _StudentVerificationState();
}

class _StudentVerificationState extends State<StudentVerification> {
  String? selectedUniversity;
  final emailController = TextEditingController();
  final apiKey = 'YOUR_API_KEY_HERE'; // 실제 API 키로 교체하세요

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text('재학생 인증', style: TextStyle(fontSize: 24)),
          DropdownButtonFormField<String>(
            value: selectedUniversity,
            items: universities.map((univ) {
              return DropdownMenuItem(
                value: univ,
                child: Text(univ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedUniversity = value;
              });
            },
            decoration: const InputDecoration(labelText: '소속된 학교를 선택하세요'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: '이메일 주소'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedUniversity != null && emailController.text.isNotEmpty) {
                _startCertification(selectedUniversity!, emailController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('학교와 이메일을 모두 입력하세요')),
                );
              }
            },
            child: const Text('웹 메일로 인증하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCertification(String university, String email) async {
    final url = Uri.parse('https://univcert.com/api/v1/certify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'key': apiKey,
        'email': email,
        'univName': university,
        'univ_check': true, // 대학 재학 여부 확인
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final code = data['code']; // 인증 코드 발송
      _showCodeDialog(email, university, code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 요청 실패')),
      );
    }
  }

  void _showCodeDialog(String email, String university, int code) {
    showDialog(
      context: context,
      builder: (context) {
        final codeController = TextEditingController();
        return AlertDialog(
          title: const Text('인증 코드 입력'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(labelText: '인증 코드'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _verifyCode(email, university, int.parse(codeController.text));
              },
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyCode(String email, String university, int code) async {
    final url = Uri.parse('https://univcert.com/api/v1/certifycode');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'key': apiKey,
        'email': email,
        'univName': university,
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 성공')),
      );

      // 닉네임 입력 화면으로 이동
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Nickname()),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 실패')),
      );
    }
  }
}

// 아래는 드롭다운에 사용할 학교 리스트입니다
final List<String> universities = [
  '서울대학교',
  '한국예술종합학교',
  '서울과학기술대학교',
  '서울교육대학교',
  '한국체육대학교',
  '서울시립대학교',
  '가톨릭대학교',
  '중앙대학교',
  '덕성여자대학교',
  '동국대학교',
  '동덕여자대학교',
  '명지대학교',
  '상명대학교',
  '서강대학교',
  '서경대학교',
  '서울여자대학교',
  '성공회대학교',
  '성신여자대학교',
  '세종대학교',
  '숙명여자대학교',
  '숭실대학교',
  '연세대학교',
  '이화여자대학교',
  '장로회신학대학교',
  '총신대학교',
  '한국외국어대학교',
  '한성대학교',
  '한양대학교',
  '홍익대학교',
  '고려대학교',
  '성균관대학교',
  '광운대학교',
  '국민대학교'
];
