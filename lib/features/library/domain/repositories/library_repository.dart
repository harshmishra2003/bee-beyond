import '../entities/book_item.dart';
import '../entities/healing_audio_track.dart';
import '../entities/video_workshop_item.dart';

abstract class LibraryRepository {
  Future<List<BookItem>> getBooksAndMaterials();
  Future<BookItem> getBookDetail(String id);
  Future<List<HealingAudioTrack>> getAudioTracks();
  Future<List<VideoWorkshopItem>> getVideoWorkshops();
}
