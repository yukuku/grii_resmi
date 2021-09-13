import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grii_resmi/grii_data.dart';
import 'package:grii_resmi/salamis_api.dart';
import 'package:package_info/package_info.dart';

import 'cabang_models.dart';
import 'flavors.dart';
import 'main.dart';

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
              builder: (context) => CabangScreen(),
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

class CabangScreen extends StatefulWidget {
  @override
  _CabangScreenState createState() => _CabangScreenState();
}

class _CabangScreenState extends State<CabangScreen> {
  late Future<Response<ListCabangResponse>> _cabangsFuture = salamisApiService.listCabangs();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<Response<ListCabangResponse>>(
          future: _cabangsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              recordGenericError(snapshot.error, stack: snapshot.stackTrace);
              return Center(child: Text('${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            final cabangs = snapshot.requireData.body!.cabangs.items;
            return CabangTree(cabangs, Theme.of(context).colorScheme);
          },
        ),
      ),
    );
  }
}

class CabangTree extends StatefulWidget {
  final ColorScheme colorScheme;
  late List<Node<Cabang>> rootNodes;

  CabangTree(List<Cabang> cabangs, this.colorScheme, {Key? key}) : super(key: key) {
    // preprocess
    final byPath = <String, Cabang>{};
    final childrenMap = <String, List<Cabang>>{};
    for (final cabang in cabangs) {
      byPath[cabang.path] = cabang;
      final bef = cabang.path.lastIndexOf('/');
      final parentPath = cabang.path.substring(0, bef);
      childrenMap.putIfAbsent(parentPath, () => <Cabang>[]);
      childrenMap[parentPath]?.add(cabang);
    }

    List<Node<Cabang>> listNodes(String parentPath) {
      final res = <Node<Cabang>>[];
      final children = childrenMap[parentPath];
      if (children != null) {
        for (final child in children) {
          final unders = listNodes(child.path);
          res.add(Node<Cabang>(
            key: child.path,
            label: child.title,
            icon: unders.isEmpty ? FontAwesomeIcons.church : null,
            iconColor: colorScheme.onSurface,
            children: unders,
          ));
        }
      }
      return res;
    }

    rootNodes = listNodes('');
  }

  @override
  _CabangTreeState createState() => _CabangTreeState();
}

class _CabangTreeState extends State<CabangTree> {
  late TreeViewController _controller = TreeViewController(children: widget.rootNodes);

  @override
  Widget build(BuildContext context) {
    return TreeView(
      controller: _controller,
      theme: TreeViewTheme(
        colorScheme: widget.colorScheme,
        expanderTheme: ExpanderThemeData(color: widget.colorScheme.onSurface, type: ExpanderType.chevron),
        iconTheme: IconThemeData(size: 16),
        parentLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        labelStyle: TextStyle(fontSize: 16),
        iconPadding: 16,
      ),
    );
  }
}
