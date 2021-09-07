import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:grii_resmi/kri_whitelist.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'simple_audio_player_compat.dart';

class SongBook {
  final String name;
  final String title;
  final String year;

  const SongBook({required this.name, required this.title, required this.year});
}

const kPrefkeySongTextSizeZoom = 'songTextSizeZoom';
const defaultTextSize = 16.0;
const maxTextSizeZoom = 2.0;
const minTextSizeZoom = 0.675;

const defaultSongBook = SongBook(name: 'KRI', title: 'Kidung Reformed Injili', year: '2017');
const songBooks = [
  defaultSongBook,
  SongBook(name: 'KPRI', title: 'Kidung Persekutuan Reformed Injili', year: '2004'),
  SongBook(name: 'JB', title: 'Jiwaku Bersukacita', year: '2014'),
];

Future<Directory> getSongFilesDir() async => getTemporaryDirectory();

class SongsHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongsHomeState();
}

class _SongsHomeState extends State<SongsHome> {
  late SearchBar searchBar;
  String bookName = defaultSongBook.name;
  String? filterText;

  _SongsHomeState() {
    searchBar = SearchBar(
      setState: setState,
      buildDefaultAppBar: buildAppBar,
      onSubmitted: onSubmitted,
      closeOnSubmit: true,
    );
  }

  void onSubmitted(String value) {
    setState(() {
      if (value.isEmpty) {
        filterText = null;
      } else {
        filterText = value;
      }
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: filterText == null
          ? PopupMenuButton<String>(
              child: Row(children: <Widget>[
                Text(bookName),
                Icon(Icons.arrow_drop_down),
              ]),
              itemBuilder: (context) => [
                for (final songBook in songBooks)
                  PopupMenuItem(
                    value: songBook.name,
                    child: Row(children: <Widget>[
                      Icon(this.bookName == songBook.name ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Text(songBook.name),
                              SizedBox(width: 8.0),
                              Text(songBook.year, style: TextStyle(fontSize: 12.0)),
                            ]),
                            Text(songBook.title, style: TextStyle(fontSize: 12.0)),
                          ],
                        ),
                      ),
                    ]),
                  ),
              ],
              onSelected: (bookName) => setState(() {
                this.bookName = bookName;
                this.filterText = null;
              }),
            )
          : Row(children: <Widget>[
              Text(bookName),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(filterText!,
                      style: TextStyle(fontWeight: FontWeight.normal), overflow: TextOverflow.ellipsis),
                ),
              ),
            ]),
      actions: <Widget>[
        if (filterText == null) searchBar.getSearchAction(context),
        if (filterText != null)
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => setState(() {
              filterText = null;
            }),
          ),
        PopupMenuButton<String>(
          itemBuilder: (context) {
            return [
              PopupMenuItem(value: 'clear_all_song_files', child: Text("Clear all song files")),
            ];
          },
          onSelected: (selected) async {
            if (selected == 'clear_all_song_files') {
              final tempdir = await getSongFilesDir();
              await for (FileSystemEntity tempfile in tempdir.list()) {
                if (tempfile is! File) continue;
                tempfile.delete();
                debugPrint('Deleted $tempfile');
              }
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: SongListPage(bookName, filterText, key: Key("$bookName $filterText")),
    );
  }
}

class SongListPage extends StatefulWidget {
  final String bookName;
  final String? filterText;

  SongListPage(this.bookName, this.filterText, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SongListPageState();
  }
}

class _SongListPageState extends State<SongListPage> {
  final List<SongHeader> headers = <SongHeader>[];

  _SongListPageState();

  @override
  void initState() {
    super.initState();

    loadSongHeaders(widget.bookName).then((headers) {
      final tokens = widget.filterText == null
          ? <String>[]
          : widget.filterText!.toLowerCase().split(RegExp(r'\s+')).map((token) => token.toLowerCase());

      final filtered = headers.where((header) => tokens.every((token) {
            if (header.code.contains(token)) return true;
            if (header.title.toLowerCase().contains(token)) return true;
            final titleOriginal = header.titleOriginal;
            if (titleOriginal != null && titleOriginal.toLowerCase().contains(token)) return true;
            return false;
          }));

      if (mounted) {
        setState(() {
          this.headers.addAll(filtered);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.headers.isNotEmpty) {
      return ListView.builder(
        itemBuilder: _getRow,
        itemCount: headers.length,
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget _getRow(BuildContext context, int index) {
    final code = headers[index].code;

    return ListTile(
      title: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(width: 36.0, child: Text(code, textAlign: TextAlign.end)),
        ),
        Text(headers[index].title),
      ]),
      subtitle: Row(children: <Widget>[
        if (headers[index].titleOriginal != null) ...[
          SizedBox(width: 44.0),
          Text(headers[index].titleOriginal!),
        ]
      ]),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SongPage(widget.bookName, code, key: Key("${widget.bookName}/$code"));
        }));
      },
    );
  }
}

class SongHeader {
  final String code;
  final String title;
  final String? titleOriginal;

  SongHeader(this.code, this.title, this.titleOriginal);
}

Future<List<SongHeader>> loadSongHeaders(String bookName) async {
  final contents = await rootBundle.loadString("assets/$bookName/_list.txt");
  final lines = contents.split("\n");
  final res = <SongHeader>[];
  for (final line in lines) {
    if (line.length > 0) {
      final cols = line.split(";");
      res.add(SongHeader(cols[0], cols[1], cols[2]));
    }
  }
  return res;
}

class SongPage extends StatefulWidget {
  final String bookName;
  final String code;

  SongPage(this.bookName, this.code, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SongPageState();
  }
}

class _SongPageState extends State<SongPage> {
  get url => "http://files.bibleforandroid.com/addon/audio/songs/v2/${widget.bookName}_${widget.code}.mp3";
  bool wantAutoStart = false;
  bool downloadIsRunning = false;
  int downloadProgress = 0;
  int downloadTotal = 0;

  @override
  void initState() {
    super.initState();

    SimpleAudioPlayer.stop();

    SimpleAudioPlayer.statusNotifier.addListener(onChange);
    SimpleAudioPlayer.durationNotifier.addListener(onChange);
    SimpleAudioPlayer.positionNotifier.addListener(onChange);
    SimpleAudioPlayer.completeNotifier.addListener(onChange);
    SimpleAudioPlayer.errorNotifier.addListener(onChange);
  }

  onChange() {
    setState(() {
      final status = SimpleAudioPlayer.statusNotifier.value;

      print(
          "SAP: ${status.toString()} ${SimpleAudioPlayer.positionNotifier.value}/${SimpleAudioPlayer.durationNotifier.value} ${SimpleAudioPlayer.completeNotifier.value} ${SimpleAudioPlayer.errorNotifier.value}");

      if (wantAutoStart == true && status == Status.paused) {
        SimpleAudioPlayer.play();
        wantAutoStart = false;
      }

      if (SimpleAudioPlayer.completeNotifier.value == true && status == Status.paused) {
        SimpleAudioPlayer.seek(Duration());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    SimpleAudioPlayer.stop();

    SimpleAudioPlayer.statusNotifier.removeListener(onChange);
    SimpleAudioPlayer.durationNotifier.removeListener(onChange);
    SimpleAudioPlayer.positionNotifier.removeListener(onChange);
    SimpleAudioPlayer.completeNotifier.removeListener(onChange);
    SimpleAudioPlayer.errorNotifier.removeListener(onChange);
  }

  toolbarStartLoading() async {
    // kri whitelist check
    if (widget.bookName == 'KRI') {
      if (!kriWhitelist.contains(widget.code)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Belum tersedia.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
      return;
    }

    // check for existing file first
    final tempdir = await getSongFilesDir();
    final newfile = File("${tempdir.path}/${widget.bookName}_${widget.code}.mp3");
    if (await newfile.exists()) {
      setState(() {
        wantAutoStart = true;
        SimpleAudioPlayer.setDataSourceUrl("file://${newfile.path}");
      });
      return;
    }

    final client = Client();
    setState(() {
      wantAutoStart = true;
      downloadIsRunning = true;
    });

    client.send(Request('GET', Uri.parse(url))).then((resp) {
      if (resp.statusCode != 200) {
        setState(() {
          SimpleAudioPlayer.statusNotifier.value = Status.error;
          SimpleAudioPlayer.errorNotifier.value = "${resp.statusCode} ${resp.reasonPhrase}";
          downloadIsRunning = false;
        });
      } else {
        processResponse(resp);
      }
    }).catchError((error) {
      setState(() {
        SimpleAudioPlayer.statusNotifier.value = Status.error;
        SimpleAudioPlayer.errorNotifier.value = "$error";
        downloadIsRunning = false;
      });
    });
  }

  processResponse(StreamedResponse resp) async {
    setState(() {
      downloadProgress = 0;
      downloadTotal = resp.contentLength!;
    });

    final tempdir = await getSongFilesDir();
    final tempfile = File("${tempdir.path}/in_progress.mp3");
    final tempsink = tempfile.openWrite();

    await for (final bytes in resp.stream) {
      tempsink.add(bytes);

      setState(() {
        downloadProgress += bytes.length;
        print(downloadProgress);
      });
    }

    await tempsink.close();
    final newfile = File("${tempdir.path}/${widget.bookName}_${widget.code}.mp3");
    await tempfile.rename(newfile.path);

    setState(() {
      downloadIsRunning = false;
      downloadProgress = downloadTotal;

      SimpleAudioPlayer.setDataSourceUrl("file://${newfile.path}");
    });
  }

  toolbarPause() {
    setState(() {
      SimpleAudioPlayer.pause();
    });
  }

  toolbarResume() {
    setState(() {
      SimpleAudioPlayer.resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    final status = SimpleAudioPlayer.statusNotifier.value;

    if (downloadIsRunning) {
      actions.add(IconButton(icon: Icon(Icons.hourglass_full), onPressed: null));
    } else if (status == Status.stopped) {
      actions.add(IconButton(icon: Icon(Icons.play_arrow), onPressed: toolbarStartLoading));
    } else if (status == Status.playing) {
      actions.add(IconButton(icon: Icon(Icons.pause), onPressed: toolbarPause));
    } else if (status == Status.paused) {
      actions.add(IconButton(icon: Icon(Icons.play_arrow), onPressed: toolbarResume));
    } else if (status == Status.error) {
      actions.add(
        IconButton(
          icon: Icon(Icons.error),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(
                    "Error! Couldn't get song file for ${widget.bookName} ${widget.code}.\n\n${SimpleAudioPlayer.errorNotifier.value}"),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      key: Key("${widget.bookName}/${widget.code}"),
      appBar: AppBar(
        title: Text("${widget.bookName} ${widget.code}"),
        actions: actions,
      ),
      body: Column(children: <Widget>[
        SizedBox(
          height: 4.0,
          child: downloadIsRunning
              ? LinearProgressIndicator(value: downloadTotal == 0 ? null : downloadProgress / downloadTotal)
              : Container(),
        ),
        Expanded(child: SongBody(widget.bookName, widget.code)),
      ]),
    );
  }
}

class SongBody extends StatefulWidget {
  final String bookName;
  final String code;

  SongBody(this.bookName, this.code);

  @override
  State<StatefulWidget> createState() {
    return _SongBodyState(bookName, code);
  }
}

class _SongBodyState extends State<SongBody> {
  final String bookName;
  final String code;
  final List<SongLine> lines = <SongLine>[];
  AssetImage? image;
  SharedPreferences? sp;
  double zoom = 1.0;
  double? startZoom;

  _SongBodyState(this.bookName, this.code);

  @override
  void initState() {
    super.initState();
    loadSong();
  }

  loadSong() async {
    final lines = await loadSongLines(bookName, code);
    final image = await loadSongImage(bookName, code);
    sp = await SharedPreferences.getInstance();
    zoom = sp!.getDouble(kPrefkeySongTextSizeZoom) ?? 1.0;

    setState(() {
      this.lines.addAll(lines);
      this.image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final originalTheme = Theme.of(context).textTheme;
    final textTheme = originalTheme.copyWith(
      headline5:
          originalTheme.headline5?.copyWith(fontSize: 24.0 * zoom, backgroundColor: Colors.grey, color: Colors.white),
      headline6: originalTheme.headline6?.copyWith(fontSize: 24.0 * zoom),
      subtitle1: originalTheme.subtitle1?.copyWith(fontSize: 16.0 * zoom),
      caption: originalTheme.caption?.copyWith(fontSize: 14.0 * zoom, color: Colors.black),
      bodyText2: originalTheme.bodyText2?.copyWith(fontSize: 18.0 * zoom),
      bodyText1: originalTheme.bodyText1?.copyWith(fontSize: 16.0 * zoom),
    );

    return GestureDetector(
      child: Container(
        child: ListView.builder(
          itemCount: lines.length + (image != null ? 1 : 0),
          itemBuilder: (context, int index) {
            if (image != null && index == lines.length) {
              return _getImageRow(context);
            } else {
              return _getLineRow(context, index, textTheme, zoom);
            }
          },
        ),
      ),
      onScaleStart: (ScaleStartDetails details) {
        startZoom = zoom;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        if (startZoom == null) return;
        var newTextSizeZoom = details.scale * startZoom!;
        if (newTextSizeZoom < minTextSizeZoom) {
          newTextSizeZoom = minTextSizeZoom;
        } else if (newTextSizeZoom > maxTextSizeZoom) {
          newTextSizeZoom = maxTextSizeZoom;
        }
        setState(() {
          zoom = newTextSizeZoom;
          sp?.setDouble(kPrefkeySongTextSizeZoom, newTextSizeZoom);
        });
      },
      onScaleEnd: (ScaleEndDetails details) {
        startZoom = null;
      },
    );
  }

  Widget _getLineRow(BuildContext context, int index, TextTheme textTheme, double zoom) {
    final line = lines[index];

    if (line.type == 'empty') {
      return Container(height: 32.0 * zoom);
    }

    var style;
    switch (line.type) {
      case 'h1':
        style = textTheme.headline6;
        break;

      case 'h2':
        style = textTheme.subtitle1;
        break;

      case 'h3':
        style = textTheme.bodyText1;
        break;

      case 'h4':
        style = textTheme.caption;
        break;

      case 'p':
        style = textTheme.bodyText2;
        break;

      case 'pi':
        style = textTheme.bodyText2?.copyWith(fontStyle: FontStyle.italic);
        break;

      case 'caption':
        style = textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold);
        break;

      case 'no':
        style = textTheme.headline5;
        break;
    }

    toRichText(String s, TextStyle? style) {
      final spans = <TextSpan>[];

      int pos = 0;
      while (true) {
        int start = s.indexOf("<u>", pos);
        if (start == -1) {
          spans.add(TextSpan(text: s.substring(pos)));
          break;
        }

        spans.add(TextSpan(text: s.substring(pos, start)));
        pos = start + "<u>".length;

        int end = s.indexOf("</u>", pos);
        if (end == -1) {
          spans.add(TextSpan(text: s.substring(pos)));
          break;
        }

        spans.add(TextSpan(text: s.substring(pos, end), style: TextStyle(decoration: TextDecoration.underline)));
        pos = end + "</u>".length;
      }

      return RichText(text: TextSpan(text: "", style: style, children: spans));
    }

    Widget textWidget;
    if (line.text.contains("<")) {
      textWidget = toRichText(line.text, style);
    } else {
      if (line.type == 'no') {
        textWidget = Text('  ${line.text}  ', softWrap: true, style: style);
      } else if (line.type == 'h1' || line.type == 'h2' || line.type == 'h3' || line.type == 'h4') {
        textWidget = Text(line.text, softWrap: true, style: style, textAlign: TextAlign.center);
      } else {
        textWidget = Text(line.text, softWrap: true, style: style);
      }
    }

    return Container(margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), child: textWidget);
  }

  Widget _getImageRow(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Image(image: image!),
      ),
      onTap: () {
        openImageExternally(bookName, code);
      },
    );
  }
}

final channel = MethodChannel("com.thnkld.kidung.app/externalImageOpener");

openImageExternally(String bookName, String code) async {
  if (Platform.isAndroid) {
    print("start");
    channel.invokeMethod("openImageExternally", {"assetName": "assets/$bookName/$code.webp"});
    print("finish");
  } else {
    print("Unsupported platform ${Platform.operatingSystem}");
  }
}

class SongLine {
  final String type;
  final String text;

  SongLine(this.type, this.text);
}

List<String> splitInto2(String s, Pattern pattern) {
  final pos = s.indexOf(pattern);
  if (pos == -1) {
    return [s];
  } else {
    return [s.substring(0, pos), s.substring(pos + 1)];
  }
}

Future<List<SongLine>> loadSongLines(String bookName, String code) async {
  final contents = await rootBundle.loadString("assets/$bookName/$code.flu");
  final lines = contents.split("\n");
  final res = <SongLine>[];
  for (final line in lines) {
    if (line.length > 0) {
      final cols = splitInto2(line, ";");
      res.add(SongLine(cols[0], cols.length > 1 ? cols[1] : ""));
    }
  }
  return res;
}

Future<AssetImage?> loadSongImage(String bookName, String code) async {
  final assetName = "assets/$bookName/$code.webp";
  try {
    await rootBundle.load(assetName);
  } catch (e) {
    print("No such asset $assetName");
    return null;
  }

  return AssetImage(assetName);
}
