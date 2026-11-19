import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum GlassTier { card, input, pill, dock }

/// Komponen dasar Frosted Light Glassmorphism dengan pembiasan optik nyata.
/// Mendukung 4 tingkatan kaca: card, input, pill, dan dock.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final GlassTier tier;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? customBorder;
  final Color? tintColor;
  final double? width;
  final double? height;

  const GlassSurface({
    super.key,
    required this.child,
    this.tier = GlassTier.card,
    this.borderRadius,
    this.padding,
    this.customBorder,
    this.tintColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    double sigma;
    double opacity;
    double borderOpacity;
    List<BoxShadow> shadows;

    switch (tier) {
      case GlassTier.card:
        sigma = 18.0;
        opacity = 0.76;
        borderOpacity = 0.92;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case GlassTier.input:
        sigma = 12.0;
        opacity = 0.65;
        borderOpacity = 0.85;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case GlassTier.pill:
        sigma = 12.0;
        opacity = 0.58;
        borderOpacity = 0.80;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case GlassTier.dock:
        sigma = 24.0;
        opacity = 0.85;
        borderOpacity = 0.95;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ];
        break;
    }

    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final baseColor = tintColor ?? Colors.white;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: opacity),
            borderRadius: effectiveRadius,
            border: customBorder ??
                Border.all(
                  color: Colors.white.withValues(alpha: borderOpacity),
                  width: 1.0,
                ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Convenience card wrapper berbasis GlassSurface Tier 1.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? tintColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.border,
    this.tintColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: GlassTier.card,
      padding: padding,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      customBorder: border,
      tintColor: tintColor,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Kanvas Latar Belakang Mesh Gradient Arsitektural dengan Ambient Lighting Orbs.
/// Digunakan sebagai wrapper latar belakang pada setiap layar mobile.
class MeshCanvasBackground extends StatelessWidget {
  final Widget child;

  const MeshCanvasBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Multi-Stop Mesh Linear Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.meshCanvasGradient,
            ),
          ),
        ),

        // 2. Ambient Atmosphere Orb 1 (Top Left Indigo)
        Positioned(
          top: -70,
          left: -50,
          child: Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ambientIndigo,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
        ),

        // 3. Ambient Atmosphere Orb 2 (Mid-Right Emerald)
        Positioned(
          top: 300,
          right: -60,
          child: Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ambientEmerald,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
        ),

        // 4. Ambient Atmosphere Orb 3 (Bottom Left Soft Amber/Mint)
        Positioned(
          bottom: -40,
          left: 20,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ambientSky,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
        ),

        // 5. Forefront Interactive UI Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

