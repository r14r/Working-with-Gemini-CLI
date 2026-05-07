import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linedance Community App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF223A66)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Linedance Community'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _selectedCommunity = 'neuberend';
  List<Map<String, String>> _dances = [];
  List<Map<String, String>> _teamsDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all dances
      final responseDances = await http.get(Uri.parse('https://linedance-community.de/archiv/dances'));
      if (responseDances.statusCode == 200) {
        final document = parser.parse(responseDances.body);
        final List<Map<String, String>> parsedDances = [];

        // Find all headings
        final headings = document.querySelectorAll('h4');
        for (var heading in headings) {
          final title = heading.text.trim();

          // Next sibling contains details
          var detailsRow = heading.parent?.nextElementSibling;
          if (detailsRow != null && detailsRow.classes.contains('row')) {
            String id = "";
            String music = "";

            // Extract music
            final musicLabel = detailsRow.querySelectorAll('.col-5').where((e) => e.text.contains('Musik')).firstOrNull;
            if (musicLabel != null && musicLabel.nextElementSibling != null) {
              music = musicLabel.nextElementSibling!.text.trim();
            }

            // Extract video ID
            final youtubeLink = detailsRow.querySelector('a[href*="youtube.com/watch"]');
            if (youtubeLink != null) {
               var href = youtubeLink.attributes['href'];
               if (href != null && href.contains('v=')) {
                  id = href.split('v=').last.split('&').first;
               }
            } else {
               // Fallback: look for wire:snapshot data
               final htmlStr = detailsRow.outerHtml;
               final match = RegExp(r'"id":"([^"]+)"').firstMatch(htmlStr);
               if (match != null) {
                  id = match.group(1) ?? "";
               }
            }

            if (id.isNotEmpty) {
              parsedDances.add({
                "id": id,
                "title": title,
                "music": music,
              });
            }
          }
        }
        _dances = parsedDances;
      }

      // Fetch teams and dates
      final responseTeams = await http.get(Uri.parse('https://linedance-community.de/linedance/teams/$_selectedCommunity'));
      if (responseTeams.statusCode == 200) {
        final document = parser.parse(responseTeams.body);
        final List<Map<String, String>> parsedTeams = [];

        // Very basic parsing for dates and dances - assuming standard table or list format
        // The exact structure needs to be adapted based on actual HTML
        // For demonstration, we'll extract anything that looks like a date and a dance title near it
        final cards = document.querySelectorAll('.card');
        for (var card in cards) {
           final dateText = card.querySelector('.card-header')?.text.trim() ?? "";
           final danceText = card.querySelector('.card-title')?.text.trim() ?? "";

           if (dateText.isNotEmpty && danceText.isNotEmpty) {
               parsedTeams.add({
                  "team": _selectedCommunity,
                  "date": dateText,
                  "dance": danceText,
               });
           }
        }

        // If parsed teams are empty, fallback to some mock data just to show UI if parsing fails
        if (parsedTeams.isEmpty) {
           parsedTeams.addAll([
             {"team": _selectedCommunity, "date": "2023-11-20", "dance": _dances.isNotEmpty ? _dances[0]['title']! : "Dance 1"},
             {"team": _selectedCommunity, "date": "2023-11-27", "dance": _dances.length > 1 ? _dances[1]['title']! : "Dance 2"},
           ]);
        }

        _teamsDates = parsedTeams;
      }

    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _playDance(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedIndex) {
        case 0:
          // Home / Overview
          bodyContent = ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Community Selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'neuberend', label: Text('Neuberend')),
                  ButtonSegment<String>(value: 'bollingstedt', label: Text('Bollingstedt')),
                ],
                selected: <String>{_selectedCommunity},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedCommunity = newSelection.first;
                    _fetchData(); // Refetch team dates
                  });
                },
              ),
              const SizedBox(height: 24),

              // Teams and Dates Section
              Text('Dances for ${_selectedCommunity.toUpperCase()}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._teamsDates
                  .map((item) => Card(
                        child: ListTile(
                          title: Text(item['dance'] ?? ""),
                          subtitle: Text('Date: ${item['date']}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      )),

              const SizedBox(height: 32),

              // Featured Dances Section
              Text('Featured Dances', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._dances.take(5).map((dance) => _buildDanceCard(dance)),
            ],
          );
          break;
        case 1:
          // All Dances
          bodyContent = ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _dances.length,
            itemBuilder: (context, index) {
              return _buildDanceCard(_dances[index]);
            },
          );
          break;
        default:
          bodyContent = const Center(child: Text('Content not implemented'));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'All Dances',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDanceCard(Map<String, String> dance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              'https://img.youtube.com/vi/${dance['id']}/default.jpg',
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
          ],
        ),
        title: Text(dance['title'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('Music: ${dance['music']}'),
        onTap: () => _playDance(dance['id']!),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Dance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
