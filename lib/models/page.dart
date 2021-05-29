class Page {
  final String id;
  final String name;
  final String subdomain;

  Page({this.id, this.name, this.subdomain});

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      name: json['name'],
      subdomain: json['subdomain'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subdomain': subdomain,
      };
}
