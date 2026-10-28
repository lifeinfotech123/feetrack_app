import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = const Color(0xFF0052D9);
Color secondaryColor = const Color(0xFF0D9488);
Color backgroundDark = const Color(0xff231F20);
Color backgroundLight = const Color(0xFFFCF8F8);


const Color black = Colors.black;

//* white Colors
Color white = Colors.white;
Color whiteSmoke = const Color(0xFFF5ECED);

//* Blue Colors
Color blueDark = const Color(0xFF00338F);
Color blueLight = const Color(0xFF89F5E7);
Color blueLight1 = const Color(0xFF87F2E4);
Color blueLight2 = const Color(0xFF003B730D);
Color blueLight4 = const Color(0xFF86F2E4);
Color blueLight3 = const Color(0xFF003DA6);
Color blueLight5 = const Color(0xFFDBE1FF);
Color blueLight6 = const Color(0xFFCBD6FF);

//* purple Colors
Color purpleLight = const Color(0xFFEADDFF);
Color purple = const Color(0xFF484AD6);

//* Grey Colors
Color grey = const Color(0xFF999999);
Color greyLight = const Color(0xFFF6F3F2);
Color greyLight1 = const Color(0xFFC3C6D766);
Color greyLight2 = const Color(0xFFC3C6D1);
Color greyLight4 = const Color(0xFFC3C6D1);
Color greyLight5 = const Color(0xFFEFE6E7);
Color greyLight6 = const Color(0xFFC3C6D7);
Color greyLight7 = const Color(0xFFE1D8D9);
Color greyLight8 = const Color(0xFFC3C6D74D);
Color greyLight9 = const Color(0xFFF0EDEC);
Color greyDart = const Color(0xFF73777F);
Color greyDart2 = const Color(0xFF434654);
Color greyLight3 = const Color(0xFFEBE7E7);

//* pink color
Color pinLight = const Color(0xFFFBF1F2);

//* Green colors
const Color greenDark = Color(0xFF006A61);

//* Yellow colors
const Color goldColor = Color(0xFFFFB400);

//* red colorsp
const Color red = Colors.red;
const Color red1 = Color(0xFFE11D48);
const Color redLight = Color(0xFFFFF1F2);
const Color redLight2 = Color(0xFFFFDAD6);
const Color redDark = Color(0xFFBA1A1A);

//* Textbox colors
Color textBox = Colors.grey.withValues(alpha: 0.30);
const Color textBlue = Color(0xff003B73);

//* Text Colors
Color greyText = const Color(0xFF43474E);
Color greyText2 = const Color(0xFF434750);
Color greyText3 = const Color(0xFF737781);
Color greyText4 = const Color(0xFFE5E2E1);
Color greyText5 = const Color(0xFF737686);
Color primaryText80 = const Color(0xFF003B73CC);
Color primaryText1 = const Color(0xFF002060);
Color primaryText2 = const Color(0xFF1E3A8A);
Color redText = const Color(0xFF93000A);

Color transactionDetailsPrimary = const Color(0xFF001A3F);
Color transactionDetailsAccent = const Color(0xFF4DFFD3);
Color transactionDetailsBackground = const Color(0xFFF8F9FA);
Color transactionSuccessText = const Color(0xFF0D6B57);
Color transactionSuccessBackground = const Color(0xFFE7FFF8);
Color transactionPendingBackground = const Color(0xFFFFF4E5);
Color transactionPendingText = const Color(0xFFB26A00);
Color transactionPendingAccent = const Color(0xFFF59E0B);
Color blackText1 = const Color(0xFF1C1B1B);
Color blackText2 = const Color(0xFF171717);
Color blackText3 = const Color(0xFF1E1B1C);
Color purpleText = const Color(0xFF25005A);
Color purpleText1 = const Color(0xFF310072);

const Color textPrimary = Color(0xff000000);
const Color textSecondary = Color(0xff838383);
Map<int, Color> color = const {
  50: Color.fromRGBO(255, 244, 149, .1),
  100: Color.fromRGBO(255, 244, 149, .2),
  200: Color.fromRGBO(255, 244, 149, .3),
  300: Color.fromRGBO(255, 244, 149, .4),
  400: Color.fromRGBO(255, 244, 149, .5),
  500: Color.fromRGBO(255, 244, 149, .6),
  600: Color.fromRGBO(255, 244, 149, .7),
  700: Color.fromRGBO(255, 244, 149, .8),
  800: Color.fromRGBO(255, 244, 149, .9),
  900: Color.fromRGBO(255, 244, 149, 1),
};
MaterialColor colorCustom = MaterialColor(0XFFFFF495, color);

class CustomTheme {
  static ThemeData light = ThemeData(
    fontFamily: "Montserrat",
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundLight,
    hintColor: Colors.grey[700],
    primarySwatch: colorCustom,
    canvasColor: secondaryColor,
    primaryColorLight: secondaryColor,
    splashColor: secondaryColor,
    shadowColor: Colors.grey[600],
    cardColor: Colors.grey[100],
    primaryColor: primaryColor,
    dividerColor: Colors.grey[600],
    primaryColorDark: Colors.black,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      error: const Color(0xFFCF6679),
      onError: const Color(0xFFCF6679),
      background: backgroundLight,
      onBackground: Colors.black,
      surface: backgroundLight,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      actionsIconTheme: IconThemeData(
        color: black,
      ),
      iconTheme: IconThemeData(
        color: black,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: primaryColor,
        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    ),
    typography: Typography.material2021(),
    textTheme: TextTheme(
      // Buttons / labels
      labelLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w500,
        color: textSecondary,
        fontSize: 14,
      ),

      // Large headings (screen titles)
      headlineLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w800,
      ),

      headlineMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
      ),

      headlineSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
      ),

      // Big display text / hero banners
      displayLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w800,
      ),

      displayMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
      ),

      displaySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
      ),

      // AppBar / section titles
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w800,
      ),

      titleMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
      ),

      titleSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
      ),

      // Main app content
      bodyLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
      ),

      bodyMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
      ),

      bodySmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w400,
      ),
    ),
  );
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundDark,
    hintColor: Colors.grey[700],
    primarySwatch: colorCustom,
    canvasColor: secondaryColor,
    primaryColorLight: secondaryColor,
    splashColor: secondaryColor,
    shadowColor: Colors.black45,
    cardColor: Colors.grey[800],
    primaryColor: primaryColor,
    dividerColor: Colors.grey[200],
    primaryColorDark: Colors.white,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      error: const Color(0xFFCF6679),
      onError: const Color(0xFFCF6679),
      background: backgroundDark,
      onBackground: Colors.white,
      surface: backgroundDark,
      onSurface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      actionsIconTheme: IconThemeData(
        color: backgroundLight,
      ),
      iconTheme: IconThemeData(
        color: backgroundLight,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: primaryColor,
        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    ),
    typography: Typography.material2021(),
    textTheme: TextTheme(
      labelLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w400,
        color: textSecondary,
        fontSize: 14.0,
      ),
      headlineLarge: GoogleFonts.openSans(),
      headlineMedium: GoogleFonts.openSans(),
      headlineSmall: GoogleFonts.openSans(),
      displayLarge: GoogleFonts.openSans(),
      displayMedium: GoogleFonts.openSans(),
      displaySmall: GoogleFonts.openSans(),
      titleLarge: GoogleFonts.openSans(),
      titleMedium: GoogleFonts.openSans(),
      titleSmall: GoogleFonts.openSans(),
      bodyLarge: GoogleFonts.openSans(),
      bodyMedium: GoogleFonts.openSans(),
      bodySmall: GoogleFonts.openSans(),
    ),
  );
}
