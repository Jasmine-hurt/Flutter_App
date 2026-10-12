import 'dart:async' show Future;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Retrieves the Bible JSON file.
Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BiblePage(
        bookIndex: 0,
        chapter: 1,
      ),
    );
  }
}

class BiblePage extends StatefulWidget {
  const BiblePage({
    super.key,
    required this.bookIndex,
    required this.chapter,
  });

  final int bookIndex;
  final int chapter;

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  // false = English
  // true = Indonesian
  bool _isIndonesian = true;

  static const List<String> books = [
    'Genesis',
    'Exodus'
    /*'Leviticus',
    'Numbers',
    'Deuteronomy',
    'Joshua',
    'Judges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Kings',
    '2 Kings',
    '1 Chronicles',
    '2 Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',
    'Job',
    'Psalms',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi',
    'Matthew',
    'Mark',
    'Luke',
    'John',
    'Acts',
    'Romans',
    '1 Corinthians',
    '2 Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    '1 Thessalonians',
    '2 Thessalonians',
    '1 Timothy',
    '2 Timothy',
    'Titus',
    'Philemon',
    'Hebrews',
    'James',
    '1 Peter',
    '2 Peter',
    '1 John',
    '2 John',
    '3 John',
    'Jude',
    'Revelation',
    */
  ];

  static const List<int> chapterCounts = [
    2,
    1
    /*
    27,
    36,
    34,
    24,
    21,
    4,
    31,
    24,
    22,
    25,
    29,
    36,
    10,
    13,
    10,
    42,
    150,
    31,
    12,
    8,
    66,
    52,
    5,
    48,
    12,
    14,
    3,
    9,
    1,
    4,
    7,
    3,
    3,
    3,
    2,
    14,
    4,
    28,
    16,
    24,
    21,
    28,
    16,
    16,
    13,
    6,
    6,
    4,
    4,
    5,
    3,
    6,
    4,
    3,
    1,
    13,
    5,
    5,
    3,
    5,
    1,
    1,
    1,
    22,*/
  ];

  String get book => books[widget.bookIndex];

  // Gets the correct JSON file depending on the selected language.
  String get assetPath {
    if (_isIndonesian) {
      return 'assets/TB_books/$book.json';
    } else {
      return 'assets/ESV_books/$book.json';
    }
  }

  // Checks if this is the first page.
  bool get isFirstPage {
    return widget.bookIndex == 0 && widget.chapter == 1;
  }

  // Checks if this is the last page.
  bool get isLastPage {
    return widget.bookIndex == books.length - 1 &&
        widget.chapter == chapterCounts[widget.bookIndex];
  }

  final indonesianBookNames = {
    'Genesis': 'Kejadian',
    'Exodus': 'Keluaran',
  };

  String get jsonBookName {
    if (_isIndonesian) {
      return indonesianBookNames[book] ?? book;
    }
    return book;
  }
  // Switches between English and Indonesian.
  void switchLanguage() {
    setState(() {
      _isIndonesian = !_isIndonesian;
    });
  }

  // Goes to the next chapter.
  void goToNextPage() {
    if (isLastPage) {
      return;
    }

    int nextBookIndex = widget.bookIndex;
    int nextChapter = widget.chapter + 1;

    // If this is the last chapter of the current book,
    // move to the first chapter of the next book.
    if (nextChapter > chapterCounts[widget.bookIndex]) {
      nextBookIndex++;
      nextChapter = 1;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BiblePage(
          bookIndex: nextBookIndex,
          chapter: nextChapter,
        ),
      ),
    );
  }

  // Goes to the previous chapter.
  void goToPreviousPage() {
    if (isFirstPage) {
      return;
    }

    int previousBookIndex = widget.bookIndex;
    int previousChapter = widget.chapter - 1;

    // If this is the first chapter of the current book,
    // move to the last chapter of the previous book.
    if (previousChapter < 1) {
      previousBookIndex--;
      previousChapter = chapterCounts[previousBookIndex];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BiblePage(
          bookIndex: previousBookIndex,
          chapter: previousChapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          '${_isIndonesian
              ? indonesianBookNames[book] ?? book
              : book} ${widget.chapter}',
        ),

        // Button in the top-right corner.
        actions: [
          TextButton(
            onPressed: switchLanguage,
            child: Text(
              _isIndonesian ? 'ENG' : 'INDO',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<String>(
        future: getFileData(assetPath),

        builder: (context, snapshot) {
          // Shows loading indicator while JSON is loading.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Shows an error if the JSON cannot be loaded.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading Bible:\n${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data found.'),
            );
          }

          try {
            // Converts the JSON text into Dart data.
            final data = jsonDecode(snapshot.data!);
            final bookData = data[jsonBookName];
            final chapter = bookData[widget.chapter.toString()];

            final chapterData = (chapter as Map<String, dynamic>)
                .entries
                .map<Map<String, dynamic>>((verse) {
              return {
                'verse': int.parse(verse.key),
                'text': verse.value,
              };
            }).toList();

            // Make sure the chapter contains verses.
            if (chapterData.isEmpty) {
              return Center(
                child: Text(
                  'No verses found for $book ${widget.chapter}.',
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Displays each verse.
                  ...chapterData.map<Widget>((verse) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),

                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            // Verse number
                            TextSpan(
                              text: '${verse['verse']} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Verse text
                            TextSpan(
                              text: verse['text'],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Previous and Next buttons.
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: isFirstPage
                            ? null
                            : goToPreviousPage,
                        child: const Text('Previous'),
                      ),

                      ElevatedButton(
                        onPressed: isLastPage
                            ? null
                            : goToNextPage,
                        child: const Text('Next'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          } catch (e) {
            return Center(
              child: Text(
                'Error parsing Bible JSON:\n$e',
              ),
            );
          }
        },
      ),
    );
  }
}
