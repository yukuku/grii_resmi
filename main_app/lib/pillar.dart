import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:grii_resmi/pillar_api.dart';

import 'main.dart';
import 'pillar_models.dart';

class PillarHome extends StatefulWidget {
  @override
  _PillarHomeState createState() => _PillarHomeState();
}

class _PillarHomeState extends State<PillarHome> {
  late Future<Response<LastIssueResponse>> _lastIssueFuture;
  late Future<Response<IssuesResponse>> _issuesFuture;

  @override
  void initState() {
    super.initState();
    _lastIssueFuture = pillarApiService.getLastIssue();
    _issuesFuture = pillarApiService.listAllIssues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buletin PILLAR')),
      body: FutureBuilder<Response<LastIssueResponse>>(
        future: _lastIssueFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            recordGenericError(snapshot.error, stack: snapshot.stackTrace);
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          final lastIssueResponse = snapshot.requireData.body!;
          return FutureBuilder<Response<IssuesResponse>>(
            future: _issuesFuture,
            builder: (context, snapshot) {
              return FutureBuilder<Response<IssuesResponse>>(
                future: _issuesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    recordGenericError(snapshot.error, stack: snapshot.stackTrace);
                    return Center(child: Text('${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  }

                  final issuesResponse = snapshot.requireData.body!;
                  return FutureBuilder<Response<IssuesResponse>>(
                    future: _issuesFuture,
                    builder: (context, snapshot) {
                      return _buildFilled(lastIssueResponse, issuesResponse);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilled(LastIssueResponse lastIssueResponse, IssuesResponse issuesResponse) {
    final lastIssueSliver = SliverList(
      delegate: SliverChildListDelegate([
        Text('${lastIssueResponse.issue.issueNumber}'),
      ]),
    );

    final issues = issuesResponse.issues.items;
    final issuesSliver = SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 0.6,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              Image.network(issues[index].thumbnailUrl),
              Text('${issues[index].monthDisplay}'),
            ],
          );
        },
        childCount: issues.length,
      ),
    );

    return CustomScrollView(
      slivers: [lastIssueSliver, issuesSliver],
    );
  }
}

class _IssueListSliver extends StatelessWidget {
  const _IssueListSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 4.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            color: Colors.teal[100 * (index % 9)],
            child: Text('grid item $index'),
          );
        },
        childCount: 20,
      ),
    );
  }
}

class _ArticleListWidget extends StatelessWidget {
  const _ArticleListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response<ArticleBriefsResponse>>(
      future: pillarApiService.listArticles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final items = snapshot.requireData.body?.articles.items ?? <ArticleBrief>[];

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
            print(snapshot.error);
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
