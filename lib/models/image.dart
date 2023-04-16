class ImageClass {
  late String? url;
  late String? storagePath;

  ImageClass({this.url, this.storagePath});

  static ImageClass fromMap(Map map) {
    return ImageClass(url: map["url"], storagePath: map["storagePath"]);
  }
}
