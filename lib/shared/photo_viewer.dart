import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:saudi_chat/pages/chat/view_video.dart';
import 'package:saudi_chat/services/storage.dart';

class DetailScreen extends StatefulWidget {
  final String? imageUrl;
  final Object? tag;
  final String? storagePath;
  final bool isVideo;
  final Duration? videoPosition;
  final VideoPlayerController? videoController;

  // ignore: prefer_const_constructors_in_immutables
  const DetailScreen({
    Key? key,
    required this.isVideo,
    this.videoController,
    this.videoPosition,
    this.storagePath,
    required this.imageUrl,
    required this.tag,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ChewieController? chewieController;

  @override
  void dispose() {
    if (widget.videoController != null && chewieController != null) {
      widget.videoController!.dispose();
      chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.videoController != null) {
      chewieController = ChewieController(
          videoPlayerController: widget.videoController!,
          autoPlay: true,
          looping: true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.isVideo
        ? widget.videoController != null &&
            widget.videoPosition != null &&
            widget.storagePath != null
        : true);

    if (!widget.isVideo) {
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
              child: Chewie(controller: chewieController!),
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
    return SizedBox(
        height: 50 + MediaQuery.of(context).padding.top,
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: isLoading
              ? const PreferredSize(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ),
                  preferredSize: Size(double.infinity, 0.5))
              : null,
          actions: [
            IconButton(
                splashRadius: 24,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                onPressed: () => onDownloadTapped(<dynamic, dynamic>{
                      "storage_path": widget.storagePath,
                      "url": widget.imageUrl
                    }),
                icon: const Icon(
                  Icons.download_sharp,
                  color: Colors.white,
                  size: 24,
                )),
            IconButton(
                splashRadius: 24,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                onPressed: () {},
                icon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 21,
                )),
          ],
          backgroundColor: Colors.black.withOpacity(0.6),
          elevation: 0,
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
