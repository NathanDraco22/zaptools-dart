

class MetaTag {
  
  MetaTag({
    required this.name,
    this.description = "",
    this.values = const {}
  });
  String name;
  String description;
  Map<String,dynamic> values;

}