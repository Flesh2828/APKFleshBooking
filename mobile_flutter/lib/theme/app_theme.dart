import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna dan spesifikasi token visual GuildSpace Frosted Light Glassmorphism.
/// Menampilkan Glassmorphism modern dengan aksen warna Indigo & Emerald.
class AppColors {
  // Brand Primary & Accents (GuildSpace Indigo & Emerald Palette)
  static const Color brandIndigo = Color(0xFF4F46E5); // Indigo 600
  static const Color brandIndigoDark = Color(0xFF3730A3); // Indigo 800
  static const Color brandIndigoLight = Color(0xFF6366F1); // Indigo 500
  
  static const Color brandEmerald = Color(0xFF10B981); // Emerald 500
  static const Color brandEmeraldDark = Color(0xFF059669); // Emerald 600
  static const Color brandEmeraldLight = Color(0xFF34D399); // Emerald 400
  static const Color brandEmeraldMint = Color(0xFFD1FAE5); // Emerald 100
  static const Color brandEmeraldSurface = Color(0xFFECFDF5);

  // Backward compatibility aliases mapped to new Indigo & Emerald brand
  static const Color brandTeal = brandIndigo;
  static const Color brandTealDark = brandIndigoDark;
  static const Color brandTealLight = brandIndigoLight;
  static const Color brandMint = brandEmeraldMint;
  static const Color brandMintSurface = brandEmeraldSurface;

  static const Color primary = brandIndigo;
  static const Color primaryDark = brandIndigoDark;
  static const Color primaryLight = brandIndigoLight;
  static const Color secondary = brandEmerald;
  static const Color accent = brandEmerald;

  // Background & Canvas (Architectural Soft Off-White Mesh with subtle Indigo-Emerald tint)
  static const Color canvasMeshStart = Color(0xFFF6F8FC);
  static const Color canvasMeshMid = Color(0xFFEFF3F9);
  static const Color canvasMeshEnd = Color(0xFFEAF5EE);
  static const Color background = Color(0xFFF6F8FC);

  // Glass Surfaces & Containers
  static const Color glassSurfaceCard = Color(0xC2FFFFFF); // ~76% White
  static const Color glassSurfaceInput = Color(0xA6FFFFFF); // ~65% White
  static const Color glassSurfacePill = Color(0x94FFFFFF); // ~58% White
  static const Color glassSurfaceDock = Color(0xD9FFFFFF); // ~85% White

  // Fallbacks for standard non-glass widgets
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceCard = Colors.white;
  static const Color surfaceElevated = Colors.white;

  // Specular Borders & Outlines
  static const Color glassBorderSpecular = Color(0xE6FFFFFF); // 90% White
  static const Color glassBorderSubtle = Color(0xB3FFFFFF); // 70% White
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFCBD5E1); // Slate 300
  static const Color borderHighlight = brandIndigo;

  // Typography Colors (High-Contrast Charcoal & Slate)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF334155); // Slate 700
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textWhite = Colors.white;

  // Ambient Lighting Orbs
  static Color ambientIndigo = const Color(0xFF4F46E5).withValues(alpha: 0.20);
  static Color ambientEmerald = const Color(0xFF10B981).withValues(alpha: 0.18);
  static Color ambientTeal = ambientEmerald;
  static Color ambientSky = const Color(0xFF6366F1).withValues(alpha: 0.14);
  static Color ambientAmber = const Color(0xFFF59E0B).withValues(alpha: 0.12);

  // Semantic Status Colors (Accessibility & High Contrast Specs)
  // 1. AVAILABLE / IN_USE (Emerald)
  static const Color statusAvailable = Color(0xFF10B981);
  static const Color statusAvailableBg = Color(0xFFECFDF5);
  static const Color statusAvailableBorder = Color(0xFFA7F3D0);
  static const Color statusAvailableText = Color(0xFF065F46);

  static const Color statusInUse = Color(0xFF059669);
  static const Color statusInUseBg = Color(0xFFD1FAE5);
  static const Color statusInUseBorder = Color(0xFF34D399);
  static const Color statusInUseText = Color(0xFF064E3B);

  // 2. BOOKED / REJECTED (Rose)
  static const Color statusBooked = Color(0xFFE11D48);
  static const Color statusBookedBg = Color(0xFFFFF1F2);
  static const Color statusBookedBorder = Color(0xFFFECDD3);
  static const Color statusBookedText = Color(0xFF9F1239);
  static const Color statusRejected = statusBooked;
  static const Color statusRejectedBg = statusBookedBg;
  static const Color statusRejectedBorder = statusBookedBorder;
  static const Color statusRejectedText = statusBookedText;

  // 3. PENDING (Amber)
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusPendingBg = Color(0xFFFFFBEB);
  static const Color statusPendingBorder = Color(0xFFFDE68A);
  static const Color statusPendingText = Color(0xFF78350F);

  // 4. MAINTENANCE / CANCELLED (Cool Slate)
  static const Color statusMaintenance = Color(0xFF64748B);
  static const Color statusMaintenanceBg = Color(0xFFF8FAFC);
  static const Color statusMaintenanceBorder = Color(0xFFCBD5E1);
  static const Color statusMaintenanceText = Color(0xFF1E293B);
  static const Color statusCancelled = statusMaintenance;
  static const Color statusCancelledBg = statusMaintenanceBg;

  // 5. GHOST-BOOKING CANCELLED (Rose-Amber Alert)
  static const Color statusGhostBooking = Color(0xFFBE123C);
  static const Color statusGhostBookingBg = Color(0xFFFFF1F2);
  static const Color statusGhostBookingBorder = Color(0xFFFDA4AF);
  static const Color statusGhostBookingText = Color(0xFF881337);

  // 6. COMPLETED (Emerald)
  static const Color statusCompleted = brandEmeraldDark;
  static const Color statusCompletedBg = brandEmeraldMint;

  // Brand Gradients (Indigo to Emerald Fusion)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandIndigo, brandEmeraldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [brandIndigo, brandEmeraldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [brandIndigoDark, brandIndigo, brandEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandIndigoDark, brandIndigo],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshCanvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [canvasMeshStart, canvasMeshMid, canvasMeshEnd],
    stops: [0.0, 0.48, 1.0],
  );
}

class AppTheme {
  /// Tema utama Frosted Light Glassmorphism berbasis Plus Jakarta Sans.
  static ThemeData get frostedLightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.statusRejected,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12.5,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 11,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.statusRejected, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 20,
      ),
    );
  }

  /// Alias darkTheme mengarah ke frostedLightTheme agar transisi lancar.
  static ThemeData get darkTheme => frostedLightTheme;
}
