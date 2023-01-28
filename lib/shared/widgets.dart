// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/pages/home/home.dart';
import 'package:saudi_chat/services/chat.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/shared/constants.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../pages/chat/nadi_details.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {Key? key,
      this.labelText,
      required this.validatorText,
      required this.onChangedVal,
      required this.validateCondition,
      this.inputStyle,
      this.obscureText,
      this.border,
      this.maxLines,
      this.formKey,
      this.labelStyle,
      this.cursorColor,
      this.focusedBorder,
      this.backgroundColor,
      this.maxLength,
      this.hintText,
      this.controller,
      this.hintTextStyle})
      : super(key: key);

  final String? labelText;
  final InputBorder? border;
  final OutlineInputBorder? focusedBorder;
  final String validatorText;
  final TextStyle? labelStyle;
  final bool? obscureText;
  final int? maxLines;
  final int? maxLength;
  final Color? backgroundColor;
  final String? hintText;
  final TextEditingController? controller;
  final TextStyle? hintTextStyle;
  final TextStyle? inputStyle;
  final Color? cursorColor;
  final Function(String? val) onChangedVal;
  final GlobalKey<FormState>? formKey;
  final Function(String? val, String errorText) validateCondition;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        cursorColor: cursorColor,
        style: inputStyle ?? const TextStyle(color: Colors.white),
        decoration: textInputDecoration.copyWith(
            hintText: hintText,
            hintStyle: hintTextStyle,
            labelStyle: labelStyle ?? const TextStyle(color: Colors.white),
            enabledBorder: border,
            labelText: labelText,
            filled: backgroundColor != null,
            fillColor: backgroundColor,
            focusedBorder: focusedBorder ??
                const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
        validator: (val) => validateCondition(val!, validatorText),
        onChanged: (val) {
          onChangedVal(val);
        });
  }
}

class MyDropdownField extends StatelessWidget {
  const MyDropdownField(
      {Key? key,
      required this.itemsList,
      required this.onChanged,
      required this.labelText,
      this.labelTextStyle,
      this.border,
      this.fillColor,
      this.validatorText})
      : super(key: key);

  final List itemsList;
  final OutlineInputBorder? border;
  final TextStyle? labelTextStyle;
  final Function(Object? val) onChanged;
  final String? labelText;
  final String? validatorText;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),
      validator: (val) => validatorText == null
          ? null
          : val == null
              ? validatorText
              : null,
      decoration: textInputDecoration.copyWith(
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          filled: fillColor != null,
          fillColor: fillColor ?? Colors.white.withOpacity(0.8),
          labelText: labelText,
          labelStyle: labelTextStyle ??
              TextStyle(color: Theme.of(context).textTheme.headline2!.color)),
      items: itemsList.map((item) {
        return DropdownMenuItem(
          child: Text(
            item,
            style: const TextStyle(fontSize: 16),
          ),
          value: item,
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class HorizontalListScrollView extends StatefulWidget {
  final Function onTap;
  final List childrenList;
  const HorizontalListScrollView(
      {Key? key, required this.onTap, required this.childrenList})
      : super(key: key);

  @override
  _HorizontalListScrollViewState createState() =>
      _HorizontalListScrollViewState();
}

class _HorizontalListScrollViewState extends State<HorizontalListScrollView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: widget.childrenList.map((e) {
        return InkWell(
          onTap: () => widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_circle,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    Text(e, style: Theme.of(context).textTheme.bodyText2)
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList()),
    );
  }
}

class ApplyElevatedButton extends StatelessWidget {
  final String text;
  final Function onTap;
  const ApplyElevatedButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(76, 40)),
        ),
        onPressed: () => onTap(),
        child: Text(text));
  }
}

class CancelElevatedButton extends StatelessWidget {
  final String text;
  final Function onTap;
  const CancelElevatedButton(
      {Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            side: MaterialStateProperty.all(
                BorderSide(color: Theme.of(context).primaryColor)),
            fixedSize: MaterialStateProperty.all(const Size(76, 40)),
            backgroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () => onTap(),
        child: Text(
          text,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ));
  }
}

class PendingOutlinedScreen extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  bool visible;
  final double? height;
  final List<Color> colors;

  PendingOutlinedScreen({
    Key? key,
    required this.visible,
    required this.strokeWidth,
    this.height,
    required this.colors,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible,
        child: Column(children: [
          AnimatedContainer(
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 500),
              height: height,
              child: PlayAnimation<double?>(
                tween: Tween(begin: 240, end: 700),
                duration: const Duration(seconds: 60),
                fps: 60,
                curve: Curves.linear,
                builder: (context, child, value) => CustomPaint(
                  painter: GradientPainter(
                      strokeWidth: strokeWidth,
                      radius: radius,
                      gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          transform: GradientRotation(value ?? 0))),
                  child: Container(),
                ),
              ))
        ]));
  }
}

class GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GradientPainter(
      {required this.strokeWidth,
      required this.radius,
      required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class PendingBar extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final List<Color>? colors;
  bool visible;

  PendingBar({
    Key? key,
    required this.visible,
    required this.strokeWidth,
    this.colors,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Column(
        children: [
          AnimatedContainer(
              width: MediaQuery.of(context).size.width,
              height: 14,
              duration: const Duration(milliseconds: 500),
              child: PlayAnimation<double?>(
                tween: Tween(begin: 50, end: 240),
                duration: const Duration(seconds: 60),
                fps: 60,
                curve: Curves.linear,
                builder: (context, child, value) => CustomPaint(
                  painter: GradientPainter(
                      strokeWidth: strokeWidth,
                      radius: radius,
                      gradient: LinearGradient(
                          colors: colors ??
                              [
                                Colors.grey.shade200,
                                Theme.of(context).colorScheme.secondaryContainer
                              ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          transform: GradientRotation(value ?? 0))),
                  // ignore: sized_box_for_whitespace
                ),
              )),
        ],
      ),
    );
  }
}

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  const MyTooltip({Key? key, required this.message, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(key),
      child: child,
    );
  }

  void _onTap(GlobalKey key) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }
}

class ScreenWidthCard extends StatelessWidget {
  final Widget child;
  final Color? highlightColor;
  final Color? splashColor;
  final Function? onTap;
  final double height;
  const ScreenWidthCard(
      {Key? key,
      this.highlightColor,
      this.splashColor,
      required this.child,
      required this.height,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: splashColor,
      highlightColor: highlightColor,
      onTap: onTap == null ? () {} : () => onTap!(),
      child: SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: child,
      ),
    );
  }
}

late OverlayEntry? _showCenterScreenMenuOverlayEntry;

void showCenterScreenMenu(BuildContext context, CenterScreenOptionsMenu menu) {
  _showCenterScreenMenuOverlayEntry = OverlayEntry(builder: (context) {
    return Material(
      color: Colors.transparent,
      child: menu,
    );
  });
  Overlay.of(context)!.insert(_showCenterScreenMenuOverlayEntry!);
}

class CenterScreenOptionsMenu extends StatelessWidget {
  final List<CSOM> items;
  final Function(dynamic) onSelected;
  const CenterScreenOptionsMenu(
      {Key? key, required this.items, required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTap: () => _showCenterScreenMenuOverlayEntry!.remove(),
        child: PlayAnimation<double>(
          tween: Tween(begin: 0.0, end: 0.5),
          duration: const Duration(milliseconds: 130),
          builder: (context, child, value) => Container(
            color: Colors.black.withOpacity(value),
          ),
        ),
      ),
      Center(
        child: PlayAnimation<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 130),
          builder: (context, child, value) => Container(
            constraints: BoxConstraints.tightFor(
                width: MediaQuery.of(context).size.width / 2.2,
                height: items.length * items.first.height! + 28),
            decoration: BoxDecoration(
              color: Colors.grey[850]!.withOpacity(value),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((csom) {
                  if (csom.type == CenterScreenOptionsMenuItem) {
                    var item = csom as CenterScreenOptionsMenuItem;
                    return SizedBox(
                      width: Size.infinite.width,
                      height: item.height,
                      child: InkWell(
                        splashColor: Colors.white,
                        onTap: () {
                          onSelected(item.value);
                          _showCenterScreenMenuOverlayEntry!.remove();
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(0, item.height! / 4, 0, 0),
                          child: Text(
                            item.text,
                            style: Theme.of(context)
                                .popupMenuTheme
                                .textStyle!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  } else {
                    assert(csom.type == CenterScreenOptionsMenuDropDown);
                    var item = csom as CenterScreenOptionsMenuDropDown;
                    return SizedBox(
                        width: Size.infinite.width,
                        height: item.height,
                        child: DropdownButton(
                            items: item.items
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e.toString())))
                                .toList(),
                            onChanged: (index) {
                              //
                            }));
                  }
                }).toList()),
          ),
        ),
      )
    ]);
  }
}

class CSOMKickBanAMember extends StatefulWidget {
  const CSOMKickBanAMember({Key? key}) : super(key: key);

  @override
  _CSOMKickBanAMemberState createState() => _CSOMKickBanAMemberState();
}

class _CSOMKickBanAMemberState extends State<CSOMKickBanAMember> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CenterScreenOptionsMenuItem extends CSOM {
  final String text;
  CenterScreenOptionsMenuItem(
      {required this.text, required dynamic value, required double? height})
      : super(value: value, height: height);

  @override
  Type get type => CenterScreenOptionsMenuItem;
}

class CenterScreenOptionsMenuDropDown extends CSOM {
  final String title;
  final List<String> items;
  final Function(dynamic) onChanged;

  CenterScreenOptionsMenuDropDown({
    required this.onChanged,
    required this.title,
    required this.items,
    dynamic value,
  }) : super(value: value);

  @override
  Type get type => CenterScreenOptionsMenuDropDown;
}

abstract class CSOM {
  final dynamic value;
  double? height = 40;

  CSOM({required this.value, this.height});

  double get width => Size.infinite.width;

  Type get type => CSOM;
}

class NoGlowScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class EmojiPickerWidget extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;
  final double keyboardHeight;

  const EmojiPickerWidget({
    required this.onEmojiSelected,
    required this.keyboardHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Config config = Config(
        columns: 7,
        skinToneIndicatorColor: Colors.grey,
        bgColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFEBEFF2)
            : const Color(0xFF303030));

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size.fromHeight(keyboardHeight)),
        child: EmojiPicker(
          config: config,
          onEmojiSelected: (category, emoji) => onEmojiSelected(emoji.emoji),
        ),
      ),
    );
  }
}

class GroupInfoCard extends StatelessWidget {
  final Map groupData;
  final AsyncSnapshot unreadMessageSnapshot;
  // groupData is the group information map that is on the users groups list
  const GroupInfoCard(
      {Key? key, required this.unreadMessageSnapshot, required this.groupData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _kOutsideContainerSize = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height / 9);

    dynamic streamedUser = Provider.of<UserAuth>(context);

    const double kContainerRadius = 102;

    const double kBorderThickness = 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onItemTap(
              context,
              streamedUser,
              DataBaseService().messagesCollection.doc(groupData["nadi_id"]),
              groupData["nadiReference"]),
          child: Container(
              height: _kOutsideContainerSize.height,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: _kOutsideContainerSize.height,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          NewMessageCircleAvatar(
                              snapshot: unreadMessageSnapshot,
                              radius: kContainerRadius,
                              borderThickness: kBorderThickness),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: LanguageTypeText(
                                      groupData["name"],
                                      style: TextStyle(
                                          fontFamily: "Ubuntu",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2,
                                          fontSize: calculateAutoscaleFontSize(
                                              groupData["name"],
                                              const TextStyle(
                                                  letterSpacing: 0.2),
                                              18,
                                              30,
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.4),
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await onInfoIconTapped(context, streamedUser);
                          },
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  onItemTap(BuildContext context, dynamic streamedUser, DocumentReference doc,
      DocumentReference nadiDocument) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(
          groupDocument: doc,
          nadiDocument: nadiDocument,
          streamedUser: streamedUser);
    }));
  }

  DocumentReference groupDocument() {
    DocumentReference documentReference =
        MessageDatabase().messagesCollection.doc(groupData["nadi_id"]);
    return documentReference;
  }

  Future<void> onMessageIconTapped(
      BuildContext context, UserAuth streamedUser) async {
    // This will get the Group DocumentReference from the [Groups] collection

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(
        groupDocument: groupDocument(),
        nadiDocument: groupData["nadiReference"],
        streamedUser: streamedUser,
      );
    }));
  }

  Future<void> onInfoIconTapped(
      BuildContext context, UserAuth streamedUser) async {
    QuerySnapshot groupmembersCollection = await DataBaseService()
        .messagesCollection
        .doc(groupDocument().id)
        .collection("members")
        .get();

    Map groupData = {
      "nadi_data":
          await DataBaseService().nadiCollection.doc(groupDocument().id).get()
    };

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NadiDetails(
        streamUser: streamedUser,
        groupDocument: groupDocument(),
        membersCollection: groupmembersCollection,
        groupData: groupData,
      );
    }));
  }

  Future<void> onExitIconTapped(
      BuildContext context, UserAuth streamedUser, String groupName) async {
    Future<void> onLeavePressed() async {
      NadiData _groupData = NadiData.parse(groupData);

      await DataBaseService()
          .removeUserFromGroup(user: streamedUser, nadi: _groupData);

      return;
    }

    showCustomAlertDialog(context, "Are you sure you want to leave",
        '"$groupName"?', "Leave", null, () {
      onLeavePressed();
      Navigator.pop(context);
    });
  }
}

class UserInfoCard extends StatefulWidget {
  final UserAuth userData;
  final TextEditingController? searchFieldController;
  // groupData is the group information map that is on the users groups list
  const UserInfoCard(
      {Key? key, required this.userData, this.searchFieldController})
      : super(key: key);

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    final _kOutsideContainerSize = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height / 10);

    dynamic streamedUser = Provider.of<UserAuth>(context);

    return Container(
        height: _kOutsideContainerSize.height,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: _kOutsideContainerSize.height,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: _kOutsideContainerSize.height / 3 * 2,
                      child: CircleAvatar(
                          radius: _kOutsideContainerSize.height / 3,
                          backgroundImage: Image.asset(
                            "assets/new_nadi_profile_pic.jpg",
                          ).image),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: LanguageTypeText(
                                widget.userData.displayName!,
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                    fontSize: calculateAutoscaleFontSize(
                                        widget.userData.displayName!,
                                        const TextStyle(letterSpacing: 0.2),
                                        18,
                                        30,
                                        MediaQuery.of(context).size.width /
                                            2.4),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Flexible(
                                child: Text(
                              widget.userData.email!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.8)),
                            ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // GestureDetector(
                  //   onTap: () async {
                  //     await onMessageIconTapped(context, streamedUser);
                  //   },
                  //   child: const Icon(
                  //     Icons.messenger_rounded,
                  //     color: Colors.white,
                  //     size: 24,
                  //   ),
                  // ),
                  // const SizedBox(
                  //   width: 8,
                  // ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     await onInfoIconTapped(context, streamedUser);
                  //   },
                  //   child: const Icon(
                  //     Icons.info_outline_rounded,
                  //     color: Colors.white,
                  //     size: 24,
                  //   ),
                  // ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await onBlockIconTapped(
                          context, widget.userData, streamedUser);
                    },
                    child: const Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  // DocumentReference groupDocument() {
  Future<void> onBlockIconTapped(
      BuildContext context, UserAuth user, UserAuth streamedUser) async {
    Future<void> onBlockPressedAdmin() async {
      await DataBaseService().removeUserFromGroup(
          user: user,
          nadi: NadiData.parse(
              (await streamedUser.groupAdmin!.get()).data() as Map));

      Navigator.pop(context);

      return;
    }

    Future<void> onBlockPressedModerator(NadiData nadiData) async {
      await DataBaseService().removeUserFromGroup(user: user, nadi: nadiData);

      Navigator.pop(context);

      return;
    }

    if (streamedUser.userClass == UserClass.admin ||
        streamedUser.userClass == UserClass.coAdmin) {
      showCustomAlertDialog(
          context,
          "Are you sure you want to Kick",
          '"${widget.userData.displayName}"?',
          "Kick",
          widget.searchFieldController, () async {
        await onBlockPressedAdmin();
      });
      return;
    }
    if (streamedUser.userClass == UserClass.moderator) {
      showUserKickModeratorDialog(
          context,
          'Choose a group to kick',
          '"${user.displayName}" from.',
          user.groups!.map((e) => NadiData.parse(e)).toList(),
          "Group:",
          "Kick", (nadiData) async {
        await onBlockPressedModerator(nadiData);
        return;
      });
    }
  }

  Future<void> showUserKickModeratorDialog(
      BuildContext context,
      String topText,
      String bottomText,
      List<NadiData> dropDownItemsList,
      String dropDownText,
      String rightButtonText,
      Future Function(NadiData) rightButtonFunction) async {
    late NadiData? group;

    final _formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(topText, textAlign: TextAlign.center),
                  Text(bottomText, textAlign: TextAlign.center),
                  const SizedBox(
                    height: 12,
                  ),
                  MyDropdownField(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground)),
                    itemsList:
                        dropDownItemsList.map((e) => e.nadiName).toList(),
                    onChanged: (val) {
                      setState(() {
                        group = dropDownItemsList
                            .where((element) => element.nadiName == val)
                            .single;
                      });
                    },
                    labelText: dropDownText,
                    validatorText: "Choose a group to kick from",
                  )
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            alignment: Alignment.center,
            actions: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 17),
                ),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await rightButtonFunction(group!);
                    if (widget.searchFieldController != null) {
                      setState(() {
                        widget.searchFieldController!.clear();
                      });
                    }
                  }
                },
                child: Text(
                  rightButtonText,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 17),
                ),
              ),
            ],
          );
        });
  }
}

Future<void> showCustomAlertDialog(
    BuildContext context,
    String topText,
    String bottomText,
    String rightButtonText,
    TextEditingController? searchFieldController,
    FutureOr rightButtonFunction) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(topText, textAlign: TextAlign.center),
              Text(
                bottomText,
                textAlign: TextAlign.center,
              )
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          actions: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 17),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await rightButtonFunction!!();
                if (searchFieldController != null) {
                  searchFieldController.clear();
                }
              },
              child: Text(
                rightButtonText,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 17),
              ),
            ),
          ],
        );
      });
}

double calculateAutoscaleFontSize(String text, TextStyle style,
    double startFontSize, double maxFontSize, double maxWidth) {
  final textPainter = TextPainter(
    textDirection: text.characters.any((element) =>
            arabicLetters.any((arabicLetter) => arabicLetter == element))
        ? TextDirection.rtl
        : TextDirection.ltr,
  );

  var currentFontSize = startFontSize;

  for (var i = 0; i < maxFontSize; i++) {
    // limit max iterations to 100
    final nextFontSize = currentFontSize + 1;
    final nextTextStyle = style.copyWith(fontSize: nextFontSize);
    textPainter.text = TextSpan(text: text, style: nextTextStyle);
    textPainter.layout();
    if (textPainter.width >= maxWidth) {
      break;
    } else {
      currentFontSize = nextFontSize;
      // continue iteration
    }
  }

  return currentFontSize;
}

class LanguageTypeText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  const LanguageTypeText(
    this.data, {
    Key? key,
    this.style,
    this.strutStyle,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textDirection: data.characters.any((element) =>
              arabicLetters.any((arabicLetter) => arabicLetter == element))
          ? TextDirection.rtl
          : TextDirection.ltr,
      textAlign: data.characters.any((element) =>
              arabicLetters.any((arabicLetter) => arabicLetter == element))
          ? TextAlign.right
          : TextAlign.left,
      style: style,
      strutStyle: strutStyle,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

class NewMessageCircleAvatar extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final double radius;
  final double borderThickness;
  const NewMessageCircleAvatar(
      {Key? key,
      required this.snapshot,
      required this.radius,
      required this.borderThickness})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: snapshot.data != null && snapshot.data == true
                  ? [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).primaryColor
                    ]
                  : [Colors.grey.shade200, Colors.grey.shade400]),
          shape: BoxShape.circle),
      height: radius,
      padding: EdgeInsets.all(borderThickness),
      child: Container(
        height: radius - (borderThickness + 2),
        padding: const EdgeInsets.all(3),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 32,
          backgroundImage: Image.asset(
            "assets/new_nadi_profile_pic.jpg",
          ).image,
        ),
      ),
    );
  }
}
