class VideoModel {
  final String name;
  final String id;
  final String pic;
  final String link;
  final bool hd;
  final bool sd;
  final String s1;
  final bool pin;

  final bool aws;

  VideoModel({
    required this.name,
    required this.id,
    required this.pic,
    required this.link,
    required this.hd,
    required this.sd,
    required this.s1,
    required this.pin,
    required this.aws,
  });

  // Convert JSON to VideoModel
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      name: json['name'] ?? '',
      aws: json['aws']??true,
      id: json['id'] ?? '',
      pic: json['pic'] ?? '',
      link: json['link'] ?? '',
      hd: json['hd'] ?? false,
      sd: json['sd'] ?? false,
      s1: json['s1'] ?? '',
      pin:json['pin']??false,
    );
  }

  // Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'pic': pic,
      'pin':pin,
      'aws':aws,
      'link': link,
      'hd': hd,
      'sd': sd,
      's1': s1,
    };
  }
}
