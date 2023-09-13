class Employee {
  int? id;
  String name;
  String position;

  Employee({this.id, required this.name, required this.position});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> data) {
    return Employee(
      id: data['id'],
      name: data['name'],
      position: data['position'],
    );
  }
}
