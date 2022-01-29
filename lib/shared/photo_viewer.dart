import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saudi_chat/pages/chat/view_video.dart';
import 'package:saudi_chat/services/storage.dart';

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
      print(widget.imageUrl);
      return Scaffold(
        body: Stack(children: <Widget>[
          Center(
            child: PhotoView(
              filterQuality: FilterQuality.medium,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.tag!),
              maxScale: PhotoViewComputedScale.contained * 2,
              minScale: PhotoViewComputedScale.contained,
              imageProvider: CachedNetworkImageProvider(widget.imageUrl!),
            ),
          ),
          _PhotoViewControlBars(
            imageUrl: widget.imageUrl,
            storagePath: widget.storagePath,
          ),
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

class _PhotoViewControlBars extends StatefulWidget {
  // this is the controll bar of the photo viewer
  final dynamic storagePath;
  final dynamic imageUrl;
  const _PhotoViewControlBars(
      {Key? key, required this.imageUrl, required this.storagePath})
      : super(key: key);

  @override
  State<_PhotoViewControlBars> createState() => _PhotoViewControlBarsState();
}

class _PhotoViewControlBarsState extends State<_PhotoViewControlBars> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    print(widget.imageUrl);
    return SizedBox(
        height: 50 + MediaQuery.of(context).padding.top,
        child: AppBar(
          bottom: isLoading
              ? const PreferredSize(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ),
                  preferredSize: Size(double.infinity, 0.5))
              : null,
          actions: [
            IconButton(
                splashRadius: 12,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                onPressed: () => onDownloadTapped(<dynamic, dynamic>{
                      "storage_path": widget.storagePath,
                      "url": widget.imageUrl
                    }),
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

  Future<void> onDownloadTapped(Map imageMessage) async {
    setState(() {
      isLoading = true;
    });

    try {
      // ignore: unused_local_variable
      bool downloaded = await FireStorage.saveImage(imageMessage["url"]);
      if (downloaded) {
        Fluttertoast.showToast(msg: "Image saved");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace); // TODO: Test
      Fluttertoast.showToast(
          msg: "Could not download File, an error has occured");
      setState(() {
        isLoading = false;
      });
    }
  }
}
