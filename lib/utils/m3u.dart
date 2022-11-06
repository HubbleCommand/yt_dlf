//Helper class for *.m3u files
//Will only handle the two accepted standard directives :
//
// https://en.wikipedia.org/wiki/M3U
import 'dart:convert';
import 'dart:io';

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

  M3U(this.source){
    File src = File(source);
    if(src.existsSync()) {
      //If the file already exists, we can read the data present
      //List<String> lines = [];
      //src.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) { lines.add(line); });

      //for(int i = 1)
      src.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
        //if
      });
    }
  }

  addEntry(String title, String author, String source) {
    _entries.add(_PlaylistEntry(title: title, author: author, source: source));
  }

  String getAsString() {
    String result = "$headerFile\n";
    for(int i = 0; i < _entries.length - 1; i++) {
      result += "$headerEntry:$i,${_entries[i].author} - ${_entries[i].title}\n";
      result += '${_entries[i].source}\n';
    }
    return result;
  }

  write() {
    var file = File(source);
    file.writeAsString(getAsString());
  }
}
