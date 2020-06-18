import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grii_resmi/cabang_parser.dart';
import 'package:grii_resmi/grii_data.dart';
import 'package:package_info/package_info.dart';

import 'flavors.dart';

class InfoHome extends StatefulWidget {
  @override
  _InfoHomeState createState() => _InfoHomeState();
}

class _InfoHomeState extends State<InfoHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informasi GRII"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.sync_problem),
            title: Text('Pengakuan Iman Reformed Injili'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PengakuanPage(title: 'Pengakuan Iman Reformed Injili', bodyList: pengakuanIman),
            )),
          ),
          ListTile(
            leading: Icon(Icons.wifi),
            title: Text('Pengakuan Iman Penginjilan'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PengakuanPage(title: 'Pengakuan Iman Penginjilan', bodyList: pengakuanPenginjilan),
            )),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Cabang-cabang GRII'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CabangPage(),
            )),
          ),
          SizedBox(
            height: 48.0,
          ),
          AboutTile(),
        ],
      ),
    );
  }
}

class PengakuanPage extends StatefulWidget {
  final String title;
  final List<Widget> bodyList;

  const PengakuanPage({Key key, this.title, this.bodyList}) : super(key: key);

  @override
  _PengakuanPageState createState() => _PengakuanPageState();
}

class _PengakuanPageState extends State<PengakuanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.0),
        separatorBuilder: (context, index) => SizedBox(height: 8.0),
        itemCount: widget.bodyList.length,
        itemBuilder: (context, index) => widget.bodyList[index],
      ),
    );
  }
}

class AboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Aplikasi GRII',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Yuku'),
        SizedBox(height: 32.0),
        RaisedButton(
          onPressed: () async {
            var version = '';
            if (!kIsWeb) {
              final pi = await PackageInfo.fromPlatform();
              version = "${pi.version} (${pi.buildNumber})";
            }
            version += ' $FLAVOR';

            showAboutDialog(
              context: context,
              applicationIcon: Image(image: AssetImage('assets/drawable/ic_launcher.png')),
              applicationVersion: version,
            );
          },
          child: Text('Info versi'),
        )
      ],
    );
  }
}

class CabangPage extends StatefulWidget {
  @override
  _CabangPageState createState() => _CabangPageState();
}

class _CabangPageState extends State<CabangPage> {
  final _controller = StreamController<CabangParseResult>();

  Future<CabangParseResult> loadCabang() async {
    final contents = await rootBundle.loadString("assets/cabang/semua.txt");
    final lines = contents.split("\n");
    return parseCabang(lines);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    final pr = await loadCabang();
    _controller.add(pr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cabang-cabang GRII"),
      ),
      body: StreamBuilder<CabangParseResult>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final pr = snapshot.data;

          String display(String key) {
            return key.replaceFirst('->World->Indonesia->', '').replaceFirst('->World->', '');
          }

          final keys = pr.keyToBody.keys.toList();
          keys.sort((a, b) => display(a).compareTo(display(b)));

          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];

              return CabangTile(
                displayKey: display(key),
                body: pr.keyToBody[key],
              );
            },
          );
        },
      ),
    );
  }
}

class CabangTile extends StatefulWidget {
  final String displayKey;
  final String body;

  const CabangTile({Key key, this.displayKey, this.body}) : super(key: key);

  @override
  _CabangTileState createState() => _CabangTileState();
}

class _CabangTileState extends State<CabangTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.displayKey),
      subtitle: expanded ? Text(widget.body) : null,
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
    );
  }
}
