
//Helper class for *.m3u files
//Will only handle the two accepted standard directives :
//
// https://en.wikipedia.org/wiki/M3U
import 'dart:io';
import 'package:flutter/cupertino.dart';

class _PlaylistEntry {
  final String name;
  final String source;

  @override
  String toString() {
    return 'name : $name source : $source';
  }

  _PlaylistEntry({required this.name, required this.source});
}

class M3U {
  String source;
  final List<_PlaylistEntry> _entries = [];

  M3U(this.source);

  addEntry(String name, String source) {
    _entries.add(_PlaylistEntry(name: name, source: source));
  }

  String getAsString() {
    String result = "#EXTM3U\n";
    for(int i = 0; i < _entries.length - 1; i++) {
      result += "#EXTINF:$i,Example Artist name - ${_entries[i].name}\n";
      result += '${_entries[i].source}\n';
    }
    return result;
  }

  write() {
    var file = File(source);
    file.writeAsString(getAsString());
  }
}
