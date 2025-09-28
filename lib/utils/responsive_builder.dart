import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return builder(context, isMobile);
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    TextStyle responsiveStyle = style ?? const TextStyle();

    // Increase font size on mobile for better readability
    if (responsiveStyle.fontSize != null) {
      responsiveStyle = responsiveStyle.copyWith(
        fontSize: isMobile ? responsiveStyle.fontSize! + 2 : responsiveStyle.fontSize,
      );
    }

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double mobilePaddingMultiplier;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.padding,
    this.mobilePaddingMultiplier = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    EdgeInsets responsivePadding = padding ?? const EdgeInsets.all(16);

    if (isMobile) {
      responsivePadding = EdgeInsets.fromLTRB(
        responsivePadding.left * mobilePaddingMultiplier,
        responsivePadding.top * mobilePaddingMultiplier,
        responsivePadding.right * mobilePaddingMultiplier,
        responsivePadding.bottom * mobilePaddingMultiplier,
      );
    }

    return Padding(
      padding: responsivePadding,
      child: child,
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ResponsiveButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ElevatedButton(
      onPressed: onPressed,
      style: style?.copyWith(
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, isMobile ? 56 : 48),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 16,
            vertical: isMobile ? 16 : 12,
          ),
        ),
      ),
      child: child,
    );
  }
}

// Helper functions for responsive design
class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize + 2; // Bigger text on mobile
    }
    return baseFontSize;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, EdgeInsets basePadding) {
    if (isMobile(context)) {
      return EdgeInsets.fromLTRB(
        basePadding.left * 1.5,
        basePadding.top * 1.5,
        basePadding.right * 1.5,
        basePadding.bottom * 1.5,
      );
    }
    return basePadding;
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing * 1.2; // More spacing on mobile
    }
    return baseSpacing;
  }

  static Size getResponsiveButtonSize(BuildContext context) {
    if (isMobile(context)) {
      return const Size(double.infinity, 56); // Bigger touch targets on mobile
    }
    return const Size(double.infinity, 48);
  }
}