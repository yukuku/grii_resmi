// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kita_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListEdisiResponse _$ListEdisiResponseFromJson(Map<String, dynamic> json) {
  return ListEdisiResponse()
    ..edisis = EdisiBriefList.fromJson(json['edisis'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ListEdisiResponseToJson(ListEdisiResponse instance) =>
    <String, dynamic>{
      'edisis': instance.edisis,
    };

EdisiBriefList _$EdisiBriefListFromJson(Map<String, dynamic> json) {
  return EdisiBriefList()
    ..total = json['total'] as int
    ..items = (json['items'] as List<dynamic>)
        .map((e) => EdisiBrief.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$EdisiBriefListToJson(EdisiBriefList instance) =>
    <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
    };

EdisiBrief _$EdisiBriefFromJson(Map<String, dynamic> json) {
  return EdisiBrief()
    ..edisi_title = json['edisi_title'] as String
    ..edisi_page_url = json['edisi_page_url'] as String
    ..edisi_thumbnail = json['edisi_thumbnail'] as String;
}

Map<String, dynamic> _$EdisiBriefToJson(EdisiBrief instance) =>
    <String, dynamic>{
      'edisi_title': instance.edisi_title,
      'edisi_page_url': instance.edisi_page_url,
      'edisi_thumbnail': instance.edisi_thumbnail,
    };

EdisiResponse _$EdisiResponseFromJson(Map<String, dynamic> json) {
  return EdisiResponse()
    ..edisi = EdisiFull.fromJson(json['edisi'] as Map<String, dynamic>);
}

Map<String, dynamic> _$EdisiResponseToJson(EdisiResponse instance) =>
    <String, dynamic>{
      'edisi': instance.edisi,
    };

EdisiFull _$EdisiFullFromJson(Map<String, dynamic> json) {
  return EdisiFull()
    ..edisi_title = json['edisi_title'] as String
    ..edisi_image = json['edisi_image'] as String
    ..downloads = (json['downloads'] as List<dynamic>)
        .map((e) => Download.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$EdisiFullToJson(EdisiFull instance) => <String, dynamic>{
      'edisi_title': instance.edisi_title,
      'edisi_image': instance.edisi_image,
      'downloads': instance.downloads,
    };

Download _$DownloadFromJson(Map<String, dynamic> json) {
  return Download()
    ..title = json['title'] as String
    ..url = json['url'] as String;
}

Map<String, dynamic> _$DownloadToJson(Download instance) => <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
    };
