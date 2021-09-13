// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cabang_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListCabangResponse _$ListCabangResponseFromJson(Map<String, dynamic> json) {
  return ListCabangResponse()
    ..cabangs = CabangList.fromJson(json['cabangs'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ListCabangResponseToJson(ListCabangResponse instance) =>
    <String, dynamic>{
      'cabangs': instance.cabangs,
    };

CabangList _$CabangListFromJson(Map<String, dynamic> json) {
  return CabangList()
    ..total = json['total'] as int
    ..items = (json['items'] as List<dynamic>)
        .map((e) => Cabang.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$CabangListToJson(CabangList instance) =>
    <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
    };

Cabang _$CabangFromJson(Map<String, dynamic> json) {
  return Cabang()
    ..path = json['path'] as String
    ..title = json['title'] as String
    ..href = json['href'] as String;
}

Map<String, dynamic> _$CabangToJson(Cabang instance) => <String, dynamic>{
      'path': instance.path,
      'title': instance.title,
      'href': instance.href,
    };
