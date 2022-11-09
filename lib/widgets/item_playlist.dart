import 'package:flutter/material.dart';
import 'package:yt_dlf/utils/m3u.dart';

class PlaylistEntryView extends StatefulWidget {
  final PlaylistEntry entry;
  const PlaylistEntryView({super.key, required this.entry});

  @override
  State<PlaylistEntryView> createState() => _PlaylistEntryViewState();
}

class _PlaylistEntryViewState extends State<PlaylistEntryView> {
  late PlaylistEntry entry;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: Column(
        children: [
          Expanded(child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text("Source"),
                Text(entry.source, style: const TextStyle(color: Colors.grey),),
                TextFormField(
                  enabled: false,
                  initialValue: entry.source,
                ),
                const Text("Author"),
                TextFormField(
                  initialValue: entry.author,
                  onChanged: (value) => entry = PlaylistEntry(title: entry.title, author: value, source: entry.source),
                ),
                const Text("Title"),
                TextFormField(
                  initialValue: entry.title,
                  onChanged: (value) => entry = PlaylistEntry(title: value, author: entry.author, source: entry.source),
                ),

              ],
            ),
          ),),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () {
              Navigator.pop(context, entry);
            },
            child: const Text("Save"),
          ),
        ],
      )
    );
  }
}
