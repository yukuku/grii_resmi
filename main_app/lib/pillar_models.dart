import 'package:json_annotation/json_annotation.dart';

part 'pillar_models.g.dart';

@JsonSerializable()
class ArticleBriefsResponse {
  final ArticleBriefList articles;

  ArticleBriefsResponse(this.articles);

  factory ArticleBriefsResponse.fromJson(Map<String, dynamic> json) => _$ArticleBriefsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefsResponseToJson(this);
}

@JsonSerializable()
class ArticleBriefList {
  final int total;
  final List<ArticleBrief> items;

  ArticleBriefList(this.total, this.items);

  factory ArticleBriefList.fromJson(Map<String, dynamic> json) => _$ArticleBriefListFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefListToJson(this);
}

@JsonSerializable()
class ArticleBrief {
  final int id;
  final String name;
  final String title;
  final String snippet;

  ArticleBrief({
    required this.id,
    required this.name,
    required this.title,
    required this.snippet,
  });

  factory ArticleBrief.fromJson(Map<String, dynamic> json) => _$ArticleBriefFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleBriefToJson(this);
}

@JsonSerializable()
class ArticleFull {
  final String name;
  final String title;
  final String body;

  ArticleFull({
    required this.name,
    required this.title,
    required this.body,
  });

  factory ArticleFull.fromJson(Map<String, dynamic> json) => _$ArticleFullFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleFullToJson(this);
}
