import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';

class MusicPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final song = musicProvider.currentSong;

    if (song == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560)),
            onPressed: () => musicProvider.playQueue(initialSongs, 0),
            child: const Text("Start Listening", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                  Text("NOW PLAYING", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const Icon(Icons.more_horiz, color: Colors.white, size: 32),
                ],
              ),
            ),
            
            // Artwork
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: song.cover,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      aspectRatio: 1,
                      placeholder: (context, url) => Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),

            // Info & Controls
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              song.artist,
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        song.liked ? Icons.favorite : Icons.favorite_border,
                        color: song.liked ? const Color(0xFFE94560) : Colors.white,
                        size: 30,
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Progress Bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: musicProvider.currentPosition.inSeconds.toDouble(),
                      max: musicProvider.totalDuration.inSeconds > 0 
                          ? musicProvider.totalDuration.inSeconds.toDouble() 
                          : 1.0,
                      onChanged: (val) {
                        musicProvider.seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(musicProvider.currentPosition), style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                      Text(_formatDuration(musicProvider.totalDuration), style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.shuffle, color: Colors.white54, size: 24),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                        onPressed: musicProvider.previous,
                      ),
                      GestureDetector(
                        onTap: musicProvider.togglePlay,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE94560),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                        onPressed: musicProvider.next,
                      ),
                      const Icon(Icons.repeat, color: Colors.white54, size: 24),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
