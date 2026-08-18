import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Types of ambient sounds we can generate.
enum CalmSoundType {
  rain,
  ocean,
  forest,
  whiteNoise,
}

/// Represents a playable calm sound with its player instance.
class CalmSound {
  final CalmSoundType type;
  final AudioPlayer player;
  double volume;
  bool isPlaying;
  String? filePath;

  CalmSound({
    required this.type,
    required this.player,
    this.volume = 0.5,
    this.isPlaying = false,
    this.filePath,
  });

  String get label {
    switch (type) {
      case CalmSoundType.rain:
        return 'Rain';
      case CalmSoundType.ocean:
        return 'Ocean Waves';
      case CalmSoundType.forest:
        return 'Forest';
      case CalmSoundType.whiteNoise:
        return 'White Noise';
    }
  }

  String get icon {
    switch (type) {
      case CalmSoundType.rain:
        return '🌧️';
      case CalmSoundType.ocean:
        return '🌊';
      case CalmSoundType.forest:
        return '🌿';
      case CalmSoundType.whiteNoise:
        return '💨';
    }
  }
}

/// Service that generates and manages ambient sound playback.
/// All sounds are generated programmatically as WAV files — no external assets needed.
class CalmSoundService {
  static final CalmSoundService _instance = CalmSoundService._();
  factory CalmSoundService() => _instance;
  CalmSoundService._();

  final List<CalmSound> _sounds = [];
  bool _initialized = false;

  static const int _sampleRate = 44100;
  static const int _bitsPerSample = 16;
  static const int _channels = 1;
  static const int _durationSeconds = 10; // Generate 10-sec loops
  static const int _soundVersion = 2; // Bump to regenerate all sounds

  List<CalmSound> get sounds => List.unmodifiable(_sounds);

  /// Initialize all sound players and generate WAV files.
  Future<void> init() async {
    if (_initialized) return;

    final tempDir = await getTemporaryDirectory();
    final soundDir = Directory('${tempDir.path}/healmind_sounds');
    if (!await soundDir.exists()) {
      await soundDir.create(recursive: true);
    }

    for (final type in CalmSoundType.values) {
      final player = AudioPlayer();
      final filePath = '${soundDir.path}/${type.name}_v$_soundVersion.wav';

      // Generate WAV file if it doesn't exist (versioned)
      final file = File(filePath);
      if (!await file.exists()) {
        // Clean up old versions
        final oldPattern = RegExp('${type.name}_v\\d+.wav');
        final dirFiles = await soundDir.list().toList();
        for (final f in dirFiles) {
          final name = f.path.split('/').last.split('\\').last;
          if (oldPattern.hasMatch(name) && f.path != filePath) {
            await File(f.path).delete();
          }
        }

        final wavData = _generateSound(type);
        await file.writeAsBytes(wavData);
      }

      final sound = CalmSound(
        type: type,
        player: player,
        filePath: filePath,
      );

      // Set looping and initial volume
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setSource(DeviceFileSource(filePath));
      await player.setVolume(0.0); // Start muted

      _sounds.add(sound);
    }

    _initialized = true;
  }

  /// Start playing a specific sound.
  Future<void> play(CalmSoundType type) async {
    final sound = _sounds.firstWhere((s) => s.type == type);
    if (!sound.isPlaying) {
      await sound.player.setVolume(sound.volume);
      await sound.player.resume();
      sound.isPlaying = true;
    }
  }

  /// Stop playing a specific sound.
  Future<void> stop(CalmSoundType type) async {
    final sound = _sounds.firstWhere((s) => s.type == type);
    if (sound.isPlaying) {
      await sound.player.pause();
      sound.isPlaying = false;
    }
  }

  /// Toggle play/pause for a sound.
  Future<void> toggle(CalmSoundType type) async {
    final sound = _sounds.firstWhere((s) => s.type == type);
    if (sound.isPlaying) {
      await stop(type);
    } else {
      await play(type);
    }
  }

  /// Set volume for a specific sound (0.0 to 1.0).
  Future<void> setVolume(CalmSoundType type, double volume) async {
    final sound = _sounds.firstWhere((s) => s.type == type);
    sound.volume = volume;
    if (sound.isPlaying) {
      await sound.player.setVolume(volume);
    }
  }

  /// Stop all sounds.
  Future<void> stopAll() async {
    for (final sound in _sounds) {
      if (sound.isPlaying) {
        await sound.player.pause();
        sound.isPlaying = false;
      }
    }
  }

  /// Check if any sound is playing.
  bool get isAnyPlaying => _sounds.any((s) => s.isPlaying);

  /// Dispose all players.
  Future<void> dispose() async {
    for (final sound in _sounds) {
      await sound.player.dispose();
    }
    _sounds.clear();
    _initialized = false;
  }

  // ─── Sound Generation ───────────────────────────────────────────

  /// Generate a WAV file as raw bytes for the given sound type.
  Uint8List _generateSound(CalmSoundType type) {
    final numSamples = _sampleRate * _durationSeconds;
    final pcmData = Float64List(numSamples);
    final rng = Random();

    switch (type) {
      case CalmSoundType.whiteNoise:
        _generateBrownNoise(pcmData, rng);
        break;
      case CalmSoundType.rain:
        _generateRain(pcmData, rng);
        break;
      case CalmSoundType.ocean:
        _generateOcean(pcmData, rng);
        break;
      case CalmSoundType.forest:
        _generateForest(pcmData, rng);
        break;
    }

    // Apply gentle fade-in/out to avoid clicks when looping
    _applyFadeEdges(pcmData);

    return _encodeWav(pcmData);
  }

  /// Brown noise — deep, warm, and relaxing.
  /// Generated by integrating white noise (1/f² spectrum).
  /// Much more pleasant than white noise for relaxation.
  void _generateBrownNoise(Float64List data, Random rng) {
    double brown = 0.0;
    const leak = 0.02; // How quickly it drifts back to center

    for (int i = 0; i < data.length; i++) {
      final white = (rng.nextDouble() * 2 - 1) * 0.15;
      brown += white;
      // Gentle leak to prevent drift
      brown -= brown * leak;
      // Clamp and normalize
      data[i] = brown.clamp(-0.9, 0.9);
    }
  }

  /// Rain: brown noise base + layered soft raindrop transients.
  /// Creates a cozy, steady rainfall ambience.
  void _generateRain(Float64List data, Random rng) {
    // Layer 1: Brown noise base (steady rainfall drone)
    double brown = 0.0;
    for (int i = 0; i < data.length; i++) {
      final white = (rng.nextDouble() * 2 - 1) * 0.08;
      brown += white;
      brown -= brown * 0.01;
      data[i] = brown.clamp(-0.5, 0.5) * 0.6;
    }

    // Layer 2: Individual raindrop hits with soft, natural decay
    for (int i = 0; i < data.length; i++) {
      // ~15-30 drops per second for medium rain
      if (rng.nextDouble() < 0.025) {
        final burstLen = 300 + rng.nextInt(1200); // 7ms - 34ms
        // Varied intensity — most drops are soft, occasional heavier ones
        final amplitude = 0.08 + rng.nextDouble() * 0.35;
        for (int j = 0; j < burstLen && i + j < data.length; j++) {
          // Natural exponential decay
          final decay = exp(-j / (burstLen * 0.3));
          // Add slight randomness to each drop's texture
          final texture = (rng.nextDouble() * 2 - 1) * 0.3;
          data[i + j] += amplitude * decay * (1.0 + texture);
        }
      }
    }

    // Soft clip
    for (int i = 0; i < data.length; i++) {
      data[i] = data[i].clamp(-0.8, 0.8);
    }
  }

  /// Ocean: brown noise with slow, rhythmic wave modulation.
  /// Simulates the soothing ebb and flow of waves on a shore.
  void _generateOcean(Float64List data, Random rng) {
    // Layer 1: Deep brown noise drone
    double brown = 0.0;
    final drone = Float64List(data.length);
    for (int i = 0; i < data.length; i++) {
      final white = (rng.nextDouble() * 2 - 1) * 0.06;
      brown += white;
      brown -= brown * 0.008;
      drone[i] = brown.clamp(-0.6, 0.6);
    }

    // Layer 2: Wave modulation — slow rise, faster fall (like real waves)
    for (int i = 0; i < data.length; i++) {
      final t = i / _sampleRate;

      // Primary wave ~0.08 Hz (12.5 sec cycle)
      final wave1 = sin(2 * pi * 0.08 * t);
      // Secondary wave ~0.14 Hz for variation
      final wave2 = sin(2 * pi * 0.14 * t + 1.5);

      // Asymmetric wave shape: slow rise, faster fall
      final combined = (wave1 * 0.7 + wave2 * 0.3);
      // Map [-1,1] to [0.2, 1.0] with a curve
      final env = 0.2 + 0.8 * ((combined + 1.0) / 2.0);

      // Wave crash: add extra noise burst at wave peaks
      double crash = 0.0;
      if (combined > 0.7) {
        crash = (rng.nextDouble() * 2 - 1) * (combined - 0.7) * 1.5;
      }

      data[i] = drone[i] * env + crash * 0.3;
    }

    // Soft clip
    for (int i = 0; i < data.length; i++) {
      data[i] = data[i].clamp(-0.75, 0.75);
    }
  }

  /// Forest: layered brown noise with gentle wind, soft rustling,
  /// and subtle high-frequency textures like distant birds.
  void _generateForest(Float64List data, Random rng) {
    // Layer 1: Deep brown noise (wind through trees)
    double brown = 0.0;
    for (int i = 0; i < data.length; i++) {
      final white = (rng.nextDouble() * 2 - 1) * 0.05;
      brown += white;
      brown -= brown * 0.006;
      data[i] = brown.clamp(-0.5, 0.5) * 0.5;
    }

    // Layer 2: Gentle wind modulation
    for (int i = 0; i < data.length; i++) {
      final t = i / _sampleRate;
      // Very slow, gentle wind swells
      final wind = sin(2 * pi * 0.06 * t) * 0.5 +
                   sin(2 * pi * 0.11 * t + 2.0) * 0.3 +
                   sin(2 * pi * 0.04 * t + 4.0) * 0.2;
      final windEnv = 0.7 + 0.3 * wind;
      data[i] *= windEnv;
    }

    // Layer 3: Soft leaf rustling (filtered higher-frequency bursts)
    for (int i = 0; i < data.length; i++) {
      if (rng.nextDouble() < 0.01) {
        final burstLen = 600 + rng.nextInt(2000);
        final amplitude = 0.04 + rng.nextDouble() * 0.12;

        // Use a smoothed noise burst for rustling
        double rustleVal = 0.0;
        for (int j = 0; j < burstLen && i + j < data.length; j++) {
          final decay = exp(-j / (burstLen * 0.25));
          final noise = (rng.nextDouble() * 2 - 1);
          // Smooth the rustle with exponential moving average
          rustleVal = rustleVal * 0.7 + noise * 0.3;
          data[i + j] += rustleVal * amplitude * decay;
        }
      }
    }

    // Soft clip
    for (int i = 0; i < data.length; i++) {
      data[i] = data[i].clamp(-0.7, 0.7);
    }
  }

  /// Apply short fade-in and fade-out to prevent clicks when looping.
  void _applyFadeEdges(Float64List data) {
    final fadeLen = (_sampleRate * 0.05).toInt(); // 50ms fade
    if (fadeLen * 2 >= data.length) return;

    // Fade in
    for (int i = 0; i < fadeLen; i++) {
      final factor = i / fadeLen;
      // Smooth ease-in curve
      data[i] *= factor * factor * (3 - 2 * factor);
    }

    // Fade out
    for (int i = 0; i < fadeLen; i++) {
      final idx = data.length - 1 - i;
      final factor = i / fadeLen;
      data[idx] *= factor * factor * (3 - 2 * factor);
    }
  }

  /// Encode PCM Float64 samples into a 16-bit WAV file byte array.
  Uint8List _encodeWav(Float64List samples) {
    final dataSize = samples.length * 2; // 16-bit = 2 bytes per sample
    final fileSize = 44 + dataSize;
    final buffer = ByteData(fileSize);
    int offset = 0;

    // RIFF header
    _writeString(buffer, offset, 'RIFF');
    offset += 4;
    buffer.setUint32(offset, fileSize - 8, Endian.little);
    offset += 4;
    _writeString(buffer, offset, 'WAVE');
    offset += 4;

    // fmt subchunk
    _writeString(buffer, offset, 'fmt ');
    offset += 4;
    buffer.setUint32(offset, 16, Endian.little); // subchunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM format
    offset += 2;
    buffer.setUint16(offset, _channels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, _sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, _sampleRate * _channels * _bitsPerSample ~/ 8, Endian.little);
    offset += 4;
    buffer.setUint16(offset, _channels * _bitsPerSample ~/ 8, Endian.little);
    offset += 2;
    buffer.setUint16(offset, _bitsPerSample, Endian.little);
    offset += 2;

    // data subchunk
    _writeString(buffer, offset, 'data');
    offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // PCM samples: convert Float64 [-1.0, 1.0] to Int16
    for (int i = 0; i < samples.length; i++) {
      final intVal = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
      buffer.setInt16(offset, intVal, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  void _writeString(ByteData buf, int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      buf.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}