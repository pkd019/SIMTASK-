class UserModel {
  late String id;
  late String name;
  late String image;
  late String last_seen;
  late String email;
  late String push_id;
  late bool is_online;
  late String about;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.is_online,
    required this.last_seen,
    required this.email,
    required this.push_id,
    required this.about,
  });
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? ' ';
    name =json['name'] ?? '';
    image = json['image'] ?? '';
    is_online =json['is_online'] ?? '';
    last_seen = json['last_seen '] ?? '';
    email =json['email'] ?? '';
    push_id =json['push_id'] ?? '';
    about =json['about'] ?? '';
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'is_online': is_online,
      'last_seen ': last_seen,
      'email': email,
      'push_id': push_id,
      'about': about,
    };
  }
}
