import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/quran/data/quran_repository.dart';
import 'package:app/features/quran/domain/quran_models.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuranSection { surahs, notes, bookmarks, search }

enum QuranReadingMode { verseByVerse, readingFlow }

class QuranHubTab extends StatefulWidget {
  const QuranHubTab({required this.repository, super.key});

  final QuranRepository repository;

  @override
  State<QuranHubTab> createState() => _QuranHubTabState();
}

class _QuranHubTabState extends State<QuranHubTab> {
  QuranSection _section = QuranSection.surahs;
  bool _loading = true;
  List<QuranSurah> _surahs = const [];
  List<QuranBookmark> _bookmarks = const [];
  List<QuranNote> _notes = const [];
  List<int> _recentSurahIds = const [];
  List<QuranSearchResult> _results = const [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final surahs = await widget.repository.loadSurahs();
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _bookmarks = widget.repository.loadBookmarks();
      _notes = widget.repository.loadNotes();
      _recentSurahIds = widget.repository.loadRecentSurahs();
      _loading = false;
    });
  }

  Future<void> _runSearch(String value) async {
    final results = await widget.repository.search(value);
    if (!mounted) return;
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.pagePadding(context),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Quran',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Full Mushaf style, fully offline with Arabic + translation controls.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<QuranSection>(
                  segments: const [
                    ButtonSegment(
                      value: QuranSection.surahs,
                      icon: Icon(Icons.menu_book_rounded),
                      label: Text('Surah'),
                    ),
                    ButtonSegment(
                      value: QuranSection.notes,
                      icon: Icon(Icons.notes_rounded),
                      label: Text('Notes'),
                    ),
                    ButtonSegment(
                      value: QuranSection.bookmarks,
                      icon: Icon(Icons.bookmark_rounded),
                      label: Text('Bookmarks'),
                    ),
                    ButtonSegment(
                      value: QuranSection.search,
                      icon: Icon(Icons.search_rounded),
                      label: Text('Search'),
                    ),
                  ],
                  selected: {_section},
                  onSelectionChanged: (value) =>
                      setState(() => _section = value.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_section == QuranSection.surahs &&
                    _recentSurahIds.isNotEmpty)
                  _RecentSurahsCard(
                    recentSurahIds: _recentSurahIds,
                    surahs: _surahs,
                    repository: widget.repository,
                    onChanged: _load,
                  ),
                if (_section == QuranSection.surahs &&
                    _recentSurahIds.isNotEmpty)
                  const SizedBox(height: AppSpacing.md),
                _buildBody(context),
              ],
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_section) {
      case QuranSection.surahs:
        return _SurahList(
          surahs: _surahs,
          repository: widget.repository,
          onChanged: _load,
        );
      case QuranSection.notes:
        return _NotesList(notes: _notes, surahs: _surahs);
      case QuranSection.bookmarks:
        return _BookmarksList(bookmarks: _bookmarks, surahs: _surahs);
      case QuranSection.search:
        return _SearchSection(
          controller: _searchController,
          results: _results,
          onSearch: _runSearch,
          surahs: _surahs,
          repository: widget.repository,
          onChanged: _load,
        );
    }
  }
}

class _RecentSurahsCard extends StatelessWidget {
  const _RecentSurahsCard({
    required this.recentSurahIds,
    required this.surahs,
    required this.repository,
    required this.onChanged,
  });

  final List<int> recentSurahIds;
  final List<QuranSurah> surahs;
  final QuranRepository repository;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Surahs', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...recentSurahIds.take(3).map((id) {
              final surah = surahs.where((s) => s.id == id).firstOrNull;
              if (surah == null) return const SizedBox.shrink();
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded),
                title: Text('${surah.transliteration}  ${surah.arabicName}'),
                trailing: Text('${surah.id}', style: theme.textTheme.bodySmall),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          QuranReaderPage(surah: surah, repository: repository),
                    ),
                  );
                  await onChanged();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({
    required this.surahs,
    required this.repository,
    required this.onChanged,
  });

  final List<QuranSurah> surahs;
  final QuranRepository repository;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: surahs
          .map((surah) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  title: Text(
                    '${surah.id}. ${surah.transliteration}  ${surah.arabicName}',
                  ),
                  subtitle: Text('${surah.type} - ${surah.totalVerses} verses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await repository.addRecentSurah(surah.id);
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderPage(
                          surah: surah,
                          repository: repository,
                        ),
                      ),
                    );
                    await onChanged();
                  },
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes, required this.surahs});

  final List<QuranNote> notes;
  final List<QuranSurah> surahs;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const _EmptyCard(
        title: 'Notes',
        message: 'Long-press an ayah in reader to add notes.',
      );
    }

    return Column(
      children: notes
          .map((note) {
            final surah = surahs.firstWhere((s) => s.id == note.surahId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  title: Text(
                    '${surah.transliteration} ${surah.arabicName} (${note.surahId}:${note.verseId})',
                  ),
                  subtitle: Text(note.text),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({required this.bookmarks, required this.surahs});

  final List<QuranBookmark> bookmarks;
  final List<QuranSurah> surahs;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const _EmptyCard(
        title: 'Bookmarks',
        message: 'Tap bookmark icon in reader to save ayah positions.',
      );
    }

    return Column(
      children: bookmarks
          .map((item) {
            final surah = surahs.firstWhere((s) => s.id == item.surahId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.bookmark_rounded),
                  title: Text('${surah.transliteration} ${surah.arabicName}'),
                  subtitle: Text('Ayah ${item.verseId}'),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.results,
    required this.onSearch,
    required this.surahs,
    required this.repository,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<QuranSearchResult> results;
  final ValueChanged<String> onSearch;
  final List<QuranSurah> surahs;
  final QuranRepository repository;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Search surah, ayah, Arabic, English. Example: 2:255',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: AppSpacing.md),
        if (results.isEmpty)
          const _EmptyCard(
            title: 'Search',
            message: 'Start typing to search Quran offline.',
          )
        else
          ...results.map((r) {
            final surah = surahs.firstWhere((s) => s.id == r.surahId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: ListTile(
                  title: Text('${r.surahName} (${r.surahId}:${r.verseId})'),
                  subtitle: Text(
                    r.english,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuranReaderPage(
                          surah: surah,
                          repository: repository,
                          initialAyah: r.verseId,
                        ),
                      ),
                    );
                    await onChanged();
                  },
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding(context),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class QuranReaderPage extends StatefulWidget {
  const QuranReaderPage({
    required this.surah,
    required this.repository,
    this.initialAyah,
    super.key,
  });

  final QuranSurah surah;
  final QuranRepository repository;
  final int? initialAyah;

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final _controller = ScrollController();
  bool _showArabic = true;
  bool _showTranslation = false;
  QuranReadingMode _readingMode = QuranReadingMode.readingFlow;
  static const _bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  @override
  void initState() {
    super.initState();
    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final offset = (widget.initialAyah! - 1) * 118.0;
        if (_controller.hasClients) {
          _controller.jumpTo(
            offset.clamp(0.0, _controller.position.maxScrollExtent),
          );
        }
      });
    }
  }

  Future<void> _toggleBookmark(int ayah) async {
    await widget.repository.toggleBookmark(
      surahId: widget.surah.id,
      verseId: ayah,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bookmark updated')));
  }

  Future<void> _addNote(int ayah) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add note (${widget.surah.id}:$ayah)'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your reflection...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (text == null || text.isEmpty) return;
    await widget.repository.saveNote(
      surahId: widget.surah.id,
      verseId: ayah,
      text: text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  void _onListenPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listen is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _ReaderPalette.fromTheme(theme);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        titleSpacing: 14,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surah.transliteration),
            Text(
              'Page ${widget.surah.id}  Juz ${_estimateJuz(widget.surah.id)} / Hizb ${_estimateHizb(widget.surah.id)}',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.muted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Verse by Verse'),
                  selected: _readingMode == QuranReadingMode.verseByVerse,
                  onSelected: (_) => setState(
                    () => _readingMode = QuranReadingMode.verseByVerse,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Reading Mode'),
                  selected: _readingMode == QuranReadingMode.readingFlow,
                  onSelected: (_) => setState(
                    () => _readingMode = QuranReadingMode.readingFlow,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Listen'),
                  onPressed: _onListenPressed,
                ),
                FilterChip(
                  label: const Text('Arabic'),
                  selected: _showArabic,
                  onSelected: (v) => setState(() => _showArabic = v),
                ),
                FilterChip(
                  label: const Text('Translation'),
                  selected: _showTranslation,
                  onSelected: (v) => setState(() => _showTranslation = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _readingMode == QuranReadingMode.readingFlow
                ? _buildMushafFlow(theme, colors)
                : _buildVerseByVerse(theme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseByVerse(ThemeData theme, _ReaderPalette colors) {
    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: widget.surah.verses.length,
      itemBuilder: (context, index) {
        final verse = widget.surah.verses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: colors.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onLongPress: () => _addNote(verse.verseId),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.surah.id}:${verse.verseId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark_add_outlined,
                        color: colors.muted,
                      ),
                      onPressed: () => _toggleBookmark(verse.verseId),
                    ),
                  ],
                ),
                if (_showArabic)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '${verse.arabic} (${verse.verseId})',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoNaskhArabic(
                        textStyle: TextStyle(
                          color: colors.foreground,
                          fontSize: 35,
                          height: 1.95,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (_showTranslation) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      verse.english,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.muted,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMushafFlow(ThemeData theme, _ReaderPalette colors) {
    final flowText = widget.surah.verses
        .map((verse) => '${verse.arabic} (${verse.verseId})')
        .join('   ');

    return ListView(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Juz ${_estimateJuz(widget.surah.id)}, Hizb ${_estimateHizb(widget.surah.id)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.surah.transliteration}  ${widget.surah.arabicName}',
              style: theme.textTheme.titleMedium?.copyWith(color: colors.muted),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.borderStrong),
                color: colors.panel,
              ),
              child: Center(
                child: Text(
                  widget.surah.arabicName,
                  style: GoogleFonts.notoNaskhArabic(
                    textStyle: TextStyle(
                      color: colors.foreground,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showBismillah()) ...[
          const SizedBox(height: 18),
          Center(
            child: Text(
              _bismillah,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoNaskhArabic(
                textStyle: TextStyle(
                  color: colors.foreground,
                  fontSize: 38,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              decoration: BoxDecoration(
                color: colors.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_showArabic)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        flowText,
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.notoNaskhArabic(
                          textStyle: TextStyle(
                            color: colors.foreground,
                            fontSize: 37,
                            height: 2.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        strutStyle: const StrutStyle(
                          forceStrutHeight: true,
                          height: 2.0,
                        ),
                      ),
                    ),
                  if (_showTranslation) ...[
                    const SizedBox(height: 20),
                    ...widget.surah.verses.map(
                      (verse) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${verse.verseId}. ${verse.english}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.muted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            '${widget.surah.id}',
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.muted),
          ),
        ),
      ],
    );
  }

  bool _showBismillah() {
    if (widget.surah.id == 1 || widget.surah.id == 9) return false;
    return true;
  }

  int _estimateJuz(int surahId) {
    if (surahId <= 2) return 1;
    if (surahId <= 4) return 3;
    if (surahId <= 5) return 6;
    if (surahId <= 9) return 8;
    if (surahId <= 18) return 15;
    if (surahId <= 36) return 21;
    if (surahId <= 55) return 27;
    return 30;
  }

  int _estimateHizb(int surahId) {
    if (surahId <= 2) return 1;
    if (surahId <= 4) return 8;
    if (surahId <= 9) return 12;
    if (surahId <= 18) return 20;
    if (surahId <= 36) return 32;
    if (surahId <= 55) return 45;
    return 60;
  }
}

class _ReaderPalette {
  const _ReaderPalette({
    required this.background,
    required this.panel,
    required this.foreground,
    required this.muted,
    required this.border,
    required this.borderStrong,
  });

  final Color background;
  final Color panel;
  final Color foreground;
  final Color muted;
  final Color border;
  final Color borderStrong;

  factory _ReaderPalette.fromTheme(ThemeData theme) {
    final dark = theme.brightness == Brightness.dark;
    return _ReaderPalette(
      background: dark ? const Color(0xFF14171F) : const Color(0xFFF8F9FB),
      panel: dark ? const Color(0xFF1A1E28) : Colors.white,
      foreground: dark ? Colors.white : const Color(0xFF161B22),
      muted: dark ? Colors.white70 : const Color(0xFF4A5565),
      border: dark ? Colors.white.withAlpha(20) : const Color(0xFFE3E7EF),
      borderStrong: dark ? Colors.white.withAlpha(56) : const Color(0xFFCDD6E4),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
