import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saudi_chat/pages/chat/view_video.dart';

class DetailScreen extends StatefulWidget {
  final String? imageUrl;
  final Object? tag;
  final String? storagePath;
  final bool isVideo;
  final Duration? videoPosition;

  // ignore: prefer_const_constructors_in_immutables
  const DetailScreen({
    Key? key,
    required this.isVideo,
    this.videoPosition,
    this.storagePath,
    required this.imageUrl,
    required this.tag,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isVideo) {
      return Scaffold(
        body: Stack(children: <Widget>[
          Center(
            child: PhotoView(
              filterQuality: FilterQuality.high,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.tag!),
              maxScale: PhotoViewComputedScale.contained * 2,
              minScale: PhotoViewComputedScale.contained,
              imageProvider: CachedNetworkImageProvider(widget.imageUrl!),
            ),
          ),
          const _PhotoViewControlBars(),
        ]),
      );
    } else {
      return Material(
          color: Colors.black,
          child: GestureDetector(
            child: Center(
              child: ViewVideo(
                  url: widget.imageUrl!,
                  storagePath: widget.storagePath!,
                  videoPosition: widget.videoPosition),
            ),
          ));
    }
  }
}

class _PhotoViewControlBars extends StatelessWidget {
  const _PhotoViewControlBars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50 + MediaQuery.of(context).padding.top,
        child: AppBar(
          actions: [
            IconButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                onPressed: () {},
                icon: const Icon(
                  Icons.download_sharp,
                  size: 24,
                )),
            IconButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                onPressed: () {},
                icon: const Icon(
                  Icons.share_rounded,
                  size: 21,
                )),
          ],
          backgroundColor: Colors.black.withOpacity(0.6),
        ));
  }
}
