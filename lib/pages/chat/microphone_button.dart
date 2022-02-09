import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:media_info/media_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:saudi_chat/models/message.dart';
import 'package:saudi_chat/services/chat.dart';
import 'package:saudi_chat/shared/widgets.dart';
import 'package:uuid/uuid.dart';

class MicrophoneButton extends StatefulWidget {
  final String groupId;
  final dynamic streamedUser;
  final Function onLoadingStart;
  final Function onLoadingEnd;
  const MicrophoneButton(
      {Key? key,
      required this.groupId,
      required this.streamedUser,
      required this.onLoadingStart,
      required this.onLoadingEnd})
      : super(key: key);

  @override
  _MicrophoneButtonState createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends State<MicrophoneButton> {
  double animatedHeight = 48;
  Color? animatedBorderColor;

  double dragContainerForCancelPositioBottomPadding = 0;
  bool longPressed = false;

  MediaInfo info = MediaInfo();
  Duration? infoDuration;

  // audio recorder var
  final audioRecorder = Record();

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 2.5),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Material(
                borderRadius: BorderRadius.circular(25),
                elevation: animatedHeight != 48 ? 2 : 0,
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.surface),
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.transparent),
                  constraints: BoxConstraints.loose(Size(48, animatedHeight)),
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 200),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child:
                      Icon(Icons.delete_outline, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                0, 0, 0, dragContainerForCancelPositioBottomPadding),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: longPressed ? Border.all(color: Colors.red) : null,
                  shape: BoxShape.circle),
            ),
          ),
          MyTooltip(
            message: "Hold to record and release to send",
            child: GestureDetector(
              onLongPressMoveUpdate: (details) {
                setState(() {
                  dragContainerForCancelPositioBottomPadding = details
                          .offsetFromOrigin.dy.isNegative
                      ? details.offsetFromOrigin.dy.abs() > animatedHeight - 48
                          ? animatedHeight - 48
                          : details.offsetFromOrigin.dy.abs()
                      : 0;
                  if (dragContainerForCancelPositioBottomPadding.isNegative) {
                    dragContainerForCancelPositioBottomPadding = 0;
                  }
                });
              },
              onLongPressStart: (details) async {
                // start recording
                final PermissionStatus oldStatus =
                    await Permission.microphone.status;
                final recordStatus = await recordAudio().catchError((error) {
                  if (error is PermissionStatus) {
                    if ((error).isDenied) {
                      return false;
                    } else if ((error).isPermanentlyDenied) {
                      // do something if permenantly denied
                      // probably open ap settings to change the permission
                      return false;
                    }
                  } else {
                    return false;
                  }
                });

                if (recordStatus is! bool && oldStatus.isGranted) {
                  setState(() {
                    longPressed = true;
                    animatedHeight = animatedHeight == 48
                        ? animatedHeight * 2.75
                        : animatedHeight * 1;
                    animatedBorderColor = Colors.red.shade300.withOpacity(0.5);
                    dragContainerForCancelPositioBottomPadding = 0;
                  });
                }
              },
              onLongPressEnd: (details) async {
                if (animatedHeight != 48) {
                  if (dragContainerForCancelPositioBottomPadding + 48 ==
                      animatedHeight) {
                    // delete recording
                    await deleteRecording();
                  } else {
                    // send recording
                    widget.onLoadingStart();
                    final recordPath = await stopRecording();
                    if (recordPath is String) {
                      final File audioFile = File(recordPath);
                      if (await audioFile.exists()) {
                        MessageDatabase()
                            .addVoiceMessage(
                                audioFile,
                                widget.groupId,
                                VoiceMessage(
                                    durationMilliseconds: infoDuration!,
                                    userName: widget.streamedUser.displayName,
                                    documentId: widget.streamedUser.uid))
                            .then((value) => widget.onLoadingEnd());
                      }
                    } else {
                      widget.onLoadingEnd();
                    }
                  }
                  setState(() {
                    animatedHeight = 48;
                    animatedBorderColor = null;
                    longPressed = false;
                  });
                }
              },
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 48,
                  curve: Curves.easeOut,
                  width: 48,
                  decoration: BoxDecoration(
                      boxShadow: animatedBorderColor != null
                          ? [
                              BoxShadow(
                                  color: animatedBorderColor!, spreadRadius: 12)
                            ]
                          : null,
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 26,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future recordAudio() async {
    try {
      final permission = await requestRecordPermission();
      if (permission.isGranted || permission == PermissionStatus.granted) {
        final String id = const Uuid().v4();
        final Directory cache = await MessageDatabase().cache;
        final String path = "${cache.path}/audio/$id.mp3";
        final File file = await File(path).create(recursive: true);
        final bool exists = await File(path).exists();
        if (exists) {
          await audioRecorder.start(path: file.path);
        }
      } else {
        return Future.error(permission);
      }
    } catch (e, stacktrace) {
      print(e.toString() + stacktrace.toString());
      Fluttertoast.showToast(
          msg: "Could not record Audio, an error has occured!");
      //TODO: Test
    }
  }

  Future stopRecording() async {
    try {
      if (await audioRecorder.isRecording()) {
        final recordPath = await audioRecorder.stop();
        final Map _info = await info.getMediaInfo(recordPath!);
        setState(() {
          infoDuration = Duration(milliseconds: _info["durationMs"]);
        });
        return recordPath;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Could not stop voice record, an error has occured");
      print(e.toString());
      //TODO: Test
    }
  }

  Future<void> deleteRecording() async {
    try {
      final String? audioPath = await audioRecorder.stop();
      if (audioPath != null) {
        if (await File(audioPath).exists()) {
          await File(audioPath).delete();
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: "Could not delete recording, an error has occured");
    }
  }

  Future<PermissionStatus> requestRecordPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      PermissionStatus requestStatus = await Permission.microphone.request();
      status = requestStatus;
      // wether the user has not gave access
      // to use the microphone which we will
      // then not record sound to sound to other user
      return requestStatus;
    } else {
      return status;
    }
  }
}
