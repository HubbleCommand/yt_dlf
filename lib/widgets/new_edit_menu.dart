import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yt_dlf/utils/m3u.dart';

class NewEditPlaylistView extends StatefulWidget {
  final Function m3uCallback;
  const NewEditPlaylistView({super.key, required this.m3uCallback});

  @override
  State<NewEditPlaylistView> createState() => _NewEditPlaylistViewState();
}

class _NewEditPlaylistViewState extends State<NewEditPlaylistView> {
  M3U? data;
  String? outputFileName;
  String? fileOutputDirectory;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), // NEW
          ),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['m3u', 'm3u8'],
            );

            //Load playlist...
            setState(() {
              if(result != null && result.files.single.path != null) {
                debugPrint("Loaded : ${result.files.single.path}");
                data = M3U(result.files.single.path!);
              } else {
                debugPrint("No playlist file found");
                data = null;
              }

              widget.m3uCallback(data);
            });
          },
          child: const Text("Edit Existing Playlist"),
        ),
        const Text("Create new local playlist"),
        Row(
          children: [

            const Text("Filename"),
            Expanded(child: TextField(
              cursorColor: outputFileName == null || outputFileName!.isEmpty ? Colors.red : Colors.black,
              onChanged: (text) {
                outputFileName = text;
              },
            ),),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), // NEW
          ),
          onPressed: () async {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
            setState(() {
              fileOutputDirectory = selectedDirectory;
            });
          },
          child: const Text("Choose output directory")
        ),
      ],
    );
  }
}
