// events_screen.dart


// events_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatelessWidget {
  final String groupId; // ID của nhóm

  EventsScreen({required this.groupId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sự kiện"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Thêm chức năng làm mới sự kiện
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Có lỗi khi tải dữ liệu"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Không tìm thấy dữ liệu nhóm."));
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          var events = groupData['events'] as List<dynamic>;

          if (events.isEmpty) {
            return Center(child: Text("Không có sự kiện nào."));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              DateTime eventDate = DateTime.parse(event['date']);
              String formattedDate = DateFormat('dd MMM yyyy').format(eventDate);
              String formattedTime = DateFormat('HH:mm').format(eventDate);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    event['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("$formattedDate - $formattedTime"),
                  leading: Icon(Icons.event, color: Colors.blue),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    _showEventDetails(context, event);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hàm hiển thị chi tiết sự kiện
  void _showEventDetails(BuildContext context, dynamic event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ngày: ${event['date']}"),
              Text("Thời gian: ${event['time']}"),
              SizedBox(height: 10),
              Text(event['description']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Đóng"),
            ),
            TextButton(
              onPressed: () {
                // Chức năng chỉnh sửa sự kiện có thể được thêm vào đây
              },
              child: Text("Chỉnh sửa"),
            ),
            TextButton(
              onPressed: () {
                // Thêm sự kiện vào lịch
              },
              child: Text("Thêm vào lịch"),
            ),
          ],
        );
      },
    );
  }
}
