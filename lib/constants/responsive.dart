import 'package:flutter/material.dart';

// Predefined responsive sizes
class ResponsiveSizes {
  static const double _baseFontSize = 16.0;
  static const double _basePadding = 16.0;
  static const double _baseMargin = 16.0;
  static const double _baseRadius = 8.0;

  static double get fontSizeSmall => _baseFontSize * 0.75;
  static double get fontSizeMedium => _baseFontSize;
  static double get fontSizeLarge => _baseFontSize * 1.25;
  static double get fontSizeXLarge => _baseFontSize * 1.5;

  static double get paddingSmall => _basePadding * 0.5;
  static double get paddingMedium => _basePadding;
  static double get paddingLarge => _basePadding * 1.5;
  static double get paddingXLarge => _basePadding * 2;

  static double get marginSmall => _baseMargin * 0.5;
  static double get marginMedium => _baseMargin;
  static double get marginLarge => _baseMargin * 1.5;
  static double get marginXLarge => _baseMargin * 2;

  static double get radiusSmall => _baseRadius * 0.5;
  static double get radiusMedium => _baseRadius;
  static double get radiusLarge => _baseRadius * 1.5;
  static double get radiusXLarge => _baseRadius * 2;
}

class Responsive {
  static const double _mobileWidth = 600;
  static const double _tabletWidth = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileWidth &&
      MediaQuery.of(context).size.width < _tabletWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletWidth;

  // Get responsive font size
  static double getFontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileWidth) {
      return size * 0.8; // Smaller on mobile
    } else if (width < _tabletWidth) {
      return size * 0.9; // Medium on tablet
    }
    return size; // Full size on desktop
  }

  // Get responsive padding
  static double getPadding(BuildContext context, double padding) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileWidth) {
      return padding * 0.8;
    } else if (width < _tabletWidth) {
      return padding * 0.9;
    }
    return padding;
  }

  // Get responsive margin
  static double getMargin(BuildContext context, double margin) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileWidth) {
      return margin * 0.8;
    } else if (width < _tabletWidth) {
      return margin * 0.9;
    }
    return margin;
  }

  // Get responsive border radius
  static double getRadius(BuildContext context, double radius) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileWidth) {
      return radius * 0.8;
    } else if (width < _tabletWidth) {
      return radius * 0.9;
    }
    return radius;
  }
}
