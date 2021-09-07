// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleBriefsResponse _$ArticleBriefsResponseFromJson(
    Map<String, dynamic> json) {
  return ArticleBriefsResponse(
    ArticleBriefList.fromJson(json['articles'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ArticleBriefsResponseToJson(
        ArticleBriefsResponse instance) =>
    <String, dynamic>{
      'articles': instance.articles,
    };

ArticleBriefList _$ArticleBriefListFromJson(Map<String, dynamic> json) {
  return ArticleBriefList(
    json['total'] as int,
    (json['items'] as List<dynamic>)
        .map((e) => ArticleBrief.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ArticleBriefListToJson(ArticleBriefList instance) =>
    <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
    };

ArticleBrief _$ArticleBriefFromJson(Map<String, dynamic> json) {
  return ArticleBrief(
    id: json['id'] as int,
    name: json['name'] as String,
    title: json['title'] as String,
    snippet: json['snippet'] as String,
  );
}

Map<String, dynamic> _$ArticleBriefToJson(ArticleBrief instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'snippet': instance.snippet,
    };

ArticleFull _$ArticleFullFromJson(Map<String, dynamic> json) {
  return ArticleFull(
    name: json['name'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
  );
}

Map<String, dynamic> _$ArticleFullToJson(ArticleFull instance) =>
    <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'body': instance.body,
    };
