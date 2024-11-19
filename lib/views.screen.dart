import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'home_screen.dart';

class Views extends StatefulWidget {
  const Views({super.key});

  @override
  _ViewsState createState() => _ViewsState();
}

class _ViewsState extends State<Views> {
  int _selectedIndex = 0; // Để theo dõi mục được chọn trong Bottom Navigation
  final List<Widget> _pages = [
    HomeScreen(),
    Container(color: Colors.green), // Thêm trang khác để kiểm tra
    Container(color: Colors.blue),  // Thêm trang khác để kiểm tra
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: PageController(initialPage: _selectedIndex),
              onPageChanged: _onItemTapped, // Khi trang thay đổi
              children: _pages,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(31, 40, 71, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(AntDesign.like1,
                          color: _selectedIndex == 0 ? Colors.blue : Colors.white,
                        ),
                        onPressed: () => _onItemTapped(0),
                      ),
                      IconButton(
                        icon: Icon(AntDesign.user,
                          color: _selectedIndex == 1 ? Colors.blue : Colors.white,
                        ),
                        onPressed: () => _onItemTapped(1),
                      ),
                      IconButton(
                        icon: Icon(AntDesign.menu_fold,
                          color: _selectedIndex == 2 ? Colors.blue : Colors.white,
                        ),
                        onPressed: () => _onItemTapped(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

