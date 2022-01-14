import 'dart:io';

import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/shared/photo_viewer.dart';
import 'package:video_player/video_player.dart';

class ViewVideo extends StatefulWidget {
  final String url;
  final String storagePath;
  final Duration? videoPosition;
  const ViewVideo(
      {Key? key,
      required this.url,
      this.videoPosition,
      required this.storagePath})
      : super(key: key);

  @override
  _ViewVideoState createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  VideoPlayerController? videoPlayerController;
  bool isInitialized = false;

  final key = GlobalKey<_PausePlayVideoState>();

  // this will get the video's bytes from a http request
  // and use those bytes to create a video file in the cache
  // directory of this app, if the file path exists which means
  // that there is a video file then it will return it and
  // initialize the controller then load the video in

  Future initialize() async {
    // get the cache directory
    final Directory filePath = (await getTemporaryDirectory());

    if (!(await File("${filePath.path}/${widget.storagePath}").exists())) {
      // get the video form firebase storage
      final response = await get(Uri.parse(widget.url));

      // create the cache directory in which the video
      // file will be saved in
      final File fileForVideo =
          await File("${filePath.path}/${widget.storagePath}")
              .create(recursive: true);

      // read the video as bytes and create he video
      // in the file at the caches directory
      final File videoMaker =
          await fileForVideo.writeAsBytes(response.bodyBytes);
      // TODO: Buffer the video on play, better space optimization

      // assign the videoPlayerController to a controller which
      // will be made form the file in which we created earlier
      videoPlayerController = VideoPlayerController.file(videoMaker);
      await videoPlayerController!.initialize();

      if (videoPlayerController!.value.isInitialized) {
        if (mounted) {
          setState(() {
            isInitialized = true;
          });
        } else {
          isInitialized = true;
        }
      }
    } else {
      videoPlayerController = VideoPlayerController.file(
          File("${filePath.path}/${widget.storagePath}"));
      await videoPlayerController!.initialize();
      if (videoPlayerController!.value.isInitialized) {
        if (mounted) {
          setState(() {
            isInitialized = true;
          });
        } else {
          isInitialized = true;
        }
      }
    }
    if (widget.videoPosition != null) {
      videoPlayerController!.seekTo(widget.videoPosition!);
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (isInitialized) {
      return Stack(children: [
        GestureDetector(
          child: Center(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                height: videoPlayerController!.value.size.height,
                width: videoPlayerController!.value.size.width,
                child: VideoPlayer(videoPlayerController!),
              ),
            ),
          ),
          onTap: () async {
            final Duration? videoPosition =
                await videoPlayerController!.position;
            if (context.findAncestorWidgetOfExactType<DetailScreen>() == null) {
              videoPlayerController!.pause();
              setState(() {
                key.currentState!.pauseVideo();
              });
              Duration? vidPos = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailScreen(
                          isVideo: true,
                          videoPosition: videoPosition,
                          storagePath: widget.storagePath,
                          tag: widget.url,
                          imageUrl: widget.url)));
              if (vidPos != null) {
                await videoPlayerController!.seekTo(vidPos);
              }

              // TODO: Fix video image not updating after seeking!
              /*void updateVidState() async {
                await videoPlayerController!.setVolume(0.0);
                await videoPlayerController!.play();
                await videoPlayerController!.pause();
                await videoPlayerController!.setVolume(1.0);
              }

              updateVidState();*/
              setState(() {});
            } else {
              Navigator.pop(context, await videoPlayerController!.position);
            }
          },
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              0, videoPlayerController!.value.size.height / 12, 0, 0),
          child: Center(
              child: PausePlayVideo(
                  key: key, videoPlayerController: videoPlayerController!)),
        )
      ]);
    } else {
      return const SizedBox(
          height: 80, width: 80, child: SpinKitCircle(color: Colors.white));
    }
  }
}

class PausePlayVideo extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const PausePlayVideo({Key? key, required this.videoPlayerController})
      : super(key: key);

  @override
  _PausePlayVideoState createState() => _PausePlayVideoState();
}

class _PausePlayVideoState extends State<PausePlayVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool _visible = true;

  Duration startVideoPisition = Duration.zero;
  final double commonContainerMax = 45;

  static const buttonFadeOutDuration = Duration(milliseconds: 300);
  static const buttonFadeInDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    widget.videoPlayerController.addListener(() {
      listener();
    });
    super.initState();
  }

  Future<void> listener() async {
    final Duration videoLength = widget.videoPlayerController.value.duration;
    if (widget.videoPlayerController.value.isPlaying) {
      final Duration? currentTime = await widget.videoPlayerController.position;
      if (currentTime!.inMilliseconds - startVideoPisition.inMilliseconds >=
          500) {
        if (mounted) {
          setState(() {
            _visible = false;
          });
        }
      }
    }
    if ((await widget.videoPlayerController.position) == videoLength) {
      if (mounted) {
        _animationController.reverse();
      }
    }
  }

  void pauseVideo() {
    _animationController.reverse();
    if (mounted) {
      setState(() {
        _visible = true;
      });
    } else {
      _visible = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onTap() async {
    if (widget.videoPlayerController.value.isPlaying) {
      if (!_visible) {
        setState(() {
          _visible = true;
        });
      }
      final Duration pos = (await widget.videoPlayerController.position)!;
      setState(() {
        startVideoPisition = pos;
      });
      _animationController.reverse();
      widget.videoPlayerController.pause();
    } else {
      _animationController.forward();
      widget.videoPlayerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: _visible ? buttonFadeOutDuration : buttonFadeInDuration,
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          constraints: BoxConstraints.tight(Size.square(
              (widget.videoPlayerController.value.size.height / 2.5) >
                      commonContainerMax
                  ? commonContainerMax
                  : widget.videoPlayerController.value.size.height / 2.5)),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _animationController,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
