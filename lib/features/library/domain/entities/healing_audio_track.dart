import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class HealingAudioTrack extends Equatable {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String description;
  final String artist;
  final String frequency;
  final String imageUrl;
  final String audioUrl;
  final bool isPopular;

  const HealingAudioTrack({
    required this.id,
    required this.title,
    required this.category,
    this.duration = '30:00',
    this.description = '',
    this.artist = 'Bee Beyonnd Vault',
    this.frequency = '432 Hz',
    this.imageUrl = '',
    this.audioUrl = '',
    this.isPopular = false,
  });

  static String _formatUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    String trimmed = url.trim();

    // Automatically rewrite localhost or 127.0.0.1 to actual server hostname
    if (trimmed.contains('localhost')) {
      trimmed = trimmed.replaceAll('http://localhost', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://localhost', 'https://metricstestingapp.xyz');
    }
    if (trimmed.contains('127.0.0.1')) {
      trimmed = trimmed.replaceAll('http://127.0.0.1', 'https://metricstestingapp.xyz');
      trimmed = trimmed.replaceAll('https://127.0.0.1', 'https://metricstestingapp.xyz');
    }

    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }

    String baseUrl = ApiEndpoints.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }

  static String parseDurationString(dynamic raw) {
    if (raw == null) return '00:00';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '00:00';

    // If it's in MM:SS or HH:MM:SS format
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0])?.toString().padLeft(2, '0') ?? parts[0];
        final s = int.tryParse(parts[1])?.toString().padLeft(2, '0') ?? parts[1];
        return '$m:$s';
      }
      return str;
    }

    // If it's a number representing seconds or milliseconds
    final numVal = double.tryParse(str);
    if (numVal != null && numVal > 0) {
      final seconds = numVal > 100000 ? (numVal / 1000).round() : numVal.round();
      final d = Duration(seconds: seconds);
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (d.inHours > 0) {
        final hours = d.inHours.toString().padLeft(2, '0');
        return '$hours:$minutes:$secs';
      }
      return '$minutes:$secs';
    }

    return str;
  }

  factory HealingAudioTrack.fromJson(Map<String, dynamic> json) {
    final rawAudioUrl = json['audio_url']?.toString() ??
        json['audioUrl']?.toString() ??
        json['url']?.toString() ??
        json['music_url']?.toString() ??
        json['file_url']?.toString() ??
        json['file']?.toString() ??
        '';

    final audioUrl = _formatUrl(rawAudioUrl);

    final rawImageUrl = json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['thumbnail']?.toString() ??
        json['cover']?.toString() ??
        '';

    final imageUrl = _formatUrl(rawImageUrl);

    final rawDuration = json['duration'] ??
        json['audio_duration'] ??
        json['track_duration'] ??
        json['duration_formatted'] ??
        json['length'] ??
        json['duration_seconds'] ??
        json['time'] ??
        '';

    final parsedDuration = parseDurationString(rawDuration);

    return HealingAudioTrack(
      id: json['id']?.toString() ??
          json['track_id']?.toString() ??
          json['audio_id']?.toString() ??
          '',
      title: json['title']?.toString() ??
          json['track_title']?.toString() ??
          json['name']?.toString() ??
          json['song_title']?.toString() ??
          'Healing Track',
      category: json['category']?.toString() ??
          json['category_name']?.toString() ??
          json['genre']?.toString() ??
          'General',
      duration: parsedDuration.isNotEmpty && parsedDuration != '00:00'
          ? parsedDuration
          : '00:00',
      description: json['description']?.toString() ??
          json['details']?.toString() ??
          '',
      artist: json['artist']?.toString() ??
          json['artist_name']?.toString() ??
          json['singer']?.toString() ??
          'Bee Beyonnd Vault',
      frequency: json['frequency']?.toString() ??
          json['hz']?.toString() ??
          json['tuning']?.toString() ??
          '432 Hz',
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      isPopular: json['isPopular'] == true ||
          json['is_popular'] == 1 ||
          json['is_popular'] == '1' ||
          json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'duration': duration,
      'description': description,
      'artist': artist,
      'frequency': frequency,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isPopular': isPopular,
    };
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'chakra therapy':
      case 'ayurvedic upchar':
      case 'ayurveda':
        return const Color(0xFF7C3AED);
      case 'bach ambient':
      case 'cricket':
        return const Color(0xFF059669);
      case 'binaural sleep':
        return const Color(0xFF4338CA);
      case 'mantra therapy':
        return const Color(0xFFD97706);
      case 'nature sounds':
        return const Color(0xFF0288D1);
      default:
        return const Color(0xFF4338CA);
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        duration,
        description,
        artist,
        frequency,
        imageUrl,
        audioUrl,
        isPopular,
      ];
}
