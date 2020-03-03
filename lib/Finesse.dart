class Finesse {
  final String title;
  final String description;
  final String image;
  final String location;
  final String duration;
  final String type;
  String _id;

  static finesseAdd( title, description, image, location,
    duration, type){
    return Finesse(null, title, description, image, location,
    duration, type);

  }

  Finesse(this._id, this.title, this.description, this.image, this.location,
      this.duration, this.type);

  factory Finesse.fromJson(Map<String, dynamic> json) {
    return Finesse(
      json['_id'],
      json['name'] != null ? json['name'] : "",
      json['description'] != null ? json['description'] : "",
      "image",
      "22",
      "23",
      json['duration'] != null ? json['duration'] : "",
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = title;
    map["location"] = location;
    map["description"] = description;
    map["duration"] = duration;

    return map;
  }

  String getImage() {
    return image;
  }

  String getTitle() {
    return title;
  }

  String getLocation() {
    return location;
  }

  String getDescription() {
    return description;
  }

  String getDuration() {
    return duration;
  }

  String getType() {
    return type;
  }

  String get_Id(){
    return _id;
  }
}
