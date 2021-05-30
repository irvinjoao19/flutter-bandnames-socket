import 'dart:convert';

List<Band> bandFromJson(String str) =>
    List<Band>.from(json.decode(str).map((x) => Band.fromJson(x)));

String bandToJson(List<dynamic> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Band> bandToList(List<dynamic> data) =>
    data.map((e) => Band.fromJson(e)).toList();

class Band {
  String id;
  String name;
  int votes;

  Band({this.id = "", this.name = "", this.votes = 0});

  factory Band.fromJson(Map<String, dynamic> obj) => Band(
        id: obj['id'],
        name: obj['name'],
        votes: obj['votes'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "votes": votes,
      };
}
