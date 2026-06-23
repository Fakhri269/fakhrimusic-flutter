import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MusicProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();
  
  List<Song> queue = [];
  int currentIndex = -1;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  MusicProvider() {
    _init();
  }

  void _init() {
    _audioService.player.positionStream.listen((pos) {
      currentPosition = pos;
      notifyListeners();
    });
    _audioService.player.durationStream.listen((dur) {
      totalDuration = dur ?? Duration.zero;
      notifyListeners();
    });
    _audioService.player.playingStream.listen((playing) {
      isPlaying = playing;
      notifyListeners();
    });
    _audioService.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  Song? get currentSong => currentIndex >= 0 && currentIndex < queue.length ? queue[currentIndex] : null;

  void playQueue(List<Song> newQueue, int startIndex) {
    queue = newQueue;
    currentIndex = startIndex;
    _audioService.playSong(queue[currentIndex]);
    notifyListeners();
  }

  void togglePlay() {
    if (_audioService.player.playing) {
      _audioService.player.pause();
    } else {
      _audioService.player.play();
    }
  }

  void next() {
    if (queue.isEmpty) return;
    currentIndex = (currentIndex + 1) % queue.length;
    _audioService.playSong(queue[currentIndex]);
    notifyListeners();
  }

  void previous() {
    if (queue.isEmpty) return;
    if (currentPosition.inSeconds > 3) {
      _audioService.player.seek(Duration.zero);
    } else {
      currentIndex = (currentIndex - 1 + queue.length) % queue.length;
      _audioService.playSong(queue[currentIndex]);
    }
    notifyListeners();
  }

  void seek(Duration position) {
    _audioService.player.seek(position);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
