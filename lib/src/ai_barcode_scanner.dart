import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prodata_app/helpers/material_helper.dart';
import 'package:prodata_app/constants/color.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'enums/validate_type.dart';
import 'overlay.dart';

/// Barcode scanner widget
class AiBarcodeScanner extends StatefulWidget {
  /// Function that gets Called when barcode is scanned successfully
  final void Function(String) onScan;

  /// Function that gets called when a Barcode is detected.
  ///
  /// [barcode] The barcode object with all information about the scanned code.
  /// [args] Information about the state of the MobileScanner widget
  final Function(Barcode barcode, MobileScannerArguments? args)? onDetect;

  /// Validate barcode text with [ValidateType]
  /// [validateText] and [validateType] must be set together.
  final String? validateText;

  /// Validate type [ValidateType]
  /// Validator working with single string value only.
  final ValidateType? validateType;

  /// Set to false if you don't want duplicate barcode to be detected
  final bool allowDuplicates;

  /// Enable/Disable switch Camera Facing
  final bool? useSwitchCamera;

  /// Enable/Disable Torch
  final bool? useTorch;

  /// Hint to Button with Text
  final bool? hintToBtn;

  /// Callback function if hintToBtn = true
  final Function()? callbackBtn;

  /// Fit to screen
  final BoxFit fit;

  /// Barcode controller (optional)
  final MobileScannerController? controller;

  /// Show overlay or not (default: true)
  final bool showOverlay;

  /// Overlay border color (default: white)
  final Color borderColor;

  /// Overlay border width (default: 10)
  final double borderWidth;

  /// Overlay color
  final Color overlayColor;

  /// Overlay border radius (default: 10)
  final double borderRadius;

  /// Overlay border length (default: 30)
  final double borderLength;

  /// Overlay cut out width (optional)
  final double? cutOutWidth;

  /// Overlay cut out height (optional)
  final double? cutOutHeight;

  /// Overlay cut out offset (default: 0)
  final double cutOutBottomOffset;

  /// Overlay cut out size (default: 300)
  final double cutOutSize;

  /// Show hint or not (default: true)
  final bool showHint;

  /// Hint text (default: 'Scan QR Code')
  final String hintText;

  /// Hint margin
  final EdgeInsetsGeometry hintMargin;

  /// Hint padding
  final EdgeInsetsGeometry hintPadding;

  /// Hint background color (optional)
  final Color? hintBackgroundColor;

  /// Hint text style
  final TextStyle hintTextStyle;

  /// Show error or not (default: true)
  final bool showError;

  /// Error color (default: red)
  final Color errorColor;

  /// Error text (default: 'Invalid BarCode')
  final String errorText;

  /// Show success or not (default: true)
  final bool showSuccess;

  /// Success color (default: green)
  final Color successColor;

  /// Success text (default: 'BarCode Found')
  final String successText;

  /// Can auto back to previous page when barcode is successfully scanned (default: true)
  final bool canPop;

  const AiBarcodeScanner({
    Key? key,
    required this.onScan,
    this.validateText,
    this.validateType,
    this.allowDuplicates = false,
    this.fit = BoxFit.cover,
    this.controller,
    this.useTorch = true,
    this.useSwitchCamera = true,
    this.hintToBtn = false,
    this.callbackBtn,
    this.onDetect,
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 10,
    this.borderLength = 30,
    this.cutOutSize = 300,
    this.cutOutWidth,
    this.cutOutHeight,
    this.cutOutBottomOffset = 0,
    this.showHint = true,
    this.hintText = 'Escanear QRCode',
    this.hintMargin = const EdgeInsets.all(16),
    this.hintBackgroundColor,
    this.hintTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    this.hintPadding = const EdgeInsets.all(0),
    this.showOverlay = true,
    this.showError = true,
    this.errorColor = Colors.red,
    this.errorText = 'BarCode inválido',
    this.showSuccess = true,
    this.successColor = Colors.green,
    this.successText = 'BarCode encontrado',
    this.canPop = true,
  })  : assert(validateText == null || validateType != null),
        assert(validateText != null || validateType == null),
        super(key: key);

  @override
  State<AiBarcodeScanner> createState() => _AiBarcodeScannerState();
}

class _AiBarcodeScannerState extends State<AiBarcodeScanner> {
  /// bool to check if barcode is valid or not
  bool? _isSuccess;

  /// Scanner controller
  late MobileScannerController controller;

  @override
  void initState() {
    controller = widget.controller ?? MobileScannerController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            fit: widget.fit,
            allowDuplicates: widget.allowDuplicates,
            onDetect: (barcode, args) {
              widget.onDetect?.call(barcode, args);
              if (barcode.rawValue?.isEmpty ?? true) {
                debugPrint('Falha ao escanear Barcode');
                return;
              }
              if (widget.validateText?.isNotEmpty ?? false) {
                if (!widget.validateType!.toValidateTypeBool(
                    barcode.rawValue!, widget.validateText!)) {
                  if (!widget.allowDuplicates) {
                    HapticFeedback.vibrate();
                  }
                  final String code = barcode.rawValue!;
                  debugPrint('Barcode inválido => $code');
                  _isSuccess = false;
                  setState(() {});
                  return;
                }
              }
              _isSuccess = true;
              if (!widget.allowDuplicates) {
                HapticFeedback.mediumImpact();
              }
              final String code = barcode.rawValue!;
              debugPrint('Barcode encontrado => $code');
              widget.onScan(code);
              setState(() {});
              if (widget.canPop) {
                Navigator.pop(context);
              }
            },
          ),
          if (widget.showOverlay)
            Container(
              decoration: ShapeDecoration(
                shape: OverlayShape(
                  borderRadius: widget.borderRadius,
                  borderColor: ((_isSuccess ?? false) && widget.showSuccess)
                      ? widget.successColor
                      : (!(_isSuccess ?? true) && widget.showError)
                          ? widget.errorColor
                          : widget.borderColor,
                  borderLength: widget.borderLength,
                  borderWidth: widget.borderWidth,
                  cutOutSize: widget.cutOutSize,
                  cutOutBottomOffset: widget.cutOutBottomOffset,
                  cutOutWidth: widget.cutOutWidth,
                  cutOutHeight: widget.cutOutHeight,
                  overlayColor: widget.overlayColor,
                ),
              ),
            ),
          if (widget.showHint)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  color: widget.hintBackgroundColor,
                  margin: widget.hintMargin,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: ListTile(
                    contentPadding: widget.hintPadding,
                    leading: widget.useSwitchCamera!
                        ? IconButton(
                            color: Theme.of(context).primaryColor,
                            tooltip: "Switch Camera",
                            onPressed: () => controller.switchCamera(),
                            icon: ValueListenableBuilder<CameraFacing>(
                              valueListenable: controller.cameraFacingState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case CameraFacing.front:
                                    return const Icon(Icons.camera_front);
                                  case CameraFacing.back:
                                    return const Icon(Icons.camera_rear);
                                }
                              },
                            ),
                          )
                        : null,
                    title: !widget.hintToBtn
                        ? Text(
                            widget.hintText,
                            textAlign: TextAlign.center,
                            style: widget.hintTextStyle,
                          )
                        : ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialHelper.mspc(corPrincipal),
                              elevation: MaterialHelper.mspd(2),
                              fixedSize: MaterialHelper.msize(
                                  Size(MediaQuery.of(context).size.width, 50)),
                            ),
                            onPressed: () {
                              widget.callbackBtn()!;
                            },
                            icon: Icon(
                              Icons.check_circle,
                              color: white,
                            ),
                            label: Text(
                              widget.hintText,
                              style: TextStyle(color: white),
                            )),
                    trailing: widget.useTorch!
                        ? IconButton(
                            tooltip: "Flash",
                            onPressed: () => controller.toggleTorch(),
                            icon: ValueListenableBuilder<TorchState>(
                              valueListenable: controller.torchState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case TorchState.off:
                                    return const Icon(
                                      Icons.flash_off,
                                      color: Colors.grey,
                                    );
                                  case TorchState.on:
                                    return const Icon(
                                      Icons.flash_on,
                                      color: Colors.orange,
                                    );
                                }
                              },
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
