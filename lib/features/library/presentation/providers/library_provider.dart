import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/library_remote_ds.dart';
import '../../data/repositories/library_repository_impl.dart';
import '../../domain/entities/book_item.dart';
import '../../domain/entities/healing_audio_track.dart';
import '../../domain/entities/video_workshop_item.dart';
import '../../domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl(
    LibraryRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final booksAndMaterialsProvider = FutureProvider<List<BookItem>>((ref) async {
  return await ref.watch(libraryRepositoryProvider).getBooksAndMaterials();
});

final bookDetailProvider = FutureProvider.family<BookItem, String>((ref, id) async {
  return await ref.watch(libraryRepositoryProvider).getBookDetail(id);
});

final audioTracksProvider = FutureProvider<List<HealingAudioTrack>>((ref) async {
  return await ref.watch(libraryRepositoryProvider).getAudioTracks();
});

final videoWorkshopsProvider = FutureProvider<List<VideoWorkshopItem>>((ref) async {
  return await ref.watch(libraryRepositoryProvider).getVideoWorkshops();
});
