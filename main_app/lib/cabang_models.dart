import 'package:json_annotation/json_annotation.dart';

part 'cabang_models.g.dart';

@JsonSerializable()
class ListCabangResponse {
  late CabangList cabangs;

  ListCabangResponse();

  factory ListCabangResponse.fromJson(Map<String, dynamic> json) => _$ListCabangResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListCabangResponseToJson(this);
}

@JsonSerializable()
class CabangList extends _CabangList<Cabang> {
  CabangList();

  factory CabangList.fromJson(Map<String, dynamic> json) => _$CabangListFromJson(json);

  Map<String, dynamic> toJson() => _$CabangListToJson(this);
}

@JsonSerializable()
class Cabang {
  late String path;
  late String title;
  late String href;

  Cabang();

  factory Cabang.fromJson(Map<String, dynamic> json) => _$CabangFromJson(json);

  Map<String, dynamic> toJson() => _$CabangToJson(this);
}

abstract class _CabangList<E> {
  late int total;
  late List<E> items;

  _CabangList();
}
