import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/domain/repository/post_repository.dart';

// Events
abstract class CommunityEvent {}

class FetchUserPosts extends CommunityEvent {
  final String userId;
  FetchUserPosts(this.userId);
}

class ToggleLikeEvent extends CommunityEvent {
  final String postId;
  ToggleLikeEvent(this.postId);
}

class CreatePostEvent extends CommunityEvent {
  final String content;
  final List<String> imageLink;
  final List<String> tags;
  final String? diseaseLink;

  CreatePostEvent({
    required this.content,
    required this.imageLink,
    required this.tags,
    this.diseaseLink,
  });
}

// States
abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<PostEntity> posts;
  CommunityLoaded(this.posts);
}

class CommunityError extends CommunityState {
  final String message;
  CommunityError(this.message);
}

class CommunityPostCreated extends CommunityState {}

// BLoC
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final PostRepository postRepository;

  CommunityBloc({required this.postRepository}) : super(CommunityInitial()) {
    on<FetchUserPosts>(_onFetchUserPosts);
    on<ToggleLikeEvent>(_onToggleLike);
    on<CreatePostEvent>(_onCreatePost);
  }

  Future<void> _onFetchUserPosts(
    FetchUserPosts event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      final posts = await postRepository.getUserPosts(event.userId);
      emit(CommunityLoaded(posts));
    } catch (e) {
      emit(CommunityError(e.toString()));
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
          tags: post.tags,
          likeNumber: newLikeCount,
          liked: !isLiked,
          commentNumber: post.commentNumber,
          shareNumber: post.shareNumber,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );

        emit(CommunityLoaded(posts));

        try {
          if (isLiked) {
            await postRepository.unlikePost(event.postId);
          } else {
            await postRepository.likePost(event.postId);
          }
        } catch (e) {
          // Revert if failed
          posts[index] = post;
          emit(CommunityLoaded(posts));
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
      print('CommunityBloc: Calling createPost API');
      await postRepository.createPost(
        content: event.content,
        imageLink: event.imageLink,
        tags: event.tags,
        diseaseLink: event.diseaseLink,
      );
      print('CommunityBloc: Post created successfully');
      emit(CommunityPostCreated());
    } catch (e) {
      print('CommunityBloc: Error creating post: $e');
      emit(CommunityError(e.toString()));
    }
  }
}
