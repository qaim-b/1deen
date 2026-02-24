import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/quran/data/quran_repository.dart';
import 'package:app/features/quran/domain/quran_models.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';

enum QuranSection { surahs, notes, bookmarks, search }

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
                  'Full Mushaf style, fully offline (Arabic + optional English translation).',
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
                      label: Text('Surahs / Juz'),
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
            Text('Recent Pages', style: theme.textTheme.titleMedium),
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
  bool _showTranslation = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF14171F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171F),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surah.transliteration),
            Text(
              '${widget.surah.arabicName} - Juz ${_estimateJuz(widget.surah.id)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
            icon: Icon(
              _showTranslation
                  ? Icons.translate_rounded
                  : Icons.g_translate_rounded,
            ),
            tooltip: _showTranslation
                ? 'Hide English translation'
                : 'Show English translation',
          ),
        ],
      ),
      body: ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: widget.surah.verses.length,
        itemBuilder: (context, index) {
          final verse = widget.surah.verses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E28),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(16)),
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
                          color: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_add_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: () => _toggleBookmark(verse.verseId),
                      ),
                    ],
                  ),
                  Text(
                    '${verse.arabic} ?',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.95,
                    ),
                  ),
                  if (_showTranslation) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        verse.english,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
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
      ),
    );
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
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
