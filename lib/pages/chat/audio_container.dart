import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioContainer extends StatefulWidget {
  final String audioUrl;
  final String storagePath;
  final bool elementcheck;
  final Duration duration;
  const AudioContainer(
      {Key? key,
      required this.elementcheck,
      required this.duration,
      required this.audioUrl,
      required this.storagePath})
      : super(key: key);

  @override
  _AudioContainerState createState() => _AudioContainerState();
}

class _AudioContainerState extends State<AudioContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _audio = AudioPlayer();
  bool? isInitialized;

  Duration currentAudioPosition = Duration.zero;
  Duration audioDuration = Duration.zero;

  Future<void> initialize() async {
    try {
      // get the cache directory
      final Directory filePath = (await getTemporaryDirectory());

      if (!(await File("${filePath.path}/audio/${widget.storagePath}")
          .exists())) {
        if (mounted) {
          setState(() {
            isInitialized = false;
          });
        } else {
          isInitialized = false;
        }
        // get the video from firebase storage
        final response = await get(Uri.parse(widget.audioUrl));

        // create the cache directory in which the video
        // file will be saved in
        final File fileForAudio =
            await File("${filePath.path}/audio/${widget.storagePath}")
                .create(recursive: true);

        // read the video as bytes and create he video
        // in the file at the caches directory
        // ignore: unused_local_variable
        final File audioMaker =
            await fileForAudio.writeAsBytes(response.bodyBytes);

        await _audio.setFilePath(fileForAudio.path,
            initialPosition: Duration.zero);

        // used for telling the widget that the audio
        // has loaded e.g. remove the loading
        if (mounted) {
          setState(() {
            isInitialized = true;
          });
        } else {
          isInitialized = true;
        }

        _audio.durationStream.listen((duration) {
          if (mounted) {
            setState(() {
              audioDuration = Duration(milliseconds: duration!.inMilliseconds);
            });
          } else {
            audioDuration = Duration(milliseconds: duration!.inMilliseconds);
          }
        });
        // used for seek bar purposes, like updating it
        // and stopping it when it stops
        _audio.positionStream.listen((event) {
          if (audioDuration != Duration.zero) {
            if (event.inMilliseconds >= audioDuration.inMilliseconds) {
              // the audio has finished, restart the slider
              // and reverse the animation button

              if (_animationController.isCompleted) {
                _animationController.reverse();
              }
              event = Duration.zero;
              if (mounted) {
                setState(() {
                  currentAudioPosition = event;
                });
              } else {
                currentAudioPosition = event;
              }
              _audio.seek(event);
              _audio.pause();
            } else {
              // the audio is playing, update the slider with the event duration

              if (mounted) {
                setState(() {
                  currentAudioPosition = event;
                });
              } else {
                currentAudioPosition = event;
              }
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            isInitialized = false;
          });
        } else {
          isInitialized = false;
        }
        await _audio.setFilePath("${filePath.path}/audio/${widget.storagePath}",
            initialPosition: Duration.zero);
        if (mounted) {
          setState(() {
            isInitialized = true;
          });
        } else {
          isInitialized = true;
        }

        var duration = _audio.duration;

        // used for seek bar purposes, like updating it
        // and stopping it when it stops
        _audio.positionStream.listen((event) {
          if (duration != null) {
            if (event.inMilliseconds >= duration.inMilliseconds) {
              // the audio has finished, restart the slider
              // and reverse the animation button

              if (_animationController.isCompleted) {
                _animationController.reverse();
              }
              event = Duration.zero;
              if (mounted) {
                setState(() {
                  currentAudioPosition = event;
                });
              } else {
                currentAudioPosition = event;
              }
              _audio.seek(event);
              _audio.pause();
            } else {
              // the audio is playing, update the slider with the event duration

              if (mounted) {
                setState(() {
                  currentAudioPosition = event;
                });
              } else {
                currentAudioPosition = event;
              }
            }
          }
        });
      }
    } catch (e) {
      // Todo: Test
      if (e.toString() != "Null check operator used on a null value") {
        Fluttertoast.showToast(
            msg: "An unknown error has occured, Please try again");
      }
    }
  }

  void pauseAudio() async {
    try {
      await _animationController.reverse();
      await _audio.pause();
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: "Could not pause audio, an error has occured");
      // TODO: Test
    }
  }

  void playAudio() async {
    try {
      await _animationController.forward();
      _audio.play();
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Could not play audio, an error has occured");
      // TODO: Test
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    super.initState();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elementCheck = widget.elementcheck;

    return Container(
        constraints: BoxConstraints.tight(const Size(240, 55)),
        child: Row(
          children: [
            SeekBarSlider(
                elementCheck: elementCheck,
                onEnd: () {
                  setState(() {
                    pauseAudio();
                  });
                },
                timerStyle: const TextStyle(fontSize: 12),
                total: _audio.duration ?? widget.duration,
                progress: currentAudioPosition,
                onChanged: (duration) {
                  setState(() {
                    _audio.seek(duration);
                  });
                },
                timerColor: elementCheck
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface),
            GestureDetector(
              onTap: () {
                if (_audio.playing) {
                  pauseAudio();
                } else {
                  if (isInitialized == null) {
                    initialize().then((value) => playAudio());
                  } else if (isInitialized == true) {
                    playAudio();
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: isInitialized == false
                    ? SpinKitRing(
                        lineWidth: 3.5,
                        color: elementCheck
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        size: 30,
                      )
                    : AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        size: 36,
                        progress: _animationController,
                        color: elementCheck
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
              ),
            ),
          ],
        ));
  }
}

class SeekBarSlider extends StatefulWidget {
  final Duration? total;
  final bool elementCheck;
  final Duration progress;
  final Function(Duration) onChanged;
  final Color timerColor;
  final TextStyle timerStyle;
  final Function onEnd;
  const SeekBarSlider(
      {Key? key,
      required this.elementCheck,
      required this.onEnd,
      required this.timerStyle,
      required this.total,
      required this.progress,
      required this.onChanged,
      required this.timerColor})
      : super(key: key);

  @override
  _SeekBarSliderState createState() => _SeekBarSliderState();
}

class _SeekBarSliderState extends State<SeekBarSlider> {
  @override
  Widget build(BuildContext context) {
    final elementCheck = widget.elementCheck;
    if (widget.total != null) {
      assert(widget.total!.inMilliseconds >= 100);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(180, 20)),
            child: Slider(
              thumbColor: elementCheck
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              inactiveColor: elementCheck
                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              activeColor: elementCheck
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              min: 0.0,
              max: widget.total!.inMilliseconds.toDouble() + 1,
              onChanged: (duration) {
                widget.onChanged(Duration(milliseconds: duration.toInt()));
              },
              value: widget.progress.inMilliseconds.toDouble() >
                      widget.total!.inMilliseconds.toDouble()
                  ? widget.total!.inMilliseconds.toDouble()
                  : widget.progress.inMilliseconds.toDouble(),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "${widget.progress.inMinutes.remainder(Duration.minutesPerHour)}:${widget.progress.inSeconds.remainder(Duration.secondsPerMinute) < 10 ? "0${widget.progress.inSeconds.remainder(Duration.secondsPerMinute)}" : widget.progress.inSeconds.remainder(Duration.secondsPerMinute)}",
                style: widget.timerStyle.copyWith(color: widget.timerColor),
              ),
              const SizedBox(
                width: 70,
              ),
              Text(
                "${widget.total!.inMinutes.remainder(Duration.minutesPerHour)}:${widget.total!.inSeconds.remainder(Duration.secondsPerMinute) < 10 ? "0${widget.total!.inSeconds.remainder(Duration.secondsPerMinute)}" : widget.total!.inSeconds.remainder(Duration.secondsPerMinute)}",
                style: widget.timerStyle.copyWith(color: widget.timerColor),
              )
            ],
          )
        ],
      );
    } else {
      return const SpinKitWave(
        size: 30,
        color: Colors.white,
        itemCount: 10,
      );
    }
  }
}
