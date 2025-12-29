import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/domain/repository/post_repository.dart';

// Events
abstract class CommunityEvent {}

class FetchPosts extends CommunityEvent {
  final String keyword;
  final bool isRefresh;
  FetchPosts({this.keyword = '', this.isRefresh = false});
}

class LoadMorePosts extends CommunityEvent {}

class FetchMyPosts extends CommunityEvent {}

class ToggleLikeEvent extends CommunityEvent {
  final String postId;
  ToggleLikeEvent(this.postId);
}

class DeletePostEvent extends CommunityEvent {
  final String postId;
  DeletePostEvent(this.postId);
}

class CreatePostEvent extends CommunityEvent {
  final String content;
  final List<String> imageLink;
  final List<String> tags;
  final String? diseaseLink;
  final String? scanHistoryId;
  final String? prefilledImageUrl;
  final List<XFile> imagesToUpload;

  CreatePostEvent({
    required this.content,
    required this.imageLink,
    required this.tags,
    this.diseaseLink,
    this.scanHistoryId,
    this.prefilledImageUrl,
    this.imagesToUpload = const [],
  });
}

// States
abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<PostEntity> posts;
  final int page;
  final bool hasReachedMax;
  final String keyword;

  CommunityLoaded({
    required this.posts,
    this.page = 1,
    this.hasReachedMax = false,
    this.keyword = '',
  });

  CommunityLoaded copyWith({
    List<PostEntity>? posts,
    int? page,
    bool? hasReachedMax,
    String? keyword,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      keyword: keyword ?? this.keyword,
    );
  }
}

class CommunityError extends CommunityState {
  final String message;
  CommunityError(this.message);
}

class CommunityPostCreated extends CommunityState {}

// BLoC
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final PostRepository postRepository;
  static const int _limit = 10;

  CommunityBloc({required this.postRepository}) : super(CommunityInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<FetchMyPosts>(_onFetchMyPosts);
    on<ToggleLikeEvent>(_onToggleLike);
    on<DeletePostEvent>(_onDeletePost);
    on<CreatePostEvent>(_onCreatePost);
  }

  Future<void> _onFetchPosts(
    FetchPosts event,
    Emitter<CommunityState> emit,
  ) async {
    if (event.isRefresh || state is! CommunityLoaded) {
      emit(CommunityLoading());
    }

    try {
      final posts = event.keyword.isEmpty
          ? await postRepository.getAllPosts(page: 1, limit: _limit)
          : await postRepository.searchPosts(
              keyword: event.keyword,
              page: 1,
              limit: _limit,
            );

      emit(
        CommunityLoaded(
          posts: posts,
          page: 1,
          hasReachedMax: posts.length < _limit,
          keyword: event.keyword,
        ),
      );
    } catch (e) {
      emit(CommunityError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.page + 1;
        final newPosts = currentState.keyword.isEmpty
            ? await postRepository.getAllPosts(page: nextPage, limit: _limit)
            : await postRepository.searchPosts(
                keyword: currentState.keyword,
                page: nextPage,
                limit: _limit,
              );

        if (newPosts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              posts: List.of(currentState.posts)..addAll(newPosts),
              page: nextPage,
              hasReachedMax: newPosts.length < _limit,
            ),
          );
        }
      } catch (e) {
        // Don't emit Error state required for LoadMore effectively?
        // Usually showing a snackbar is handled in UI listener.
        // We might want to keep current state but maybe emit a side effect.
        // For simplicity, we keep the state (ignore error) or emit error if we want full screen error (not ideal).
        // Let's just print log for now or emit nothing.
        print('Error loading more posts: $e');
      }
    }
  }

  Future<void> _onFetchMyPosts(
    FetchMyPosts event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      final posts = await postRepository.getMyPosts();
      emit(
        CommunityLoaded(posts: posts, hasReachedMax: true),
      ); // No pagination for My Posts yet
    } catch (e) {
      emit(CommunityError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      final posts = List<PostEntity>.from(currentState.posts);
      final index = posts.indexWhere((element) => element.id == event.postId);

      if (index != -1) {
        // Remove post from UI
        posts.removeAt(index);
        emit(currentState.copyWith(posts: posts));

        try {
          await postRepository.deletePost(event.postId);
          print('Debug: Post deleted successfully');
        } catch (e) {
          print('Debug: Failed to delete post: $e');
          // Refresh posts if failed
          add(FetchPosts());
        }
      }
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<CommunityState> emit,
  ) async {
    print('Debug: ToggleLikeEvent received for post ${event.postId}');
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      final posts = List<PostEntity>.from(currentState.posts);
      final index = posts.indexWhere((element) => element.id == event.postId);

      if (index != -1) {
        final post = posts[index];
        final isLiked = post.liked;
        final newLikeCount = isLiked
            ? post.likeNumber - 1
            : post.likeNumber + 1;

        // Optimistic update
        posts[index] = PostEntity(
          id: post.id,
          userId: post.userId,
          fullName: post.fullName,
          avatar: post.avatar,
          content: post.content,
          imageLink: post.imageLink,
          diseaseLink: post.diseaseLink,
          diseaseName: post.diseaseName,
          diseaseDescription: post.diseaseDescription,
          diseaseSolution: post.diseaseSolution,
          diseaseImageLink: post.diseaseImageLink,
          scanHistoryId: post.scanHistoryId,
          tags: post.tags,
          likeNumber: newLikeCount,
          liked: !isLiked,
          isMyPost: post.isMyPost,
          commentNumber: post.commentNumber,
          commentList: post.commentList,
          shareNumber: post.shareNumber,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );

        emit(currentState.copyWith(posts: posts));

        try {
          if (isLiked) {
            await postRepository.unlikePost(event.postId);
          } else {
            await postRepository.likePost(event.postId);
          }
        } catch (e) {
          // Revert if failed
          posts[index] = post;
          emit(currentState.copyWith(posts: posts));
        }
      }
    }
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<CommunityState> emit,
  ) async {
    print('CommunityBloc: Received CreatePostEvent');
    emit(CommunityLoading());
    try {
      // Collect all image URLs
      List<String> allImageUrls = [];

      // Add prefilled image URL first (scan image)
      if (event.prefilledImageUrl != null &&
          event.prefilledImageUrl!.isNotEmpty) {
        print('CommunityBloc: Adding prefilled scan image URL');
        allImageUrls.add(event.prefilledImageUrl!);
      }

      // Upload user-selected images to Supabase
      if (event.imagesToUpload.isNotEmpty) {
        print(
          'CommunityBloc: Uploading ${event.imagesToUpload.length} images to Supabase',
        );
        for (final image in event.imagesToUpload) {
          final bytes = await image.readAsBytes();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'post_${timestamp}_${image.name}';

          final url = await SupabaseService.uploadFileFromBytes(
            bucketName: 'uploads',
            fileBytes: bytes,
            fileName: fileName,
          );
          print('CommunityBloc: Uploaded image: $url');
          allImageUrls.add(url);
        }
      }

      print(
        'CommunityBloc: Calling createPost API with ${allImageUrls.length} images',
      );
      await postRepository.createPost(
        content: event.content,
        imageLink: allImageUrls,
        tags: event.tags,
        diseaseLink: event.diseaseLink,
        scanHistoryId: event.scanHistoryId,
      );
      print('CommunityBloc: Post created successfully');
      emit(CommunityPostCreated());
      // Refresh list
      add(FetchPosts(isRefresh: true));
    } catch (e) {
      print('CommunityBloc: Error creating post: $e');
      emit(CommunityError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
