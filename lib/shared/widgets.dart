// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saudi_chat/shared/constants.dart';
import 'package:simple_animations/simple_animations.dart';

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

  final TextStyle? hintTextStyle;
  final TextStyle? inputStyle;
  final Function(String? val) onChangedVal;
  final GlobalKey<FormState>? formKey;
  final Function(String? val, String errorText) validateCondition;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
  final String labelText;
  final String? validatorText;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.primaryVariant),
      validator: (val) => validatorText == null
          ? null
          : val == null
              ? validatorText
              : null,
      decoration: textInputDecoration.copyWith(
          border: border,
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
                  painter: _GradientPainter(
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

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter(
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
                  painter: _GradientPainter(
                      strokeWidth: strokeWidth,
                      radius: radius,
                      gradient: LinearGradient(
                          colors: colors ??
                              [
                                Colors.grey.shade200,
                                Theme.of(context).colorScheme.secondaryVariant
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
