import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EOTCSpiritualApp());
}

// ==========================================
// 1. ሞዴሎች (DATA MODELS)
// ==========================================

class Mezmur {
  final String id;
  final String title;
  final String singer; // ዘማሪ / መዘምራን
  final String audioUrl;
  final String coverUrl;
  final String category; // ለምሳሌ፡ የቅዱስ ገብርኤል፣ የእመቤታችን፣ የበዓላት
  final String lyrics; // የመዝሙሩ ግጥም
  bool isFavorite;
  bool isDownloaded;

  Mezmur({
    required this.id,
    required this.title,
    required this.singer,
    required this.audioUrl,
    required this.coverUrl,
    required this.category,
    required this.lyrics,
    this.isFavorite = false,
    this.isDownloaded = false,
  });
}

class SpiritualPoem {
  final String id;
  final String title;
  final String author;
  final String content;
  final String category;
  final String? audioRecitationUrl;
  bool isFavorite;

  SpiritualPoem({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.category,
    this.audioRecitationUrl,
    this.isFavorite = false,
  });
}

// ==========================================
// 2. የአፕሊኬሽኑ ሁኔታ መቆጣጠሪያ (APP STATE)
// ==========================================

class AppState extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Mezmur? _currentMezmur;
  SpiritualPoem? _currentPoemAudio;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // የመዝሙራት ዝርዝር (ናሙና የቅዱስ ገብርኤልና ሌሎች መዝሙራት)
  final List<Mezmur> _mezmurs = [
    Mezmur(
      id: 'm1',
      title: 'ገብርኤል ኃያል መልአከ ሰላም',
      singer: 'ፈለገ ጥበብ ሰ/ት/ቤት መዘምራን',
      category: 'የቅዱስ ገብርኤል',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1548625361-195fe578491c?w=500',
      lyrics: '''ገብርኤል ኃያል መልአከ ሰላም
የታመንክ አገልጋይ ለሕዝብህ ሁሉ
በእሳቱ ባሕር ውስጥ ጥላ የሆንከው
ታደገን ከክፉው ከሚነደው እሳት።

አዝ፦ ገብርኤል ስልህ ይሰማኛል ሰላም
በአማላጅነትህ ታድነናለህ ዘላለም።

በሠለስቱ ደቂቅ በናቡከደነፆር
የታየህ ኃያል በታላቁ ክብር
ዛሬም ከጭንቀታችን ፈጥነህ አድነን
የልባችንን ሐዘን በደስታ ቀይረን።''',
    ),
    Mezmur(
      id: 'm2',
      title: 'ደስ ይበለን በደብረ ጽጌ',
      singer: 'የሰንበት ት/ቤቱ ያሬዳዊ ክፍል',
      category: 'የደብረ ጽጌ',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1509021436665-8f07dbf5bf1d?w=500',
      lyrics: '''ደስ ይበለን በደብረ ጽጌ ቆመን
የእግዚአብሔርን ስም በዝማሬ ጠርተን
ቅዱስ ገብርኤል ጠባቂያችን ነውና
ይድረሰው ምስጋና ይድረሰው ዜማ።

አዝ፦ የወይቦ ምድር ዛሬ ታበራለች
በመልአኩ ጥበቃ ተከባ ትኖራለች።''',
    ),
    Mezmur(
      id: 'm3',
      title: 'እመ አምላክ ድንግል ማርያም',
      singer: 'ፈለገ ጥበብ ሰ/ት/ቤት መዘምራን',
      category: 'የእመቤታችን',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      coverUrl: 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=500',
      lyrics: '''እመ አምላክ ድንግል ማርያም እናታችን
ላንቺ ይገባሻል ዘወትር ምስጋናችን
ከልጅሽ አማልጅን ከወዳጅሽ
ይብዛልን ምህረት ከአምላካችን።''',
    ),
  ];

  // የመንፈሳዊ ግጥሞች ዝርዝር
  final List<SpiritualPoem> _poems = [
    SpiritualPoem(
      id: 'p1',
      title: 'የወይቦው ታዳጊ',
      author: 'ዲ/ን ተስፋዬ (ፈለገ ጥበብ ሰ/ት/ቤት)',
      category: 'የቅዱስ ገብርኤል',
      audioRecitationUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      content: '''በወይቦ ደብረ ጽጌ ክብርህ የታየው
የምእመናን አባት ገብርኤል ኃያል ነው
እሳቱን አብርደህ ለሕዝብህ ጥላ የሆንክ
ለደከመው ብርታት ለታመመው ጤና የሰጠህ
ስምህን የጠራ መቼ አፍሮ ያውቃል
የአምላኬ መልአክ ፈጥኖ ይደርስልናል።''',
    ),
    SpiritualPoem(
      id: 'p2',
      title: 'የሰንበት ትምህርት ቤቴ ውበት',
      author: 'ከፈለገ ጥበብ አባላት',
      category: 'የሰንበት ት/ቤት',
      audioRecitationUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      content: '''ፈለገ ጥበብ የሕይወቴ መመሪያ
የነፍሴ ማረፊያ የእውነት መገኛ
ያሬዳዊ ዜማን የተማርኩብሽ
ኦርቶዶክሳዊነትን ያወቅሁብሽ
እግዚአብሔር ያክብርሽ ሰንበት ትምህርት ቤቴ
ላንቺ ይሁን ሁሌ አገልግሎቴ።''',
    ),
  ];

  List<Mezmur> get mezmurs => _mezmurs;
  List<SpiritualPoem> get poems => _poems;
  Mezmur? get currentMezmur => _currentMezmur;
  SpiritualPoem? get currentPoemAudio => _currentPoemAudio;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AppState() {
    _initAudio();
  }

  void _initAudio() {
    _player.onPositionChanged.listen((p) {
      _currentPosition = p;
      notifyListeners();
    });
    _player.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });
    _player.onPlayerStateChanged.listen((s) {
      _isPlaying = s == PlayerState.playing;
      notifyListeners();
    });
  }

  Future<void> playMezmur(Mezmur mezmur) async {
    _currentPoemAudio = null;
    _currentMezmur = mezmur;
    await _player.stop();
    await _player.play(UrlSource(mezmur.audioUrl));
    notifyListeners();
  }

  Future<void> playPoemAudio(SpiritualPoem poem) async {
    if (poem.audioRecitationUrl == null) return;
    _currentMezmur = null;
    _currentPoemAudio = poem;
    await _player.stop();
    await _player.play(UrlSource(poem.audioRecitationUrl!));
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration pos) async => await _player.seek(pos);

  void toggleFavorite(Mezmur m) {
    m.isFavorite = !m.isFavorite;
    notifyListeners();
  }

  void togglePoemFavorite(SpiritualPoem p) {
    p.isFavorite = !p.isFavorite;
    notifyListeners();
  }

  void toggleDownload(Mezmur m) {
    m.isDownloaded = !m.isDownloaded;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class StateScope extends InheritedNotifier<AppState> {
  const StateScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StateScope>()!.notifier!;
  }
}

// ==========================================
// 3. ዋናው አፕሊኬሽንና ገጽታ (THEME & SHELL)
// ==========================================

class EOTCSpiritualApp extends StatefulWidget {
  const EOTCSpiritualApp({super.key});

  @override
  State<EOTCSpiritualApp> createState() => _EOTCSpiritualAppState();
}

class _EOTCSpiritualAppState extends State<EOTCSpiritualApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateScope(
      state: _state,
      child: MaterialApp(
        title: 'ፈለገ ጥበብ መዝሙር',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0C0E), // ጥቁር ወይንጠጅ ዳራ
          primaryColor: const Color(0xFFD4AF37), // ክቡር ወርቃማ ቀለም
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Color(0xFF991B1B), // ጥልቅ የቤተክርስቲያን ቀይ
            surface: Color(0xFF1B1417),
          ),
          textTheme: GoogleFonts.notoSansEthiopicTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B1417),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
          ),
        ),
        home: const AppShellScreen(),
      ),
    );
  }
}

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _tabIndex = 0;

  final List<Widget> _pages = const [
    MezmurCatalogScreen(),
    PoemsCatalogScreen(),
    UserLibraryScreen(),
    MoreMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);
    final hasActiveAudio = state.currentMezmur != null || state.currentPoemAudio != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ፈለገ ጥበብ ሰ/ት/ቤት',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
            ),
            Text(
              'ወ/ሀ/ስ/ ቦ/ሶሬ/ወ/ቤ/ክ የወይቦ ደብረ ጽጌ ቅ/ገብርኤል ቤ/ክ',
              style: TextStyle(fontSize: 10, color: Color(0xFFD1D5DB)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'መተግበሪያውን ያጋሩ',
            onPressed: () => _shareAppDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _tabIndex, children: _pages),
          if (hasActiveAudio)
            const Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SpiritualMiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2E2429), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (idx) => setState(() => _tabIndex = idx),
          backgroundColor: const Color(0xFF161013),
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: const Color(0xFF9CA3AF),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.queue_music_rounded), label: 'መዝሙራት'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: 'ግጥሞች'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'የእኔ ማህደር'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'ተጨማሪ'),
          ],
        ),
      ),
    );
  }

  void _shareAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1417),
        title: const Text('መተግበሪያውን ለወዳጅዎ ያጋሩ', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Text(
          'የወይቦ ደብረ ጽጌ ቅ/ገብርኤል ቤ/ክ የፈለገ ጥበብ ሰ/ት/ቤት መዝሙራትና ግጥሞች መተግበሪያን ለኦርቶዶክሳውያን ወንድም እህቶች በማጋራት የበረከቱ ተካፋይ ያድርጓቸው።',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ዝጋ')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('ሊንኩን ቅዳ'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('የመተግበሪያው ማውረጃ ሊንክ ተቀድቷል! ለወዳጅዎ ያጋሩ።')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. አነስተኛና ሙሉ ማጫወቻ (AUDIO PLAYERS)
// ==========================================

class SpiritualMiniPlayer extends StatelessWidget {
  const SpiritualMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);
    final title = state.currentMezmur?.title ?? state.currentPoemAudio?.title ?? '';
    final sub = state.currentMezmur?.singer ?? state.currentPoemAudio?.author ?? '';
    final cover = state.currentMezmur?.coverUrl ??
        'https://images.unsplash.com/photo-1548625361-195fe578491c?w=500';

    return GestureDetector(
      onTap: () {
        if (state.currentMezmur != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const FullMezmurPlayer(),
          );
        }
      },
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF24191E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 10)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(cover, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(sub, maxLines: 1, style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37))),
                ],
              ),
            ),
            IconButton(
              icon: Icon(state.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
              iconSize: 38,
              color: const Color(0xFFD4AF37),
              onPressed: () => state.togglePlayPause(),
            ),
          ],
        ),
      ),
    );
  }
}

class FullMezmurPlayer extends StatelessWidget {
  const FullMezmurPlayer({super.key});

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);
    final mezmur = state.currentMezmur;
    if (mezmur == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF161013),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const TabBar(
              indicatorColor: Color(0xFFD4AF37),
              labelColor: Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(icon: Icon(Icons.music_note_rounded), text: 'ማጫወቻ'),
                Tab(icon: Icon(Icons.lyrics_rounded), text: 'የመዝሙር ግጥም'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ክፍል 1፡ ማጫወቻ
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(mezmur.coverUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 24),
                      Text(mezmur.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(mezmur.singer, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                      const SizedBox(height: 24),
                      Slider(
                        activeColor: const Color(0xFFD4AF37),
                        inactiveColor: Colors.white24,
                        value: state.currentPosition.inSeconds.toDouble().clamp(0.0, state.totalDuration.inSeconds.toDouble().clamp(1.0, double.infinity)),
                        max: state.totalDuration.inSeconds.toDouble().clamp(1.0, double.infinity),
                        onChanged: (val) => state.seek(Duration(seconds: val.toInt())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_format(state.currentPosition), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                            Text(_format(state.totalDuration), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        iconSize: 64,
                        color: const Color(0xFFD4AF37),
                        icon: Icon(state.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                        onPressed: () => state.togglePlayPause(),
                      ),
                    ],
                  ),
                  // ክፍል 2፡ ግጥም
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text(
                      mezmur.lyrics,
                      style: const TextStyle(fontSize: 17, height: 2.0, color: Color(0xFFF3F4F6)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. ገጽ 1፡ መዝሙራት (MEZMUR CATALOG)
// ==========================================

class MezmurCatalogScreen extends StatefulWidget {
  const MezmurCatalogScreen({super.key});

  @override
  State<MezmurCatalogScreen> createState() => _MezmurCatalogScreenState();
}

class _MezmurCatalogScreenState extends State<MezmurCatalogScreen> {
  String _selectedCat = 'ሁሉም';

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);
    final categories = ['ሁሉም', 'የቅዱስ ገብርኤል', 'የደብረ ጽጌ', 'የእመቤታችን'];
    final list = _selectedCat == 'ሁሉም'
        ? state.mezmurs
        : state.mezmurs.where((m) => m.category == _selectedCat).toList();

    return Column(
      children: [
        // ምድቦች
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSel = cat == _selectedCat;
              return ChoiceChip(
                label: Text(cat, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontSize: 12)),
                selected: isSel,
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF1B1417),
                onSelected: (_) => setState(() => _selectedCat = cat),
              );
            },
          ),
        ),
        // ዝርዝር
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final mezmur = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1417),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E2429)),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(mezmur.coverUrl, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(mezmur.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${mezmur.singer} • ${mezmur.category}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(mezmur.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                        color: mezmur.isFavorite ? const Color(0xFFDC2626) : Colors.white54,
                        onPressed: () => state.toggleFavorite(mezmur),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFFD4AF37), size: 30),
                        onPressed: () => state.playMezmur(mezmur),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 6. ገጽ 2፡ መንፈሳዊ ግጥሞች (POEMS CATALOG)
// ==========================================

class PoemsCatalogScreen extends StatelessWidget {
  const PoemsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: state.poems.length,
      itemBuilder: (context, i) {
        final poem = state.poems[i];
        return Card(
          color: const Color(0xFF1B1417),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF2E2429))),
          margin: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PoemDetailView(poem: poem)));
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(poem.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      IconButton(
                        icon: Icon(poem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                        color: poem.isFavorite ? Colors.red : Colors.white54,
                        onPressed: () => state.togglePoemFavorite(poem),
                      ),
                    ],
                  ),
                  Text('ደራሲ፦ ${poem.author}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text(
                    poem.content.split('\n').take(3).join('\n'),
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white60, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  const Text('ሙሉውን ለማንበብ ይጫኑ...', style: TextStyle(fontSize: 12, color: Color(0xFFD4AF37))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PoemDetailView extends StatefulWidget {
  final SpiritualPoem poem;
  const PoemDetailView({super.key, required this.poem});

  @override
  State<PoemDetailView> createState() => _PoemDetailViewState();
}

class _PoemDetailViewState extends State<PoemDetailView> {
  double _fontSize = 17.0;

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poem.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1B1417),
                builder: (ctx) => StatefulBuilder(
                  builder: (ctx, setMState) => Container(
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('የፊደል መጠን ማስተካከያ'),
                        Slider(
                          min: 14,
                          max: 28,
                          activeColor: const Color(0xFFD4AF37),
                          value: _fontSize,
                          onChanged: (v) {
                            setState(() => _fontSize = v);
                            setMState(() => _fontSize = v);
                          },
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.poem.title, style: TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))),
            const SizedBox(height: 6),
            Text('ደራሲ፦ ${widget.poem.author}', style: const TextStyle(color: Colors.white70)),
            const Divider(height: 28, color: Colors.white24),
            if (widget.poem.audioRecitationUrl != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('የድምፅ ንባቡን አዳምጥ'),
                onPressed: () => state.playPoemAudio(widget.poem),
              ),
            const SizedBox(height: 20),
            Text(
              widget.poem.content,
              style: TextStyle(fontSize: _fontSize, height: 2.0, color: const Color(0xFFE5E7EB)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. ገጽ 3፡ የእኔ ማህደር (LIBRARY)
// ==========================================

class UserLibraryScreen extends StatelessWidget {
  const UserLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StateScope.of(context);
    final favMezmurs = state.mezmurs.where((m) => m.isFavorite).toList();

    return favMezmurs.isEmpty
        ? const Center(
            child: Text('እስካሁን የተወደዱ መዝሙራት አልተመረጡም።\nየልብ ቅርጿን በመንካት ያስቀምጡ።', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: favMezmurs.length,
            itemBuilder: (ctx, i) {
              final m = favMezmurs[i];
              return ListTile(
                tileColor: const Color(0xFF1B1417),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.music_note, color: Color(0xFFD4AF37)),
                title: Text(m.title),
                subtitle: Text(m.singer),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Color(0xFFD4AF37)),
                  onPressed: () => state.playMezmur(m),
                ),
              );
            },
          );
  }
}

// ==========================================
// 8. ገጽ 4፡ ተጨማሪ ክፍሎች (MORE MENU, ABOUT, CONTACT, FAQ, FEEDBACK)
// ==========================================

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _menuTile(
          context,
          icon: Icons.church_rounded,
          title: 'ስለ እኛ (About Us)',
          subtitle: 'የሰንበት ት/ቤቱ አመሠራረትና አገልግሎት',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
        ),
        _menuTile(
          context,
          icon: Icons.contact_phone_rounded,
          title: 'ያግኙን (Contact Us)',
          subtitle: 'ስልክ፣ ቴሌግራም እና አድራሻ',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
        ),
        _menuTile(
          context,
          icon: Icons.help_outline_rounded,
          title: 'ተደጋጋሚ ጥያቄዎች (FAQ)',
          subtitle: 'ስለ መተግበሪያው አጠቃቀም ማብራሪያ',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen())),
        ),
        _menuTile(
          context,
          icon: Icons.rate_review_rounded,
          title: 'አስተያየት ይስጡ (Feedback)',
          subtitle: 'ማሻሻያ እና የድጋፍ ቃልዎን ያጋሩን',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
        ),
      ],
    );
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1417),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2429)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD4AF37)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}

// 8.1 ስለ እኛ (ABOUT US)
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ስለ እኛ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('በስመ አብ ወወልድ ወመንፈስ ቅዱስ አሐዱ አምላክ አሜን።', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            SizedBox(height: 16),
            Text(
              'የወይቦ ደብረ ጽጌ ቅዱስ ገብርኤል ቤተክርስቲያን የፈለገ ጥበብ ሰንበት ትምህርት ቤት',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'የፈለገ ጥበብ ሰንበት ት/ቤት በኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተክርስቲያን እምነት፣ ሥርዓትና ትውፊት መሠረት ሕፃናትን፣ ወጣቶችንና ምእመናንን በቃለ እግዚአብሔር ለማነጽ፣ ያሬዳዊ ዜማንና መንፈሳዊ ግጥሞችን ለማስተማር የተመሠረተ የተቀደሰ ማኅበር ነው።',
              style: TextStyle(height: 1.8, color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text('ዓላማችን፦', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            SizedBox(height: 6),
            Text('• ትውልዱን በኦርቶዶክሳዊ ተዋሕዶ እምነት ማጽናት።\n• ቅዱሳት መጻሕፍትንና ያሬዳዊ መዝሙራትን ለምእመናን ተደራሽ ማድረግ።\n• ቤተክርስቲያንን በእውቀትና በምግባር የሚያገለግሉ ልጆችን ማፍራት።', style: TextStyle(height: 1.8, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// 8.2 ያግኙን (CONTACT US)
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ያግኙን')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _contactItem(Icons.location_on_rounded, 'አድራሻ', 'ኢትዮጵያ፣ ቦ/ሶሬ፣ የወይቦ ደብረ ጽጌ ቅ/ገብርኤል ቤ/ክ'),
          _contactItem(Icons.phone_rounded, 'ስልክ ቁጥር', '+251 900 00 00 00 / +251 911 00 00 00'),
          _contactItem(Icons.send_rounded, 'ቴሌግራም ቻናል', '@FelegeTibebWeybo'),
          _contactItem(Icons.email_rounded, 'ኢሜይል', 'felegetibeb.weybogebriel@gmail.com'),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String title, String val) {
    return Card(
      color: const Color(0xFF1B1417),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD4AF37)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
        subtitle: Text(val, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }
}

// 8.3 ተደጋጋሚ ጥያቄዎች (FAQ)
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'መዝሙራትን ያለ ኢንተርኔት (Offline) ማዳመጥ ይቻላል?', 'a': 'አዎ! መዝሙሩ አጠገብ ያለውን የማውረጃ ምልክት በመንካት ካወረዱት በኋላ ያለ ኢንተርኔት በማንኛውም ሰዓት ማዳመጥ ይችላሉ።'},
      {'q': 'የመዝሙሩን ግጥም እንዴት ማግኘት እችላለሁ?', 'a': 'መዝሙሩ በሚጫወትበት ጊዜ ማጫወቻውን ወደ ላይ በመክፈት "የመዝሙር ግጥም" የሚለውን ክፍል በመንካት ማግኘት ይችላሉ።'},
      {'q': 'የግጥሞችን የፊደል መጠን እንዴት እጨምራለሁ?', 'a': 'ግጥሙን በከፈቱ ጊዜ ከላይ በቀኝ በኩል ያለውን የፊደል ምልክት በመንካት እንደ ፍላጎትዎ ማሳነስና ማሳደግ ይችላሉ።'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ተደጋጋሚ ጥያቄዎች (FAQ)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (ctx, i) {
          final f = faqs[i];
          return Card(
            color: const Color(0xFF1B1417),
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              iconColor: const Color(0xFFD4AF37),
              collapsedIconColor: Colors.white70,
              title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(f['a']!, style: const TextStyle(color: Colors.white70, height: 1.6)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// 8.4 አስተያየት መስጫ (FEEDBACK)
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _nameCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('አስተያየት ይስጡ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ለመተግበሪያው ማሻሻያ የሚሆን ማንኛውንም ገንቢ አስተያየት ይላኩልን።', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'ሙሉ ስም (አስገዳጅ አይደለም)',
                filled: true,
                fillColor: Color(0xFF1B1417),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'የእርስዎ አስተያየት...',
                filled: true,
                fillColor: Color(0xFF1B1417),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                onPressed: () {
                  if (_msgCtrl.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('አስተያየትዎ ደርሶናል! ቃለ ሕይወት ያሰማልን።')),
                    );
                    _msgCtrl.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('አስተያየት ላክ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
