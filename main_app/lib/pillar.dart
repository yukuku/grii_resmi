import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
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
          final items = snapshot.data!;

          String truncate(String s) {
            if (s.length > 150) {
              return s.substring(0, 150) + '...';
            } else {
              return s;
            }
          }

          return ListView.builder(
            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                title: Text(item.title),
                subtitle: HtmlWidget(truncate(item.snippet)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return PillarArticlePage(item);
                  }));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PillarArticlePage extends StatefulWidget {
  final ArticleBrief articleBrief;

  PillarArticlePage(this.articleBrief, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PillarArticlePageState();
  }
}

class _PillarArticlePageState extends State<PillarArticlePage> {
  final _controller = StreamController<ArticleFull>(); // ignore: close_sinks

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    getArticle(widget.articleBrief.id, _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
      appBar: AppBar(
        title: Text(widget.articleBrief.title),
      ),
      body: StreamBuilder<ArticleFull>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final item = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: HtmlWidget(
              item.body,
              textStyle: TextStyle(fontSize: 16.0),
            ),
          );
        },
      ),
    );
  }
}
