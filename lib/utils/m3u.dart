//Helper class for *.m3u files
//Will only handle the two accepted standard directives : #EXTM3U and #EXTINF
// https://en.wikipedia.org/wiki/M3U
// https://docs.fileformat.com/audio/m3u/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class PlaylistEntry {
  final String title;
  final String author;
  final String source;

  @override
  String toString() {
    return 'title : $title name : $author source : $source';
  }

  PlaylistEntry({required this.title, required this.author, required this.source});
}

class M3U {
  static const String headerFile = "#EXTM3U";
  static const String headerEntry = "#EXTINF";

  String source;
  final List<PlaylistEntry> _entries = [];

  get length => _entries.length;
  operator [](int i) => _entries[i];

  static String filenameToTitle(String name) {
    List<String> split = name.split(" - ");

    return split.length == 2 ? split.first : name;
  }

  static String filenameToAuthor(String name) {
    List<String> split = name.split(" - ");

    return split.length == 2 ? split[1] : "Unknown";
  }

  static String makeEntryName(String title, String author) {
    return '$author - $title';
  }

  flip(int indexA, int indexB) {
    if(indexA < 0) {
      indexA = _entries.length + indexA;
    }
    if(indexB < 0) {
      indexB = _entries.length + indexB;
    }
    if(indexA >= _entries.length) {
      indexA = indexA - _entries.length;
    }
    if(indexB >= _entries.length) {
      indexB = indexB - _entries.length;
    }

    if(indexA != indexB) {
      PlaylistEntry a = _entries[indexA];

      _entries[indexA] = _entries[indexB];
      _entries[indexB] = a;
    }
  }

  PlaylistEntry get(int index) {
    return _entries[index];
  }

  removeAt(int index) {
    _entries.removeAt(index);
  }

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
          } else if (line.isNotEmpty) {
            try {
              debugPrint(line);
              File src = File(line);

              //Split filename to get title & author
              String fileNameNoExtension = src.uri.pathSegments.last.split(".").first;

              String titleLoc = title ?? fileNameNoExtension.split(" - ").first;
              String authorLoc = author ?? fileNameNoExtension.split(" - ")[1];
              _entries.add(PlaylistEntry(title: titleLoc, author: authorLoc, source: line));
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
    _entries.add(PlaylistEntry(title: title, author: author, source: source));
  }

  String getAsString() {
    String result = "$headerFile\n\n";
    for(int i = 0; i < _entries.length; i++) {
      result += "$headerEntry:$i, ${makeEntryName(_entries[i].title, _entries[i].author)}\n";
      result += '${_entries[i].source}\n';
    }
    return result;
  }

  write() {
    var file = File(source);
    file.writeAsString(getAsString());
  }
}
