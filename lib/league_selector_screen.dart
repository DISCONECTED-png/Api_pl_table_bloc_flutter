import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'league_config.dart';
import 'leaguetablebloc.dart';
import 'leaguetablescreen.dart';

class LeagueSelectorScreen extends StatefulWidget {
  const LeagueSelectorScreen({super.key});

  @override
  State<LeagueSelectorScreen> createState() => _LeagueSelectorScreenState();
}

class _LeagueSelectorScreenState extends State<LeagueSelectorScreen> {
  late PageController _leaguePageController;
  late PageController _cupPageController;
  int _selectedLeagueIndex = 0;
  int _selectedCupIndex = 0;
  bool _isCupSectionActive = false;

  @override
  void initState() {
    super.initState();
    _leaguePageController = PageController(viewportFraction: 0.85);
    _cupPageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _leaguePageController.dispose();
    _cupPageController.dispose();
    super.dispose();
  }

  CompetitionInfo get _activeCompetition => _isCupSectionActive
      ? LeagueConfig.cups[_selectedCupIndex]
      : LeagueConfig.leagues[_selectedLeagueIndex];

  void _nextLeague() {
    if (_selectedLeagueIndex < LeagueConfig.leagues.length - 1) {
      _leaguePageController.animateToPage(
        _selectedLeagueIndex + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevLeague() {
    if (_selectedLeagueIndex > 0) {
      _leaguePageController.animateToPage(
        _selectedLeagueIndex - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextCup() {
    if (_selectedCupIndex < LeagueConfig.cups.length - 1) {
      _cupPageController.animateToPage(
        _selectedCupIndex + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevCup() {
    if (_selectedCupIndex > 0) {
      _cupPageController.animateToPage(
        _selectedCupIndex - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeComp = _activeCompetition;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: activeComp.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeComp.accentColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: activeComp.accentColor.withOpacity(0.25),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PITCHSIDE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: activeComp.accentColor,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Competition',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Carousels
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Domestic Leagues Section
                      _buildCarouselSection(
                        title: 'Domestic Leagues',
                        items: LeagueConfig.leagues,
                        controller: _leaguePageController,
                        currentIndex: _selectedLeagueIndex,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedLeagueIndex = index;
                            _isCupSectionActive = false;
                          });
                        },
                        onPrev: _prevLeague,
                        onNext: _nextLeague,
                      ),

                      const SizedBox(height: 28),

                      // UEFA Cups Section
                      _buildCarouselSection(
                        title: 'UEFA European Cups',
                        items: LeagueConfig.cups,
                        controller: _cupPageController,
                        currentIndex: _selectedCupIndex,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedCupIndex = index;
                            _isCupSectionActive = true;
                          });
                        },
                        onPrev: _prevCup,
                        onNext: _nextCup,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection({
    required String title,
    required List<CompetitionInfo> items,
    required PageController controller,
    required int currentIndex,
    required Function(int) onPageChanged,
    required Function() onPrev,
    required Function() onNext,
  }) {
    final activeComp = _activeCompetition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: activeComp.accentColor.withOpacity(0.85),
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 340, // Height for a cards carousel
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageView.builder(
                controller: controller,
                onPageChanged: onPageChanged,
                itemCount: items.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isCurrent = index == currentIndex;

                  return AnimatedScale(
                    scale: isCurrent ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: isCurrent ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 350),
                      child: _buildShowcaseCard(item),
                    ),
                  );
                },
              ),

              // Left Navigation Arrow
              if (currentIndex > 0)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: onPrev,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

              // Right Navigation Arrow
              if (currentIndex < items.length - 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: onNext,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Carousel dots indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (index) {
              final isCurrent = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isCurrent ? 20 : 6,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? activeComp.accentColor
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: activeComp.accentColor.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseCard(CompetitionInfo competition) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: competition.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Hero(
                    tag: 'logo_${competition.code}',
                    child: Image.network(
                      competition.logoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              competition.accentColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.sports_soccer_outlined,
                          size: 48,
                          color: competition.accentColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                competition.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Country/Type Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: competition.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: competition.accentColor.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  competition.country.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: competition.accentColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: competition.accentColor,
                    foregroundColor: competition.primaryColor == const Color(0xFFFFFFFF)
                        ? Colors.black
                        : Colors.white,
                    elevation: 3,
                    shadowColor: competition.accentColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => LeagueTableBloc()..add(FetchLeagueTable(competition.code)),
                          child: LeagueTableScreen(initialLeague: competition),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EXPLORE STANDINGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: competition.primaryColor == const Color(0xFFFFFFFF)
                              ? Colors.black87
                              : competition.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: competition.primaryColor == const Color(0xFFFFFFFF)
                            ? Colors.black87
                            : competition.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
