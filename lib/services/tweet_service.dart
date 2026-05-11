import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tweet.dart';
import '../models/tweet_response.dart';

/// Singleton service para manejar las llamadas REST al endpoint de tweets
class TweetService {
  static final TweetService _instance = TweetService._internal();

  // Cambia esta URL por la de tu API en la nube cuando hagas deploy
  //final String baseUrl = 'http://localhost:8080/api';
  final String baseUrl = 'https://tweeter-api-5pyx.onrender.com/api';
  late http.Client _httpClient;

  /// Constructor privado
  TweetService._internal() {
    _httpClient = http.Client();
  }

  /// Factory constructor que siempre regresa la misma instancia
  factory TweetService() {
    return _instance;
  }

  /// Obtiene la instancia singleton
  static TweetService getInstance() {
    return _instance;
  }

  /// Obtiene todos los tweets desde la API
  Future<List<Tweet>> fetchTweets() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/tweets'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final tweetResponse = TweetResponse.fromJson(jsonData);
        return tweetResponse.content;
      } else {
        throw Exception(
            'Error al cargar tweets. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  /// Crea un nuevo tweet
  Future<Tweet> createTweet(String tweetText) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/tweets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tweet': tweetText}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Tweet.fromJson(jsonData);
      } else {
        throw Exception('Error al crear tweet. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  /// Elimina un tweet por ID
  Future<void> deleteTweet(int id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/tweets/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al eliminar tweet. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  /// Cierra el cliente HTTP
  void dispose() {
    _httpClient.close();
  }
}
