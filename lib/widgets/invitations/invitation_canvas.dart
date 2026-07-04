import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvitationCanvas extends StatelessWidget {
  final String title;
  final String message;
  final String dateTime;
  final String venue;
  final String address;
  final String? dressCode;
  final String rsvpDeadline;
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
    required this.rsvpDeadline,
    required this.template,
    required this.theme,
    required this.colorPalette,
    required this.fontStyle,
  });

  String get _templateLower => template.toLowerCase();
  String get _themeLower => theme.toLowerCase();
  String get _paletteLower => colorPalette.toLowerCase();
  String get _fontLower => fontStyle.toLowerCase();

  bool get _isLuxury =>
      _themeLower.contains('luxury') || _templateLower.contains('luxury');

  bool get _isFun => _themeLower.contains('fun');

  bool get _isModern =>
      _themeLower.contains('modern') || _templateLower.contains('modern');

  bool get _isFormal =>
      _themeLower.contains('formal') || _templateLower.contains('simple');

  bool get _isTraditional => _themeLower.contains('traditional');

  bool get _isDarkCard =>
      _isLuxury ||
      _templateLower.contains('bold') ||
      _templateLower.contains('celebration') ||
      _paletteLower.contains('black');

  Color get primaryColor {
    if (_paletteLower.contains('pink')) return const Color(0xFFB76E79);
    if (_paletteLower.contains('green')) return const Color(0xFF2E5E4E);
    if (_paletteLower.contains('blue')) return const Color(0xFF193B68);
    if (_paletteLower.contains('black') || _paletteLower.contains('gold')) {
      return const Color(0xFFD4AF37);
    }
    return const Color(0xFFD4AF37);
  }

  Color get accentColor {
    if (_paletteLower.contains('pink')) return const Color(0xFFF4B6C2);
    if (_paletteLower.contains('green')) return const Color(0xFF8BAE91);
    if (_paletteLower.contains('blue')) return const Color(0xFF8EA9C8);
    return const Color(0xFFFFD77A);
  }

  Color get backgroundColor {
    if (_isLuxury || _paletteLower.contains('black')) {
      return const Color(0xFF050B18);
    }
    if (_paletteLower.contains('pink')) return const Color(0xFFFFF0F4);
    if (_paletteLower.contains('green')) return const Color(0xFFEDF6EF);
    if (_paletteLower.contains('blue')) return const Color(0xFFF2F7FF);
    return const Color(0xFFFFFCF2);
  }

  Color get secondaryColor {
    if (_isLuxury || _paletteLower.contains('black')) {
      return const Color(0xFF1A1405);
    }
    if (_paletteLower.contains('pink')) return const Color(0xFFF9DDE5);
    if (_paletteLower.contains('green')) return const Color(0xFFE0EFE4);
    if (_paletteLower.contains('blue')) return const Color(0xFFEAF1FA);
    return const Color(0xFFFFF3D0);
  }

  Color get textColor {
    if (_isDarkCard) return Colors.white;
    if (_paletteLower.contains('green')) return const Color(0xFF18392F);
    if (_paletteLower.contains('pink')) return const Color(0xFF5C2935);
    if (_paletteLower.contains('blue')) return const Color(0xFF14213D);
    return const Color(0xFF222222);
  }

  TextStyle get titleStyle {
    if (_fontLower.contains('script')) {
      return GoogleFonts.greatVibes(
        color: textColor,
        fontSize: 44,
        height: 1.05,
      );
    }

    if (_fontLower.contains('serif')) {
      return GoogleFonts.playfairDisplay(
        color: textColor,
        fontSize: 33,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );
    }

    if (_fontLower.contains('bold')) {
      return GoogleFonts.oswald(
        color: textColor,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );
    }

    if (_fontLower.contains('sans')) {
      return GoogleFonts.poppins(
        color: textColor,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );
    }

    return GoogleFonts.montserrat(
      color: textColor,
      fontSize: 31,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
  }

  TextStyle get bodyStyle {
    return GoogleFonts.poppins(
      color: textColor.withOpacity(0.84),
      fontSize: 14,
      height: 1.5,
    );
  }

  TextStyle get smallHeadingStyle {
    return GoogleFonts.poppins(
      color: primaryColor,
      fontSize: 11,
      letterSpacing: _isFun ? 2 : 3,
      fontWeight: FontWeight.bold,
    );
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

  String _eventTypeSubtitle() {
    if (_themeLower.contains('wedding')) return 'WEDDING CELEBRATION';
    if (_themeLower.contains('birthday')) return 'BIRTHDAY CELEBRATION';
    if (_themeLower.contains('graduation')) return 'GRADUATION CELEBRATION';
    if (_themeLower.contains('formal')) return 'FORMAL CELEBRATION';
    return 'SPECIAL CELEBRATION';
  }

  Widget _heartDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: primaryColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.favorite, color: primaryColor, size: 20),
        ),
        Expanded(child: Divider(color: primaryColor)),
      ],
    );
  }

  Widget _elegantInfoColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _elegantInfoBlock(
            icon: Icons.calendar_month,
            label: 'DATE / TIME',
            lines: _formatDateTime(dateTime),
          ),
        ),
        _elegantVerticalDivider(),
        Expanded(
          child: _elegantInfoBlock(
            icon: Icons.location_city,
            label: 'VENUE',
            lines: [venue],
          ),
        ),
        _elegantVerticalDivider(),
        Expanded(
          child: _elegantInfoBlock(
            icon: Icons.location_on,
            label: 'VENUE ADDRESS',
            lines: _splitAddress(address),
          ),
        ),
        _elegantVerticalDivider(),
        Expanded(
          child: _elegantInfoBlock(
            icon: Icons.checkroom,
            label: 'DRESS CODE',
            lines: [
              if (dressCode != null && dressCode!.isNotEmpty)
                dressCode!
              else
                'Not specified',
            ],
          ),
        ),
      ],
    );
  }

  Widget _elegantInfoBlock({
    required IconData icon,
    required String label,
    required List<String> lines,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B1E2D), size: 34),
        const SizedBox(height: 16),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF8B1E2D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: const Color(0xFF222222),
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _elegantVerticalDivider() {
    return Container(
      width: 1.4,
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFC28A2E),
    );
  }

  List<String> _formatDateTime(String value) {
    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'JANUARY',
        'FEBRUARY',
        'MARCH',
        'APRIL',
        'MAY',
        'JUNE',
        'JULY',
        'AUGUST',
        'SEPTEMBER',
        'OCTOBER',
        'NOVEMBER',
        'DECEMBER',
      ];

      const days = [
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY',
        'SUNDAY',
      ];

      final hour = date.hour > 12
          ? date.hour - 12
          : date.hour == 0
          ? 12
          : date.hour;

      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return [
        '${date.day} ${months[date.month - 1]} ${date.year}',
        days[date.weekday - 1],
        '$hour:$minute $period',
      ];
    } catch (_) {
      return [value];
    }
  }

  String _formatDateOnly(String value) {
    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'JANUARY',
        'FEBRUARY',
        'MARCH',
        'APRIL',
        'MAY',
        'JUNE',
        'JULY',
        'AUGUST',
        'SEPTEMBER',
        'OCTOBER',
        'NOVEMBER',
        'DECEMBER',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value;
    }
  }

  List<String> _splitAddress(String value) {
    final parts = value.split(',');

    if (parts.length >= 2) {
      return [parts.first.trim(), parts.sublist(1).join(',').trim()];
    }

    return [value];
  }

  Widget _elegantClassic() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 1024,
          height: 1536,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/invitations/elegant_classic/elegant_classic_portrait.png',
                  fit: BoxFit.cover,
                ),
              ),

              // ONLY this moves "YOU'RE INVITED TO"
              Positioned(
                top: 200,
                left: 150,
                right: 150,
                child: Text(
                  "YOU'RE INVITED TO",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFF8B1E2D),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // This controls title, subtitle, and message
              Positioned(
                top: 355,
                left: 150,
                right: 150,
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.greatVibes(
                        color: const Color(0xFF8B1E2D),
                        fontSize: 82,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _eventTypeSubtitle(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFC28A2E),
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 58),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFF333333),
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 850,
                left: 92,
                right: 92,
                child: _elegantInfoColumns(),
              ),

              Positioned(
                bottom: 170,
                left: 170,
                right: 170,
                child: Column(
                  children: [
                    Text(
                      'RSVP BY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFF8B1E2D),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDateOnly(rsvpDeadline),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFC28A2E),
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernMinimal() {
    return _outerCard(
      radius: 18,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(height: 5, width: 95, color: primaryColor),
          ),
          const SizedBox(height: 22),
          Text('MODERN INVITATION', style: smallHeadingStyle),
          const SizedBox(height: 18),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: bodyStyle),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: primaryColor.withOpacity(0.5)),
                bottom: BorderSide(color: primaryColor.withOpacity(0.5)),
              ),
            ),
            child: _threeInfoColumns(),
          ),
          const SizedBox(height: 18),
          _rsvpBar('RSVP CONFIRMATION'),
        ],
      ),
    );
  }

  Widget _boldCelebration() {
    return _outerCard(
      forceDark: true,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _partyCorner()),
          Positioned(bottom: 0, right: 0, child: _partyCorner()),
          Column(
            children: [
              const SizedBox(height: 24),
              _funIcons(),
              const SizedBox(height: 14),
              Text("YOU'RE INVITED TO", style: smallHeadingStyle),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: titleStyle),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryColor),
                ),
                child: Text(
                  "LET'S CELEBRATE!",
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: bodyStyle),
              const SizedBox(height: 24),
              _darkInfoPanel(),
              const SizedBox(height: 16),
              _dressCodeLine(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _luxuryGold() {
    return _outerCard(
      forceDark: true,
      radius: 24,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _goldCorner()),
          Positioned(top: 0, right: 0, child: _goldCorner()),
          Positioned(bottom: 0, left: 0, child: _goldCorner()),
          Positioned(bottom: 0, right: 0, child: _goldCorner()),
          Column(
            children: [
              const SizedBox(height: 22),
              Icon(Icons.diamond_outlined, color: primaryColor, size: 38),
              const SizedBox(height: 14),
              Text('LUXURY INVITATION', style: smallHeadingStyle),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: titleStyle),
              const SizedBox(height: 18),
              _goldFrame(child: _threeInfoColumns(forceLight: true)),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center, style: bodyStyle),
              const SizedBox(height: 18),
              _rsvpBar('RSVP CONFIRMATION', dark: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleFormal() {
    return _outerCard(
      radius: 12,
      child: Column(
        children: [
          _formalBorderHeader(),
          const SizedBox(height: 18),
          Text('YOU ARE CORDIALLY INVITED TO', style: smallHeadingStyle),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: titleStyle),
          const SizedBox(height: 20),
          Divider(color: primaryColor),
          const SizedBox(height: 16),
          _threeInfoColumns(),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center, style: bodyStyle),
          const SizedBox(height: 18),
          _rsvpBar('KINDLY RSVP'),
        ],
      ),
    );
  }

  Widget _outerCard({
    required Widget child,
    bool forceDark = false,
    double radius = 24,
  }) {
    final dark = forceDark || _isDarkCard;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF050B18), const Color(0xFF1A1405)]
              : [backgroundColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: primaryColor, width: dark ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _threeInfoColumns({bool forceLight = false}) {
    final color = forceLight || _isDarkCard ? Colors.white : textColor;

    return Row(
      children: [
        Expanded(
          child: _infoBlock(Icons.calendar_month, 'DATE/TIME', dateTime, color),
        ),
        _verticalDivider(),
        Expanded(child: _infoBlock(Icons.location_city, 'VENUE', venue, color)),
        _verticalDivider(),
        Expanded(
          child: _infoBlock(Icons.location_on, 'ADDRESS', address, color),
        ),
      ],
    );
  }

  Widget _infoBlock(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 22),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _darkInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.7)),
      ),
      child: _threeInfoColumns(forceLight: true),
    );
  }

  Widget _goldFrame({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.18),
      ),
      child: child,
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 70,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: primaryColor.withOpacity(0.5),
    );
  }

  Widget _rsvpBar(String text, {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? primaryColor : textColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: dark ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _dressCodeLine() {
    if (dressCode == null || dressCode!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      'Dress Code: $dressCode',
      textAlign: TextAlign.center,
      style: GoogleFonts.playfairDisplay(
        color: primaryColor,
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _ornamentDivider() {
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

  Widget _floralCorner() {
    return Opacity(
      opacity: 0.25,
      child: Column(
        children: [
          Icon(Icons.local_florist, color: textColor, size: 42),
          Icon(Icons.eco, color: primaryColor, size: 26),
        ],
      ),
    );
  }

  Widget _partyCorner() {
    return Opacity(
      opacity: 0.75,
      child: Column(
        children: [
          Icon(Icons.celebration, color: primaryColor, size: 32),
          const SizedBox(height: 8),
          Icon(Icons.star, color: accentColor, size: 18),
          const SizedBox(height: 8),
          Icon(Icons.circle, color: primaryColor, size: 8),
        ],
      ),
    );
  }

  Widget _goldCorner() {
    return Opacity(
      opacity: 0.75,
      child: Icon(Icons.auto_awesome, color: primaryColor, size: 26),
    );
  }

  Widget _funIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.celebration, color: primaryColor, size: 30),
        const SizedBox(width: 12),
        Icon(Icons.cake, color: accentColor, size: 28),
        const SizedBox(width: 12),
        Icon(Icons.star, color: primaryColor, size: 26),
      ],
    );
  }

  Widget _formalBorderHeader() {
    return Row(
      children: [
        Expanded(child: Divider(color: primaryColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.account_balance, color: primaryColor, size: 22),
        ),
        Expanded(child: Divider(color: primaryColor)),
      ],
    );
  }
}
