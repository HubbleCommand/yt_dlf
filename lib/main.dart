import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_dlf/widgets/bottom_navigation_bar_page.dart';
import 'package:yt_dlf/widgets/download_playlist.dart';
import 'package:yt_dlf/widgets/edit_playlist.dart';

void main() {
  runApp(const YTDLF());
}

class YTDLF extends StatelessWidget {
  const YTDLF({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube Download Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Permission.storage.status.then((value) {
      if (value != PermissionStatus.granted || value != PermissionStatus.limited) {
        Permission.storage.request().then((value){
          Permission.manageExternalStorage.status.then((valueInner) {
            if (valueInner != PermissionStatus.granted || value != PermissionStatus.limited) {
              Permission.manageExternalStorage.request().then((valueInner){
                debugPrint("Storage : ${value} External storage : ${valueInner}");
              });
            }
          });
        });
      }
    });
  }

  static final List<BottomNavigationBarPage> _pages = <BottomNavigationBarPage>[
    BottomNavigationBarPage(
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.download),
        label: 'Download',
        backgroundColor: Colors.red,
      ),
      pageView: const DownloadPlaylistView(),
    ),
    BottomNavigationBarPage(
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.edit),
        label: 'Edit',
        backgroundColor: Colors.red,
      ),
      pageView: const EditPlaylistView(),
    ),
  ];

  void _onBottomNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Youtube Download Flutter'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex).pageView,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          for(BottomNavigationBarPage item in _pages)...[
            item.bottomNavigationBarItem
          ],
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onBottomNavigationItemTapped,
      ),
    );
  }
}
