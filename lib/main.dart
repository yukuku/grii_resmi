import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_audio_player/simple_audio_player.dart';

final SentryClient sentry = SentryClient(dsn: 'https://4d1de035fe314db8b219e2f701a2181c:ec106d4c1ff34a229b2329ff249ec4df@sentry.io/223245');

class SongBook {
  final String name;
  final String title;
  final String year;

  const SongBook({this.name, this.title, this.year});
}

const defaultSongBook = SongBook(name: 'KRI', title: 'Kidung Reformed Injili', year: '2017');

const songBooks = [
  defaultSongBook,
  SongBook(name: 'KPRI', title: 'Kidung Persekutuan Reformed Injili', year: '2004'),
  SongBook(name: 'JB', title: 'Jiwaku Bersukacita', year: '2014'),
];

const kPrefkeySongTextSizeZoom = 'songTextSizeZoom';
const defaultTextSize = 16.0;
const maxTextSizeZoom = 2.0;
const minTextSizeZoom = 0.675;

Future<Directory> getSongFilesDir() async => getTemporaryDirectory();

main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    final resp = await sentry.captureException(exception: details.exception, stackTrace: details.stack);
    print("sending crash from FlutterError: ${resp.isSuccessful}");
  };

  try {
    runApp(MyApp());
  } catch (error, stackTrace) {
    final resp = await sentry.captureException(exception: error, stackTrace: stackTrace);
    print("sending crash from try-catch: ${resp.isSuccessful}");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRII',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  MainWidget({Key key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    _CalendarHome(),
    _SongHome(),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Aplikasi GRII',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Yuku',
        ),
      ],
    ),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Jadwal'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text('Lagu'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text('Tentang'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _SongHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongHomeState();
}

class _SongHomeState extends State<_SongHome> {
  SearchBar searchBar;
  String bookName = defaultSongBook.name;
  String filterText;

  _SongHomeState() {
    searchBar = SearchBar(
      setState: setState,
      buildDefaultAppBar: buildAppBar,
      onSubmitted: onSubmitted,
      closeOnSubmit: true,
    );
  }

  void onSubmitted(String value) {
    setState(() {
      if (value == null || value.isEmpty) {
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
                  child: Text(filterText, style: TextStyle(fontWeight: FontWeight.normal), overflow: TextOverflow.ellipsis),
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
              PopupMenuItem(value: 'about', child: Text("About")),
              PopupMenuItem(value: 'clear_all_song_files', child: Text("Clear all song files")),
            ];
          },
          onSelected: (selected) async {
            if (selected == 'about') {
              final pi = await PackageInfo.fromPlatform();
              showAboutDialog(
                context: context,
                applicationIcon: Image(image: AssetImage('assets/drawable/ic_launcher.png')),
                applicationVersion: "${pi.version} (${pi.buildNumber})",
              );
            } else if (selected == 'clear_all_song_files') {
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
      body: ListPage(bookName, filterText, key: Key("$bookName $filterText")),
    );
  }
}

class ListPage extends StatefulWidget {
  final String bookName;
  final String filterText;

  ListPage(this.bookName, this.filterText, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  final List<SongHeader> headers = List<SongHeader>();

  _ListPageState();

  @override
  void initState() {
    super.initState();

    loadSongHeaders(widget.bookName).then((headers) {
      final tokens = widget.filterText == null ? <String>[] : widget.filterText.toLowerCase().split(RegExp(r'\s+')).map((token) => token.toLowerCase());

      final filtered = headers.where((header) => tokens.every((token) => header.code.contains(token) || (header.title != null && header.title.toLowerCase().contains(token)) || (header.titleOriginal != null && header.titleOriginal.toLowerCase().contains(token))));

      setState(() {
        this.headers.addAll(filtered);
      });
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
        if (headers[index].titleOriginal.isNotEmpty) ...[
          SizedBox(width: 44.0),
          Text(headers[index].titleOriginal),
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
  final String titleOriginal;

  SongHeader(this.code, this.title, this.titleOriginal);
}

Future<List<SongHeader>> loadSongHeaders(String bookName) async {
  final contents = await rootBundle.loadString("assets/$bookName/_list.txt");
  final lines = contents.split("\n");
  final res = List<SongHeader>();
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

  SongPage(this.bookName, this.code, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SongPageState();
  }
}

class _SongPageState extends State<SongPage> {
  get url => "http://files.bibleforandroid.com/addon/audio/songs/v2/${widget.bookName}_${widget.code}.mp3";
  bool wantAutoStart;
  bool downloadIsRunning = false;
  int downloadProgress;
  int downloadTotal;

  @override
  void initState() {
    super.initState();

    wantAutoStart = false;

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

      print("SAP: ${status.toString()} ${SimpleAudioPlayer.positionNotifier.value}/${SimpleAudioPlayer.durationNotifier.value} ${SimpleAudioPlayer.completeNotifier.value} ${SimpleAudioPlayer.errorNotifier.value}");

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
      downloadTotal = resp.contentLength;
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
                content: Text("Error! Couldn't get song file for ${widget.bookName} ${widget.code}.\n\n${SimpleAudioPlayer.errorNotifier.value}"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Oke'),
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
          child: downloadIsRunning ? LinearProgressIndicator(value: downloadTotal == null || downloadTotal == 0 ? null : downloadProgress / downloadTotal) : Container(),
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
  AssetImage image;
  SharedPreferences sp;
  double zoom = 1.0;
  double startZoom;

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
    zoom = sp.getDouble(kPrefkeySongTextSizeZoom) ?? 1.0;

    setState(() {
      this.lines.addAll(lines);
      this.image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final originalTheme = Theme.of(context).textTheme;
    final textTheme = originalTheme.copyWith(
      headline: originalTheme.headline.copyWith(fontSize: 24.0 * zoom, backgroundColor: Colors.grey, color: Colors.white),
      title: originalTheme.title.copyWith(fontSize: 24.0 * zoom),
      subhead: originalTheme.subhead.copyWith(fontSize: 16.0 * zoom),
      caption: originalTheme.caption.copyWith(fontSize: 14.0 * zoom, color: Colors.black),
      body1: originalTheme.body1.copyWith(fontSize: 18.0 * zoom),
      body2: originalTheme.body2.copyWith(fontSize: 16.0 * zoom),
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
        if (zoom != null) {
          startZoom = zoom;
        }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        if (startZoom == null) return;
        var newTextSizeZoom = details.scale * startZoom;
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
        style = textTheme.title;
        break;

      case 'h2':
        style = textTheme.subhead;
        break;

      case 'h3':
        style = textTheme.body2;
        break;

      case 'h4':
        style = textTheme.caption;
        break;

      case 'p':
        style = textTheme.body1;
        break;

      case 'pi':
        style = textTheme.body1.copyWith(fontStyle: FontStyle.italic);
        break;

      case 'caption':
        style = textTheme.subhead.copyWith(fontWeight: FontWeight.bold);
        break;

      case 'no':
        style = textTheme.headline;
        break;
    }

    toRichText(String s, TextStyle style) {
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
        child: Image(image: image),
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
  final res = List<SongLine>();
  for (final line in lines) {
    if (line.length > 0) {
      final cols = splitInto2(line, ";");
      res.add(SongLine(cols[0], cols.length > 1 ? cols[1] : ""));
    }
  }
  return res;
}

Future<AssetImage> loadSongImage(String bookName, String code) async {
  final assetName = "assets/$bookName/$code.webp";
  try {
    await rootBundle.load(assetName);
  } catch (e) {
    print("No such asset $assetName");
    return null;
  }

  return AssetImage(assetName);
}

class _CalendarHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarHomeState();
}

class _CalendarHomeState extends State<_CalendarHome> {
  StreamController _controller = StreamController();

  _CalendarHomeState() {}

  Future fetchCalendar() async {
    final response = await Client().get('https://us-central1-pulau-kreta.cloudfunctions.net/calendar/v0/listDayEvents?local_date=2020-06-06&local_tzhm=%2b08:00');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    fetchCalendar().then((res) async {
      _controller.add(res);
      return res;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal'),
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.error != null) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final List<dynamic> events = snapshot.data;
          final widgets = events.map((e) {
            final startTime = DateTime.fromMillisecondsSinceEpoch(e['startTime'] * 1000.0);

            return Column(children: <Widget>[
              Text(startTime.toString()),
              Text(
                e['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (e['speaker'] != null) Text(e['speaker']),
              if (e['linkText'] != null) Text(e['linkText']),
              if (e['description'] != null)
                Text(
                  e['description'],
                  style: TextStyle(fontSize: 12.0),
                ),
            ]);
          }).toList();
          return ListView(children: widgets);
        },
      ),
    );
  }
}
