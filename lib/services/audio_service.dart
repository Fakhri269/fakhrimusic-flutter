import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();

  Future<void> init() async {}

  Future<String?> getAudioUrl(String youtubeId) async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(youtubeId);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      return streamInfo.url.toString();
    } catch (e) {
      print("Error getting YouTube stream: $e");
      return null;
    }
  }

  Future<void> playSong(Song song) async {
    final url = await getAudioUrl(song.youtubeId);
    if (url != null) {
      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album,
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.cover),
        ),
      );
      await player.setAudioSource(audioSource, initialPosition: Duration(seconds: song.startSeconds));
      player.play();
    }
  }

  void dispose() {
    yt.close();
    player.dispose();
  }
}
