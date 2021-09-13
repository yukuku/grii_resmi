import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grii_resmi/kita_models.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'salamis_api.dart';
import 'main.dart';

class KitaEdisiListScreen extends StatefulWidget {
  @override
  _KitaEdisiListScreenState createState() => _KitaEdisiListScreenState();
}

class _KitaEdisiListScreenState extends State<KitaEdisiListScreen> {
  late Future<Response<ListEdisiResponse>> _edisisFuture = salamisApiService.listEdisis();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Response<ListEdisiResponse>>(
        future: _edisisFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            recordGenericError(snapshot.error, stack: snapshot.stackTrace);
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          final edisis = snapshot.requireData.body!.edisis.items;
          return _buildFilled(edisis);
        },
      ),
    );
  }

  Widget _buildFilled(List<EdisiBrief> edisis) {
    final headerSliver = SliverList(
      delegate: SliverChildListDelegate([
        Image.asset('assets/kita/header_banner.webp'),
      ]),
    );

    final edisisSliver = SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final edisi = edisis[index];
          return InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KitaEdisiScreen(edisi_page_url: edisi.edisi_page_url),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  color: Color(0xffc9a496),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/kita/edisi_placeholder.webp',
                    image: edisi.edisi_thumbnail,
                  ),
                ),
                SizedBox(height: 8),
                Text('${edisi.edisi_title}', textAlign: TextAlign.center),
              ],
            ),
          );
        },
        childCount: edisis.length,
      ),
    );

    return CustomScrollView(
      slivers: [
        headerSliver,
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: edisisSliver,
        ),
      ],
    );
  }
}

class KitaEdisiScreen extends StatelessWidget {
  final String edisi_page_url;
  late Future<Response<EdisiResponse>> _edisiFuture = salamisApiService.getEdisi(edisi_page_url);

  KitaEdisiScreen({
    Key? key,
    required this.edisi_page_url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Response<EdisiResponse>>(
        future: _edisiFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            recordGenericError(snapshot.error, stack: snapshot.stackTrace);
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          final edisi = snapshot.requireData.body!.edisi;
          return _buildFilled(context, edisi);
        },
      ),
    );
  }

  Widget _buildFilled(BuildContext context, EdisiFull edisi) {
    final accentColor = Theme.of(context).accentColor;

    return SafeArea(
      child: ListView(
        children: [
          Text(
            edisi.edisi_title,
            style: TextStyle(fontSize: 22, letterSpacing: 1.5),
          ),
          SizedBox(height: 8),
          Image.network(edisi.edisi_image),
          SizedBox(height: 8),
          for (final download in edisi.downloads)
            ElevatedButton(
              child: Text(download.title, style: TextStyle(color: accentColor, fontSize: 24)),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KitaPdfViewScreen(
                    pdfUrl: download.url,
                  ),
                ));
              },
            ),
        ],
      ),
    );
  }
}

class KitaPdfViewScreen extends StatelessWidget {
  final String pdfUrl;

  KitaPdfViewScreen({
    Key? key,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SfPdfViewer.network(pdfUrl),
      ),
    );
  }
}
