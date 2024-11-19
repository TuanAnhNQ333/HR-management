// create_event_screen.dart


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventScreen extends StatelessWidget {
  final String groupId; // ID của nhóm

  CreateEventScreen({required this.groupId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  Future<void> createEvent() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Tạo sự kiện mới trong Firebase
      await _firestore.collection('groups').doc(groupId).update({
        'events': FieldValue.arrayUnion([
          {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'date': _dateController.text,
            'time': _timeController.text,
            'createdBy': userId
          }
        ])
      });

      print("Sự kiện đã được tạo thành công!");
    } catch (e) {
      print("Lỗi khi tạo sự kiện: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tạo sự kiện"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Tiêu đề sự kiện"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Mô tả sự kiện"),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: "Ngày (YYYY-MM-DD)"),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "Thời gian (HH:MM)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await createEvent();
                Navigator.pop(context);
              },
              child: Text("Tạo sự kiện"),
            )
          ],
        ),
      ),
    );
  }
}
