import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grii_resmi/cabang_parser.dart';
import 'package:grii_resmi/grii_data.dart';
import 'package:package_info/package_info.dart';

import 'flavors.dart';

class InfoHome extends StatefulWidget {
  @override
  _InfoHomeState createState() => _InfoHomeState();
}

class InfoCard extends StatelessWidget {
  final String assetPath;
  final String heroTag;
  final String text;
  final Function onTap;

  const InfoCard({
    Key? key,
    required this.assetPath,
    required this.heroTag,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
          child: Stack(
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(assetPath),
                ),
              ),
              PositionedDirectional(
                bottom: 0,
                child: Container(
                  color: Color(0x77000000),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          InfoCard(
            assetPath: 'assets/pengakuan/new_rmci_kebaktian_1400x750.webp',
            heroTag: 'pengakuanIman',
            text: 'Pengakuan Iman Reformed Injili',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PengakuanPage(
                assetPath: 'assets/pengakuan/new_rmci_kebaktian_1400x750.webp',
                heroTag: 'pengakuanIman',
                title: 'Pengakuan Iman Reformed Injili',
                bodyList: pengakuanIman,
              ),
            )),
          ),
          InfoCard(
            assetPath: 'assets/pengakuan/new_KPIN_1400x450.webp',
            heroTag: 'pengakuanPenginjilan',
            text: 'Pengakuan Iman Penginjilan',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PengakuanPage(
                assetPath: 'assets/pengakuan/new_KPIN_1400x450.webp',
                heroTag: 'pengakuanPenginjilan',
                title: 'Pengakuan Iman Penginjilan',
                bodyList: pengakuanPenginjilan,
              ),
            )),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Cabang-cabang GRII'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CabangPage(),
            )),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.infoCircle),
            title: Text('Versi aplikasi'),
            onTap: () async {
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
          ),
        ],
      ),
    );
  }
}

class PengakuanPage extends StatefulWidget {
  final String assetPath;
  final String heroTag;
  final String title;
  final List<Widget> bodyList;

  const PengakuanPage({
    Key? key,
    required this.assetPath,
    required this.heroTag,
    required this.title,
    required this.bodyList,
  }) : super(key: key);

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
        separatorBuilder: (context, index) => SizedBox(height: 12.0),
        itemCount: 1 + widget.bodyList.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Hero(tag: widget.heroTag, child: Image.asset(widget.assetPath));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: widget.bodyList[index - 1],
          );
        },
      ),
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
          final pr = snapshot.data!;

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
                body: pr.keyToBody[key]!,
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

  const CabangTile({Key? key, required this.displayKey, required this.body}) : super(key: key);

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
