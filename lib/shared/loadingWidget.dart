// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: SpinKitCircle(
        color: Theme.of(context).primaryColorLight,
        size: 70,
      )),
      color: Colors.black.withOpacity(0.5),
    );
  }
}

class LoadingSpinnerNoColor extends StatelessWidget {
  const LoadingSpinnerNoColor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SpinKitCircle(
      color: Colors.black,
      size: 70,
    ));
  }
}

OverlayEntry? _overlayEntry = OverlayEntry(builder: (context) {
  return Material(
    color: Colors.black.withOpacity(0.5),
    child: const LoadingSpinner(),
  );
});

void createLoadingOverlay(BuildContext context) {
  return Overlay.of(context)!.insert(_overlayEntry!);
}

void removeOverlayEntry(BuildContext context) {
  _overlayEntry!.remove();
}

OverlayEntry? _overlayBottomloadingEntry = OverlayEntry(builder: (context) {
  return Material(
    color: Colors.black.withOpacity(0.5),
    child: const LoadingSpinner(),
  );
});

void createBottomLoadingOverlay(BuildContext context) {
  return Overlay.of(context)!.insert(_overlayBottomloadingEntry!);
}

void removeBottomOverlayEntry(BuildContext context) {
  if (_overlayBottomloadingEntry!.mounted) {
    _overlayBottomloadingEntry!.remove();
  }
}

class LoadingBottomBar extends StatefulWidget {
  const LoadingBottomBar({Key? key}) : super(key: key);

  @override
  _LoadingBottomBarState createState() => _LoadingBottomBarState();
}

class _LoadingBottomBarState extends State<LoadingBottomBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 10,
        child: LiquidLinearProgressIndicator(
          borderWidth: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ));
  }
}
