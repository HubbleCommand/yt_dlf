import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yt_dlf/utils/m3u.dart';
import 'package:yt_dlf/widgets/item_playlist.dart';
import 'package:yt_dlf/widgets/new_edit_menu.dart';

class EditPlaylistView extends StatefulWidget {
  const EditPlaylistView({super.key});

  @override
  State<EditPlaylistView> createState() => _EditPlaylistViewState();
}

class _EditPlaylistViewState extends State<EditPlaylistView> {
  M3U? data;

  Widget _getBody() {
    if (!(data!.length > 0)) {
      return const Center(child: Text("No entries yet!"));
    } else {
      return SingleChildScrollView(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            //Needed for mobile https://stackoverflow.com/questions/59510116/the-singlechildscrollview-is-not-scrollable
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: data == null ? null : () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        PlaylistEntryView(entry: data!.get(index))),
                  );
                  if (result is PlaylistEntry) {
                    data!.setAt(index, result);
                    setState(() {
                      data = data;
                    });
                  }
                },
                leading: Text('${index + 1}'),
                title: Text(data!.get(index).title),
                subtitle: Text(data!.get(index).author),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            data!.removeAt(index);
                          });
                        }
                    ),
                    IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () {
                          setState(() {
                            data!.flip(index, index - 1);
                          });
                        }
                    ),
                    IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () {
                          setState(() {
                            data!.flip(index, index + 1);
                          });
                        }
                    ),
                  ],
                ),
              );
            },
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if(data == null) ... [
          NewEditPlaylistView(m3uCallback: (M3U? data) {
            debugPrint("Data is loaded in EditPlaylist, is of length : ${data?.length}");
            setState(() {
              this.data = data;
            });
          })
        ],

        if(data != null) ... [
          Padding(
            padding: const EdgeInsets.all(15), //apply padding to all four sides
            child: Text("Editing ${data?.source}"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () {
              setState(() {
                data = null;
              });
            },
            child: const Text("Reset"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () async {
              //Apparently don't need
              //https://github.com/miguelpruivo/flutter_file_picker/issues/1093
              //But still sometimes return cached paths instead of the real path
              await FilePicker.platform.clearTemporaryFiles();
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: true,
                allowedExtensions: ['mp3', 'mp4', 'webm'],
              );

              debugPrint("Res : $result");

              if (result != null) {
                List<File> files = result.paths.map((path) => File(path!)).toList();
                for (var element in files) {
                  if(element.uri.pathSegments.last.split(".")[1] == "m3u" || element.uri.pathSegments.last.split(".")[1] == "m3u8"){

                  } else {
                    String filename = element.uri.pathSegments.last.split(".").first;
                    data?.addEntry(M3U.filenameToTitle(filename), M3U.filenameToAuthor(filename), element.path);
                  }
                }
                setState(() {
                  data = data;
                });
              } else {
                // User canceled the picker
              }
            },
            child: const Text("Add items"),
          ),
          Expanded(
              child: _getBody()
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () {
              final data = this.data;
              if (data != null) {
                data.write();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ],
    );
  }
}
