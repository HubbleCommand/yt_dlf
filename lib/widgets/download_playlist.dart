import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_dlf/utils/m3u.dart';
import 'package:yt_dlf/utils/error_message.dart';

class DownloadPlaylistView extends StatefulWidget {
  const DownloadPlaylistView({super.key});

  @override
  State<DownloadPlaylistView> createState() => _DownloadPlaylistViewState();
}

class _DownloadPlaylistViewState extends State<DownloadPlaylistView> {
  //Playlist details
  var url;
  bool onlyAudio = true;
  String? fileOutputDirectory;

  //Download status
  bool downloading = false;
  int count = 0;
  int counter = 0;
  String currentName = '';
  List<ErrorMessage> errorMessages = [];

  Future downloadPlaylist() async {
    setState(() {
      errorMessages = [];
      downloading = true;
    });

    //https://www.youtube.com/playlist?list=PLlTveFoZ8MM6_i6hfuCm4v-k8juxTL7I8
    //TODO can pass custom YoutubeHttpClient()
    //var yt = YoutubeExplode(YoutubeHttpClient());
    //https://github.com/Tyrrrz/YoutubeExplode/issues/110
    //https://pub.dev/documentation/youtube_explode_dart/latest/youtube_explode/YoutubeExplode-class.html
    //https://pub.dev/documentation/youtube_explode_dart/latest/youtube_explode/YoutubeHttpClient-class.html
    var yt = YoutubeExplode();
    Playlist playlist;
    try {
      playlist = await yt.playlists.get(url);
      debugPrint("playlist : $playlist");
    } catch (e) {
      debugPrint("ERROR PARSING URL");
      setState(() {
        downloading = false;
        errorMessages = [...errorMessages, ErrorMessage(message: "ERROR PARSING URL", level: Level.ERROR)];
      });
      return;
    }

    if(playlist.videoCount == null ||playlist.videoCount == 0) {
      setState(() {
        downloading = false;
        errorMessages = [...errorMessages, ErrorMessage(message: "NO VIDEOS", level: Level.ERROR)];
      });
      return;
    }

    var m3u = M3U("$fileOutputDirectory/${playlist.title}.m3u");
    setState(() {
      count = playlist.videoCount!;
      counter = 0;
    });

    await for (var video in yt.playlists.getVideos(playlist.id)) {
      var videoTitle = video.title.replaceAll(RegExp('[^A-Z a-z 0-9]'), "");
      var videoAuthor = video.author.replaceAll(RegExp('[^A-Z a-z 0-9]'), "");
      setState(() {
        currentName = videoTitle;
        counter += 1;
      });

      StreamManifest videoManifest;
      try {
        //TODO handle if is age restricted, pass token or use HTTPClient
        videoManifest = await yt.videos.streamsClient.getManifest(video.id);
        debugPrint(videoManifest.toString());
      } catch (e) {
        setState(() {
          errorMessages = [...errorMessages, ErrorMessage(message: "Couldn't download video : ${video.id}", level: Level.ERROR)];
        });

        debugPrint("Couldn't download video : ${video.id}");
        continue;
      }

      AudioStreamInfo streamInfo;
      if(onlyAudio) {
        streamInfo = videoManifest.audioOnly.withHighestBitrate();
      } else {
        streamInfo = videoManifest.muxed.withHighestBitrate();
      }

      var stream = yt.videos.streamsClient.get(streamInfo);

      var extension = streamInfo.codec.subtype;
      var name = "$videoTitle - $videoAuthor";

      var path = "$fileOutputDirectory/$name.$extension";
      debugPrint(path);
      var file = File(path);

      if(!file.existsSync()) {
        debugPrint("DOESN'T EXIST, DOWNLOADING");
        //If the file exists, then we don't need to download
        var fileStream = file.openWrite();
        debugPrint("STREAM $fileStream");

        try {
          await stream.pipe(fileStream);
          await fileStream.flush();
          await fileStream.close();

          m3u.addEntry(videoTitle, videoAuthor, "$fileOutputDirectory/$name.$extension");
        } catch (e) {
          setState(() {
            errorMessages = [...errorMessages, ErrorMessage(message: "Couldn't save file : ${video.id}", level: Level.ERROR)];
          });

          debugPrint("ERROR DOWNLOADING FILE : ${video.id}");
          debugPrint("$e");
        }
      } else {
        debugPrint("EXISTS, setting in file");
        setState(() {
          errorMessages = [...errorMessages, ErrorMessage(message: "Video : ${video.id} already exists", level: Level.WARNING)];
        });

        m3u.addEntry(videoTitle, videoAuthor, "$fileOutputDirectory/$name.$extension");
      }
    }

    yt.close();
    m3u.write();

    setState(() {
      count = 0;
      counter = 0;
      currentName = '';
      downloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Youtube playlist URL or playlist ID'),
        TextField(
          style: TextStyle(color: downloading ? Colors.grey : Colors.black),
          enabled: !downloading,
          onChanged: (text) {
            url = text;
            debugPrint(url);
          },
        ),
        ElevatedButton(
          onPressed: () async {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
            setState(() {
              fileOutputDirectory = selectedDirectory;
            });
          },
          child: const Text("Choose output directory"),
        ),
        ListTile(
          title: const Text('Video'),
          leading: Radio<bool>(
            value: false,
            groupValue: onlyAudio,
            onChanged: (bool? value) {
              setState(() {
                debugPrint("Only audio : $onlyAudio");
                if(value != null) {
                  onlyAudio = value;
                }
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Audio'),
          leading: Radio<bool>(
            value: true,
            groupValue: onlyAudio,
            onChanged: (bool? value) {
              setState(() {
                debugPrint("Only audio : $onlyAudio");
                if(value != null) {
                  onlyAudio = value;
                }
              });
            },
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: downloading ? Colors.blueGrey : Colors.blue),
          onPressed: fileOutputDirectory == null || downloading ? null : downloadPlaylist,
          child: Text(fileOutputDirectory == null ? "Select output directory before downloading" : downloading ? "Downloading" : "Download Playlist"),
        ),
        if(downloading) ... [
          const CircularProgressIndicator(),
          Text("Downloading $counter / $count", textAlign: TextAlign.center),
          Text(currentName, textAlign: TextAlign.center),
        ],
        Visibility(
          visible: errorMessages.isEmpty ? false : true,
          child: Expanded(child: SingleChildScrollView(
            child: Column(children: [
              for(ErrorMessage message in errorMessages)...[
                Text(message.message, style: TextStyle(color: message.color),)
              ],
            ],),
          ),),
        )
      ],
    );
  }
}
