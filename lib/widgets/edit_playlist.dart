import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EditPlaylistView extends StatefulWidget {
  const EditPlaylistView({super.key});

  @override
  State<EditPlaylistView> createState() => _EditPlaylistViewState();
}

class _EditPlaylistViewState extends State<EditPlaylistView> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Coming Soon'),
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['m3u', 'm3u8'],
            );
          },
          child: const Text("Edit Playlist File"),
        ),
      ],
    );
  }
}
