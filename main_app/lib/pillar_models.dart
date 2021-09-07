import 'package:json_annotation/json_annotation.dart';

part 'pillar_models.g.dart';

@JsonSerializable()
class ArticleBriefsResponse {
  late ArticleBriefList articles;

  ArticleBriefsResponse();

  factory ArticleBriefsResponse.fromJson(Map<String, dynamic> json) => _$ArticleBriefsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefsResponseToJson(this);
}

@JsonSerializable()
class ArticleBriefList extends _PillarList<ArticleBrief> {
  ArticleBriefList();

  factory ArticleBriefList.fromJson(Map<String, dynamic> json) => _$ArticleBriefListFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefListToJson(this);
}

@JsonSerializable()
class ArticleBrief {
  @JsonKey(name: '_id')
  late int id;
  late String name;
  late String title;
  late String snippet;

  ArticleBrief();

  factory ArticleBrief.fromJson(Map<String, dynamic> json) => _$ArticleBriefFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefToJson(this);
}

@JsonSerializable()
class ArticleFull {
  late String name;
  late String title;
  late String body;

  ArticleFull();

  factory ArticleFull.fromJson(Map<String, dynamic> json) => _$ArticleFullFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleFullToJson(this);
}

@JsonSerializable()
class IssuesResponse {
  late IssueList issues;

  IssuesResponse();

  factory IssuesResponse.fromJson(Map<String, dynamic> json) => _$IssuesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IssuesResponseToJson(this);
}

@JsonSerializable()
class LastIssueResponse {
  late Issue issue;
  late ArticleBriefList articles;

  LastIssueResponse();

  factory LastIssueResponse.fromJson(Map<String, dynamic> json) => _$LastIssueResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LastIssueResponseToJson(this);
}

@JsonSerializable()
class IssueList extends _PillarList<Issue> {
  IssueList();

  factory IssueList.fromJson(Map<String, dynamic> json) => _$IssueListFromJson(json);

  Map<String, dynamic> toJson() => _$IssueListToJson(this);
}

@JsonSerializable()
class Issue {
  late String issueNumber;
  late String yyyymm;
  late String monthDisplay;
  late String thumbnailUrl;

  Issue();

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

  Map<String, dynamic> toJson() => _$IssueToJson(this);
}

abstract class _PillarList<E> {
  late int total;
  late List<E> items;

  _PillarList();
}
