import 'package:flutter/material.dart';
import 'models/tweet.dart';
import 'services/tweet_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tweeter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TweetPage(),
    );
  }
}

class TweetPage extends StatefulWidget {
  const TweetPage({super.key});

  @override
  State<TweetPage> createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  final TweetService _tweetService = TweetService();
  final TextEditingController _controller = TextEditingController();
  List<Tweet> _tweets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTweets();
  }

  Future<void> _loadTweets() async {
    setState(() => _isLoading = true);
    try {
      final tweets = await _tweetService.fetchTweets();
      setState(() {
        _tweets = tweets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _postTweet() async {
    if (_controller.text.trim().isEmpty) return;
    try {
      await _tweetService.createTweet(_controller.text.trim());
      _controller.clear();
      await _loadTweets();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteTweet(int id) async {
    try {
      await _tweetService.deleteTweet(id);
      await _loadTweets();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: const Text('Tweeter - REST API Integration'),
      ),
      body: Column(
        children: [
          // Campo para escribir tweet
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controller,
                maxLength: 140,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          // Botón Post Tweet
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton(
                onPressed: _postTweet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[100],
                ),
                child: const Text('Post Tweet'),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lista de tweets
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tweets.length,
                    itemBuilder: (context, index) {
                      final tweet = _tweets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(tweet.tweet),
                          subtitle: Text('ID: ${tweet.id}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTweet(tweet.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tweetService.dispose();
    super.dispose();
  }
}
