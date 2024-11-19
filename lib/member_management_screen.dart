// member_management_screen.dart


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberManagementScreen extends StatelessWidget {
  final String groupId; // ID của nhóm

  MemberManagementScreen({required this.groupId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm thêm thành viên
  Future<void> addMember(String email, BuildContext context) async {
    try {
      // Lấy thông tin user từ email
      var userQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        String uid = userQuery.docs.first.id;

        // Thêm user vào danh sách members
        await _firestore.collection('groups').doc(groupId).update({
          'members.$uid': {
            'name': userData['name'],
            'email': email,
            'role': 'member',
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thành viên đã được thêm thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email không tồn tại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm thành viên: $e')),
      );
    }
  }

  // Hàm xoá thành viên
  Future<void> removeMember(String uid, BuildContext context) async {
    try {
      // Hiển thị dialog xác nhận xoá
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Xác nhận'),
            content: Text('Bạn có chắc chắn muốn xoá thành viên này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xoá'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await _firestore.collection('groups').doc(groupId).update({
          'members.$uid': FieldValue.delete(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thành viên đã được xoá!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xoá thành viên: $e')),
      );
    }
  }

  // Kiểm tra quyền hạn
  Future<bool> isLeader(String userId) async {
    var groupDoc = await _firestore.collection('groups').doc(groupId).get();
    return groupDoc.data()?['leaderId'] == userId;
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý thành viên"),
      ),
      body: FutureBuilder<bool>(
        future: isLeader(currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          bool isCurrentUserLeader = snapshot.data!;

          if (!isCurrentUserLeader) {
            return Center(child: Text("Bạn không có quyền quản lý thành viên."));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('groups').doc(groupId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var groupData = snapshot.data!.data() as Map<String, dynamic>;
              var members = groupData['members'] as Map<String, dynamic>;

              return ListView(
                children: members.entries.map((entry) {
                  String uid = entry.key;
                  var member = entry.value;

                  return ListTile(
                    title: Text(member['name']),
                    subtitle: Text(member['email']),
                    trailing: uid == groupData['leaderId']
                        ? Text("Leader", style: TextStyle(color: Colors.blue))
                        : IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              removeMember(uid, context);
                            },
                          ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hiển thị dialog để nhập email thành viên mới
          showDialog(
            context: context,
            builder: (context) {
              String email = "";
              return AlertDialog(
                title: Text("Thêm thành viên"),
                content: TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: InputDecoration(labelText: "Nhập email thành viên"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addMember(email, context);
                      Navigator.pop(context);
                    },
                    child: Text("Thêm"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
