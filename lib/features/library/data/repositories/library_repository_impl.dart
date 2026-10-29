import '../../domain/entities/book_item.dart';
import '../../domain/entities/healing_audio_track.dart';
import '../../domain/entities/video_workshop_item.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_ds.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BookItem>> getBooksAndMaterials() async {
    return await remoteDataSource.getBooksAndMaterials();
  }

  @override
  Future<BookItem> getBookDetail(String id) async {
    return await remoteDataSource.getBookDetail(id);
  }

  @override
  Future<List<HealingAudioTrack>> getAudioTracks() async {
    return await remoteDataSource.getAudioTracks();
  }

  @override
  Future<List<VideoWorkshopItem>> getVideoWorkshops() async {
    return await remoteDataSource.getVideoWorkshops();
  }
}
