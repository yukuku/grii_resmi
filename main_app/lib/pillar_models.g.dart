// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleBriefsResponse _$ArticleBriefsResponseFromJson(
    Map<String, dynamic> json) {
  return ArticleBriefsResponse()
    ..articles =
        ArticleBriefList.fromJson(json['articles'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ArticleBriefsResponseToJson(
        ArticleBriefsResponse instance) =>
    <String, dynamic>{
      'articles': instance.articles,
    };

ArticleBriefList _$ArticleBriefListFromJson(Map<String, dynamic> json) {
  return ArticleBriefList()
    ..total = json['total'] as int
    ..items = (json['items'] as List<dynamic>)
        .map((e) => ArticleBrief.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ArticleBriefListToJson(ArticleBriefList instance) =>
    <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
    };

ArticleBrief _$ArticleBriefFromJson(Map<String, dynamic> json) {
  return ArticleBrief()
    ..id = json['_id'] as int
    ..name = json['name'] as String
    ..title = json['title'] as String
    ..snippet = json['snippet'] as String;
}

Map<String, dynamic> _$ArticleBriefToJson(ArticleBrief instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'snippet': instance.snippet,
    };

ArticleFull _$ArticleFullFromJson(Map<String, dynamic> json) {
  return ArticleFull()
    ..name = json['name'] as String
    ..title = json['title'] as String
    ..body = json['body'] as String;
}

Map<String, dynamic> _$ArticleFullToJson(ArticleFull instance) =>
    <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'body': instance.body,
    };

IssuesResponse _$IssuesResponseFromJson(Map<String, dynamic> json) {
  return IssuesResponse()
    ..issues = IssueList.fromJson(json['issues'] as Map<String, dynamic>);
}

Map<String, dynamic> _$IssuesResponseToJson(IssuesResponse instance) =>
    <String, dynamic>{
      'issues': instance.issues,
    };

LastIssueResponse _$LastIssueResponseFromJson(Map<String, dynamic> json) {
  return LastIssueResponse()
    ..issue = Issue.fromJson(json['issue'] as Map<String, dynamic>)
    ..articles =
        ArticleBriefList.fromJson(json['articles'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LastIssueResponseToJson(LastIssueResponse instance) =>
    <String, dynamic>{
      'issue': instance.issue,
      'articles': instance.articles,
    };

IssueList _$IssueListFromJson(Map<String, dynamic> json) {
  return IssueList()
    ..total = json['total'] as int
    ..items = (json['items'] as List<dynamic>)
        .map((e) => Issue.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$IssueListToJson(IssueList instance) => <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
    };

Issue _$IssueFromJson(Map<String, dynamic> json) {
  return Issue()
    ..issueNumber = json['issueNumber'] as String
    ..yyyymm = json['yyyymm'] as String
    ..monthDisplay = json['monthDisplay'] as String
    ..thumbnailUrl = json['thumbnailUrl'] as String;
}

Map<String, dynamic> _$IssueToJson(Issue instance) => <String, dynamic>{
      'issueNumber': instance.issueNumber,
      'yyyymm': instance.yyyymm,
      'monthDisplay': instance.monthDisplay,
      'thumbnailUrl': instance.thumbnailUrl,
    };
