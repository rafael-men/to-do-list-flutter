class TaskSeries {
  final String id;
  final String name;

  TaskSeries({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };

  factory TaskSeries.fromMap(Map<String, dynamic> map) => TaskSeries(
        id: map['id'],
        name: map['name'],
      );
}
