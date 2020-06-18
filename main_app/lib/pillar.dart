import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grii_resmi/pillar_api.dart';

class PillarHome extends StatefulWidget {
  @override
  _PillarHomeState createState() => _PillarHomeState();
}

class _PillarHomeState extends State<PillarHome> {
  final _controller = StreamController<List<ArticleBrief>>(); // ignore: close_sinks

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    getLatestArticles(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buletin PILLAR')),
      body: StreamBuilder<List<ArticleBrief>>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.snippet),
                dense: true,
              );
            },
          );
        },
      ),
    );
  }
}
