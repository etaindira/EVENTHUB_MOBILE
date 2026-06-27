import 'package:flutter/material.dart';

class InvitationCanvas extends StatelessWidget {
  final String title;
  final String message;
  final String dateTime;
  final String venue;
  final String address;
  final String? dressCode;
  final String template;
  final String theme;
  final String colorPalette;
  final String fontStyle;

  const InvitationCanvas({
    super.key,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.venue,
    required this.address,
    this.dressCode,
    required this.template,
    required this.theme,
    required this.colorPalette,
    required this.fontStyle,
  });

  String get _templateLower => template.toLowerCase();
  String get _themeLower => theme.toLowerCase();
  String get _paletteLower => colorPalette.toLowerCase();
  String get _fontLower => fontStyle.toLowerCase();

  Color get primaryColor {
    if (_paletteLower.contains('pink')) return const Color(0xFFB76E79);
    if (_paletteLower.contains('black') || _paletteLower.contains('gold')) {
      return const Color(0xFFD4AF37);
    }
    if (_paletteLower.contains('green')) return const Color(0xFF2E5E4E);
    if (_paletteLower.contains('blue')) return const Color(0xFF193B68);
    return const Color(0xFFD4AF37);
  }

  Color get secondaryColor {
    if (_paletteLower.contains('pink')) return const Color(0xFFF9E1E7);
    if (_paletteLower.contains('black')) return const Color(0xFF050B18);
    if (_paletteLower.contains('green')) return const Color(0xFFE8F1EA);
    if (_paletteLower.contains('blue')) return const Color(0xFFEAF1FA);
    if (_paletteLower.contains('gold')) return const Color(0xFFFFF7DB);
    return const Color(0xFFFAF7F0);
  }

  Color get backgroundColor {
    if (_paletteLower.contains('black')) return const Color(0xFF050B18);
    if (_paletteLower.contains('green')) return const Color(0xFFEDF6EF);
    if (_paletteLower.contains('pink')) return const Color(0xFFFFF0F4);
    if (_paletteLower.contains('blue')) return const Color(0xFFF2F7FF);
    return const Color(0xFFFFFCF2);
  }

  Color get darkTextColor {
    if (_paletteLower.contains('green')) return const Color(0xFF18392F);
    if (_paletteLower.contains('pink')) return const Color(0xFF5C2935);
    if (_paletteLower.contains('blue')) return const Color(0xFF14213D);
    return const Color(0xFF222222);
  }

  bool get isDarkCard {
    return _templateLower.contains('bold') ||
        _templateLower.contains('celebration') ||
        _templateLower.contains('luxury') ||
        _paletteLower.contains('black');
  }

  FontWeight get titleWeight {
    if (_fontLower.contains('bold')) return FontWeight.w900;
    if (_fontLower.contains('serif')) return FontWeight.w700;
    if (_fontLower.contains('script')) return FontWeight.w500;
    return FontWeight.bold;
  }

  double get titleSize {
    if (_fontLower.contains('script')) return 36;
    if (_fontLower.contains('bold')) return 32;
    if (_fontLower.contains('serif')) return 31;
    return 29;
  }

  FontStyle get dressCodeFontStyle {
    if (_fontLower.contains('script') || _fontLower.contains('serif')) {
      return FontStyle.italic;
    }
    return FontStyle.normal;
  }

  @override
  Widget build(BuildContext context) {
    if (_templateLower.contains('modern')) return _modernMinimal();

    if (_templateLower.contains('bold') ||
        _templateLower.contains('celebration')) {
      return _boldCelebration();
    }

    if (_templateLower.contains('luxury')) return _luxuryGold();

    if (_templateLower.contains('simple')) return _simpleFormal();

    return _elegantClassic();
  }

  Widget _elegantClassic() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Stack(
        children: [
          if (_shouldShowFlowers)
            Positioned(top: 6, left: 6, child: _flowerCorner()),
          if (_shouldShowFlowers)
            Positioned(bottom: 6, right: 6, child: _flowerCorner()),
          Column(
            children: [
              const SizedBox(height: 28),
              _smallHeading("YOU'RE INVITED TO", primaryColor),
              const SizedBox(height: 18),
              _titleText(darkTextColor),
              const SizedBox(height: 18),
              _divider(),
              const SizedBox(height: 18),
              _messageText(darkTextColor.withOpacity(0.82)),
              const SizedBox(height: 22),
              _eventInfoDarkText(),
              _dressCodeText(primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernMinimal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
      child: Column(
        children: [
          Container(height: 4, width: 80, color: primaryColor),
          const SizedBox(height: 24),
          _smallHeading('INVITATION', primaryColor),
          const SizedBox(height: 18),
          _titleText(darkTextColor),
          const SizedBox(height: 20),
          _messageText(darkTextColor.withOpacity(0.82)),
          const SizedBox(height: 24),
          _eventInfoDarkText(),
          _dressCodeText(primaryColor),
        ],
      ),
    );
  }

  Widget _boldCelebration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkCard ? const Color(0xFF050B18) : backgroundColor,
            isDarkCard ? const Color(0xFF10203D) : secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor, width: 1.8),
      ),
      child: Stack(
        children: [
          Positioned(top: 8, left: 8, child: _sparkles()),
          Positioned(bottom: 8, right: 8, child: _sparkles()),
          Column(
            children: [
              const SizedBox(height: 18),
              _smallHeading("YOU'RE INVITED TO", primaryColor),
              const SizedBox(height: 18),
              _titleText(Colors.white),
              const SizedBox(height: 18),
              _messageText(const Color(0xFFE6E6E6)),
              const SizedBox(height: 24),
              _eventInfoLightText(),
              _dressCodeText(primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _luxuryGold() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF070707), Color(0xFF1A1405)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: 8, left: 8, child: _sparkles()),
          Positioned(bottom: 8, right: 8, child: _sparkles()),
          Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.diamond_outlined, color: primaryColor, size: 34),
              const SizedBox(height: 14),
              _smallHeading("YOU'RE INVITED TO", primaryColor),
              const SizedBox(height: 18),
              _titleText(Colors.white),
              const SizedBox(height: 18),
              _divider(),
              const SizedBox(height: 18),
              _messageText(const Color(0xFFEDEDED)),
              const SizedBox(height: 24),
              _eventInfoLightText(),
              _dressCodeText(primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleFormal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor, width: 1.4),
      ),
      child: Column(
        children: [
          _smallHeading('FORMAL INVITATION', primaryColor),
          const SizedBox(height: 20),
          _titleText(darkTextColor),
          const SizedBox(height: 20),
          _divider(),
          const SizedBox(height: 20),
          _messageText(darkTextColor.withOpacity(0.84)),
          const SizedBox(height: 24),
          _eventInfoDarkText(),
          _dressCodeText(primaryColor),
        ],
      ),
    );
  }

  bool get _shouldShowFlowers {
    return _themeLower.contains('elegant') ||
        _themeLower.contains('traditional') ||
        _paletteLower.contains('pink') ||
        _paletteLower.contains('green');
  }

  Widget _smallHeading(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 12,
        letterSpacing: _fontLower.contains('bold') ? 2 : 3,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _titleText(Color color) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: titleSize,
        fontWeight: titleWeight,
        height: 1.1,
        letterSpacing: _fontLower.contains('script') ? 0.5 : 0,
        fontStyle: _fontLower.contains('script')
            ? FontStyle.italic
            : FontStyle.normal,
      ),
    );
  }

  Widget _messageText(Color color) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 15,
        height: 1.5,
        fontWeight: _fontLower.contains('bold')
            ? FontWeight.w600
            : FontWeight.normal,
      ),
    );
  }

  Widget _dressCodeText(Color color) {
    if (dressCode == null || dressCode!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 18),
        Text(
          'Dress Code: $dressCode',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontStyle: dressCodeFontStyle,
            fontWeight: _fontLower.contains('bold')
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _eventInfoDarkText() {
    return Column(
      children: [
        _infoRow(Icons.calendar_month, dateTime, darkTextColor),
        const SizedBox(height: 10),
        _infoRow(Icons.location_city, venue, darkTextColor),
        const SizedBox(height: 10),
        _infoRow(Icons.location_on, address, darkTextColor),
      ],
    );
  }

  Widget _eventInfoLightText() {
    return Column(
      children: [
        _infoRow(Icons.calendar_month, dateTime, Colors.white),
        const SizedBox(height: 10),
        _infoRow(Icons.location_city, venue, Colors.white),
        const SizedBox(height: 10),
        _infoRow(Icons.location_on, address, Colors.white),
      ],
    );
  }

  Widget _infoRow(IconData icon, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Divider(color: primaryColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.auto_awesome, color: primaryColor, size: 18),
        ),
        Expanded(child: Divider(color: primaryColor)),
      ],
    );
  }

  Widget _flowerCorner() {
    return Opacity(
      opacity: 0.28,
      child: Column(
        children: [
          Icon(Icons.local_florist, color: darkTextColor, size: 44),
          Icon(Icons.eco, color: primaryColor, size: 28),
        ],
      ),
    );
  }

  Widget _sparkles() {
    return Opacity(
      opacity: 0.5,
      child: Column(
        children: [
          Icon(Icons.star, color: primaryColor, size: 18),
          const SizedBox(height: 8),
          Icon(Icons.auto_awesome, color: primaryColor, size: 24),
          const SizedBox(height: 8),
          Icon(Icons.circle, color: primaryColor, size: 8),
        ],
      ),
    );
  }
}
