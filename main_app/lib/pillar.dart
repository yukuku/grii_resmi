import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'imageproxy.dart';
import 'main.dart';
import 'pillar_api.dart';
import 'pillar_models.dart';

class PillarHome extends StatefulWidget {
  @override
  _PillarHomeState createState() => _PillarHomeState();
}

class _PillarHomeState extends State<PillarHome> {
  late Future<Response<LastIssueResponse>> _lastIssueFuture = pillarApiService.getLastIssue();
  late Future<Response<IssuesResponse>> _issuesFuture = pillarApiService.listAllIssues();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Response<LastIssueResponse>>(
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
      ),
    );
  }

  Widget _buildFilled(LastIssueResponse lastIssueResponse, IssuesResponse issuesResponse) {
    final lastIssueSliver = SliverList(
      delegate: SliverChildListDelegate([
        PillarCoverWidget(
          issue: lastIssueResponse.issue,
        ),
        for (ArticleBrief article in lastIssueResponse.articles.items.where((a) => !a.category.monthly))
          PillarArticleCard(article: article),
      ]),
    );

    final oldIssuesHeadingSliver = SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Edisi Lampau'.toUpperCase(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );

    final issues = issuesResponse.issues.items;
    final oldIssuesSliver = SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 0.6,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final issue = issues[index];
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/pillar/issue_placeholder.jpg',
                  image: issue.thumbnailUrl.imageProxy(),
                ),
              ),
              SizedBox(height: 8),
              Text('Edisi ${issue.issueNumber} | ${issue.monthDisplay}'),
            ],
          );
        },
        childCount: issues.length,
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: lastIssueSliver,
        ),
        oldIssuesHeadingSliver,
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: oldIssuesSliver,
        ),
      ],
    );
  }
}

class PillarCoverWidget extends StatelessWidget {
  final Issue issue;

  const PillarCoverWidget({
    Key? key,
    required this.issue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dividerColor = Color(0xfffaf1d5);
    final accentColor = Theme.of(context).accentColor;

    return Column(
      children: [
        Divider(thickness: 2, color: dividerColor),
        IntrinsicHeight(
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                issue.issueNumber,
                style: TextStyle(color: dividerColor, fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            VerticalDivider(thickness: 4, color: dividerColor),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.monthDisplay.toUpperCase(),
                    style: TextStyle(color: dividerColor, fontSize: 22, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text('unduh pdf', style: TextStyle(color: accentColor, fontSize: 16)),
                ],
              ),
            ),
          ]),
        ),
        Divider(thickness: 2, color: dividerColor),
      ],
    );
  }
}

class PillarArticleCard extends StatelessWidget {
  final ArticleBrief article;

  const PillarArticleCard({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dividerColor = Color(0xfffaf1d5);
    final accentColor = Theme.of(context).accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.category.title.toUpperCase(),
          style: TextStyle(letterSpacing: 1.5),
        ),
        Divider(thickness: 2, color: dividerColor),
        Text(
          article.title,
          style: TextStyle(
            color: dividerColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            height: 1.25,
          ),
        ),
        SizedBox(height: 8),
        HtmlWidget(
          article.snippet,
          textStyle: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text('selengkapnya', style: TextStyle(color: accentColor, fontSize: 16)),
        SizedBox(height: 8),
        Divider(thickness: 2, color: dividerColor),
      ],
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
