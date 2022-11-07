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
  static const _textStyle = TextStyle(color: Colors.white);
  M3U? data;
  String? outputFileName;
  String? outputDirectory;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40), // NEW
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

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: Column(children: [
            const Text("Create new local playlist", style: _textStyle),
            Row(
              children: [
                const Text("Filename", style: _textStyle),
                Expanded(child: TextField(
                  style: _textStyle,
                  onChanged: (text) {
                    outputFileName = text;
                  },
                ),),
              ],
            ),
            OutlinedButton(
              onPressed: () async {
                String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                setState(() {
                  outputDirectory = selectedDirectory;
                });
              },
              child: const Text("Choose output directory", style: _textStyle)
            ),
            if(outputDirectory != null) ... [
              Text("Output directory : $outputDirectory", style: _textStyle),
            ],
            OutlinedButton(
                onPressed: () async {
                  bool fileError = false;
                  if(outputFileName != null && outputDirectory != null) {
                    //Create file & return M3U
                    try {
                      debugPrint("Creating new .m3u at : $outputDirectory/$outputFileName.m3u");
                      var m3u = M3U("$outputDirectory/$outputFileName.m3u", readExisting: false);
                      data = m3u;
                      widget.m3uCallback(data);
                      return;
                    } catch (e) {
                      fileError = true;
                    }
                  }

                  String message = '';
                  if(outputFileName == null || outputDirectory == null) {
                    message = "You must enter a filename and choose an output directory";
                  } else if (fileError) {
                    message = "Could not create file. Make sure you have a valid filename and path.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),));
                },
                child: const Text("Create", style: _textStyle)
            ),
          ],),
        ),
      ],
    );
  }
}
