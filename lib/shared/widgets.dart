// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saudi_chat/shared/constants.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
      {required this.text, dynamic value, double? height})
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
