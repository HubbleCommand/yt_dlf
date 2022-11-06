//Helper class for *.m3u files
//Will only handle the two accepted standard directives :
//
// https://en.wikipedia.org/wiki/M3U
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class _PlaylistEntry {
  final String title;
  final String author;
  final String source;

  @override
  String toString() {
    return 'title : $title name : $author source : $source';
  }

  _PlaylistEntry({required this.title, required this.author, required this.source});
}

class M3U {
  static const String headerFile = "#EXTM3U";
  static const String headerEntry = "#EXTINF";

  String source;
  final List<_PlaylistEntry> _entries = [];

  M3U(this.source, {bool readExisting = true}){
    File src = File(source);

    if(readExisting) {
      if(src.existsSync()) {
        //If the file already exists, we can read the data present

        String? title;
        String? author;
        src.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
          if(line.startsWith(headerFile)){
            //continue;
          } else if (line.startsWith(headerEntry)){
            String valid = line.split(",")[1];
            author = valid.split(" - ")[0];
            title = valid.split(" - ")[1];
          } else {
            try {
              debugPrint(line);
              File src = File(line);

              //Split filename to get title & author
              String fileNameNoExtension = src.uri.pathSegments.last.split(".").first;

              String titleLoc = title ?? fileNameNoExtension.split(" - ").first;
              String authorLoc = author ?? fileNameNoExtension.split(" - ")[1];
              _entries.add(_PlaylistEntry(title: titleLoc, author: authorLoc, source: line));
            } on FileSystemException catch (_, e) {
              //Not a valid file string...
            } finally {
              title = author = null;
            }
          }
        });
      }
    }

    debugPrint(getAsString());
  }

  addEntry(String title, String author, String source) {
    //If source already exists, don't add
    for(var entry in _entries) {
      if(entry.source == source) {
        return;
      }
    }
    _entries.add(_PlaylistEntry(title: title, author: author, source: source));
  }

  String getAsString() {
    String result = "$headerFile\n\n";
    for(int i = 0; i < _entries.length - 1; i++) {
      result += "$headerEntry:$i, ${_entries[i].author} - ${_entries[i].title}\n";
      result += '${_entries[i].source}\n';
    }
    return result;
  }

  write() {
    var file = File(source);
    file.writeAsString(getAsString());
  }
}
