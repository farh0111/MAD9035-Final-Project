import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/http_helper.dart';

// main widget for movie selection screen
class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  List<Map<String, dynamic>> movies = []; // list to store movies
  int currentIndex = 0; // index of the current movie
  int currentPage = 1; // current page for pagination
  bool isLoading = true; // loading state

  @override
  void initState() {
    super.initState();
    _loadMovies(); // load movies when the screen initializes
  }

  // function to load movies from the api
  Future<void> _loadMovies() async {
    try {
      final newMovies = await HttpHelper.fetchMovies(currentPage);
      setState(() {
        movies.addAll(newMovies); // add new movies to the list
        isLoading = false; // set loading to false
        currentPage++; // increment the page number
      });
    } catch (e) {
      // show error message if loading fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load movies!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // function to vote for a movie
  Future<void> _voteMovie(bool vote) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final sessionId = appState.sessionId!;
    final movie = movies[currentIndex];
    final movieId = movie['id'];

    try {
      final response = await HttpHelper.voteMovie(sessionId, movieId, vote);

      if (response.containsKey('data')) {
        final match = response['data']['match'] as bool;
        if (match) {
          _showMatchDialog(movie); // show match dialog if there's a match
        }
      }

      setState(() {
        currentIndex++; // move to the next movie
      });

      if (currentIndex >= movies.length - 1) {
        await _loadMovies(); // load more movies if at the end of the list
      }
    } catch (e) {
      // show error message if voting fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit vote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // function to show match dialog
  void _showMatchDialog(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IT\'S A MATCH!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(movie['title']),
            const SizedBox(height: 10),
            Image.network(
              '${HttpHelper.tmdbImageBaseUrl}${movie['poster_path']}',
              height: 150,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && movies.isEmpty) {
      // show loading indicator if movies are loading
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (movies.isEmpty) {
      // show message if no movies are available
      return Scaffold(
        appBar: AppBar(
          title: const Text('Movie Selection'),
          backgroundColor: Colors.blue[900],
        ),
        body: const Center(child: Text('No movies available!')),
      );
    }

    final movie = movies[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Selection'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Dismissible(
          key: Key(movie['id'].toString()),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            final vote = direction == DismissDirection.startToEnd;
            _voteMovie(vote); // vote based on swipe direction
          },
          background: _buildSwipeBackground(
              Colors.green, Icons.thumb_up, Alignment.centerLeft),
          secondaryBackground: _buildSwipeBackground(
              Colors.red, Icons.thumb_down, Alignment.centerRight),
          child: _buildMovieCard(movie), // build movie card
        ),
      ),
    );
  }

  // function to build swipe background
  Widget _buildSwipeBackground(
      Color color, IconData icon, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 40),
    );
  }

  // function to build movie card
  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (movie['poster_path'] != null)
            Image.network(
              '${HttpHelper.tmdbImageBaseUrl}${movie['poster_path']}',
              height: 400,
            )
          else
            const SizedBox(
              height: 400,
              child: Center(child: Text('no image')),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'] ?? 'no title',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Release Date: ${movie['release_date'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Rating: ${movie['vote_average'] ?? 'N/A'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
