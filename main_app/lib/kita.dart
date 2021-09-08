import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grii_resmi/kita_models.dart';

import 'kita_api.dart';
import 'main.dart';

class KitaHome extends StatefulWidget {
  @override
  _KitaHomeState createState() => _KitaHomeState();
}

class _KitaHomeState extends State<KitaHome> {
  late Future<Response<ListEdisiResponse>> _edisisFuture = kitaApiService.listEdisis();

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
          return Column(
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
