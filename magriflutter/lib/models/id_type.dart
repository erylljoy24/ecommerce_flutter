final String columnId = 'id';
final String columnName = 'name';

class IdType {
  int? id;
  String? name;

  IdType(this.id, this.name);

  IdType.map(dynamic obj) {
    this.id = obj[columnId];
    this.name = obj[columnName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  IdType.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
  }
}
