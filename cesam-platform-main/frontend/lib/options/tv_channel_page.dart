import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../services/api_service_video.dart';
import '../video_player/video_player.dart'; // ton player existant
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TvChannelPage extends StatefulWidget {
  const TvChannelPage({super.key});

  @override
  State<TvChannelPage> createState() => _TvChannelPageState();
}

class _TvChannelPageState extends State<TvChannelPage> {
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  String search = '';
  String? errorMessage;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('auth_token');
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await VideoApiService.getVideos(theme: 'Chaîne TV étudiante');
      if (result['success'] == true) {
        setState(() {
          videos = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Erreur lors du chargement';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleLike(int index, int videoId) async {
    if (_userToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour liker'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await VideoApiService.toggleLike(_userToken!, videoId);
      if (result['success'] == true) {
        setState(() {
          videos[index]['liked'] = result['data']['liked'];
          videos[index]['likes'] = result['data']['likes_count'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de connexion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isYouTube(String url) => YoutubePlayer.convertUrlToId(url) != null;
  bool isWebPlatform(String url) =>
      url.contains('facebook.com') || url.contains('instagram.com');
  bool isMp4(String url) => url.toLowerCase().endsWith('.mp4');

  void _openVideo(Map<String, dynamic> video) {
    final url = video['url'] ?? '';
    if (isYouTube(url)) {
      final videoId = YoutubePlayer.convertUrlToId(url)!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              YoutubePlayerPage(videoId: videoId, title: video['titre']),
        ),
      );
    } else if (isWebPlatform(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewPage(url: url, title: video['titre']),
        ),
      );
    } else if (isMp4(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VideoPlayerPage(videoUrl: url, title: video['titre']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lire cette vidéo")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVideos = videos
        .where((video) => (video['titre'] ?? '')
            .toString()
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Chaîne TV Étudiante',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une vidéo...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => search = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _buildContent(filteredVideos),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> filteredVideos) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (filteredVideos.isEmpty) {
      return const Center(child: Text("Aucune vidéo trouvée"));
    }

    return RefreshIndicator(
      onRefresh: _loadVideos,
      child: ListView.builder(
        itemCount: filteredVideos.length,
        itemBuilder: (context, index) {
          final video = filteredVideos[index];
          return GestureDetector(
            onTap: () => _openVideo(video),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoThumbnail(video),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            video['titre'] ?? 'Titre non disponible',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            video['liked'] == true ? Icons.favorite : Icons.favorite_border,
                            color: video['liked'] == true ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleLike(index, video['id']),
                        ),
                        Text(
                          VideoApiService.formatLikes(video['likes']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoThumbnail(Map<String, dynamic> video) {
    String? thumbnailUrl = video['miniature'] ?? VideoApiService.getYouTubeThumbnail(video['url'] ?? '');
    return Container(
      width: double.infinity,
      height: 240, // grande miniature style YouTube
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: thumbnailUrl != null
            ? DecorationImage(
                image: NetworkImage(thumbnailUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: thumbnailUrl == null
          ? const Center(
              child: Icon(Icons.video_library, size: 64, color: Colors.grey),
            )
          : null,
    );
  }
}

// --- YouTube player page ---
class YoutubePlayerPage extends StatefulWidget {
  final String videoId;
  final String? title;
  const YoutubePlayerPage({super.key, required this.videoId, this.title});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
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
      appBar: AppBar(title: Text(widget.title ?? 'YouTube')),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}

// --- WebView player page ---
class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;
  const WebViewPage({super.key, required this.url, this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Lecture vidéo')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
