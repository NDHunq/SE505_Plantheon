import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/domain/entities/comment_entity.dart';
import 'package:se501_plantheon/domain/repository/post_repository.dart';

// Events
abstract class PostDetailEvent {}

class FetchPostDetail extends PostDetailEvent {
  final String postId;
  final bool isRefresh;
  FetchPostDetail(this.postId, {this.isRefresh = false});
}

class ToggleLikePostDetail extends PostDetailEvent {
  final String postId;
  ToggleLikePostDetail(this.postId);
}

class CreateCommentEvent extends PostDetailEvent {
  final String postId;
  final String content;
  final String? parentId;

  CreateCommentEvent(this.postId, this.content, {this.parentId});
}

class ToggleLikeComment extends PostDetailEvent {
  final String postId;
  final String commentId;
  ToggleLikeComment(this.postId, this.commentId);
}

// States
abstract class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  final PostEntity post;
  PostDetailLoaded(this.post);
}

class PostDetailError extends PostDetailState {
  final String message;
  PostDetailError(this.message);
}

// BLoC
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostRepository postRepository;

  PostDetailBloc({required this.postRepository}) : super(PostDetailInitial()) {
    on<FetchPostDetail>(_onFetchPostDetail);
    on<ToggleLikePostDetail>(_onToggleLikePostDetail);
    on<CreateCommentEvent>(_onCreateComment);
    on<ToggleLikeComment>(_onToggleLikeComment);
  }

  Future<void> _onFetchPostDetail(
    FetchPostDetail event,
    Emitter<PostDetailState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(PostDetailLoading());
    }
    try {
      final post = await postRepository.getPostDetail(event.postId);
      emit(PostDetailLoaded(post));
    } catch (e) {
      emit(PostDetailError(e.toString()));
    }
  }

  Future<void> _onToggleLikePostDetail(
    ToggleLikePostDetail event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final post = currentState.post;
      final isLiked = post.liked;
      final newLikeCount = isLiked ? post.likeNumber - 1 : post.likeNumber + 1;

      // Optimistic update
      final updatedPost = PostEntity(
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

      emit(PostDetailLoaded(updatedPost));

      try {
        if (isLiked) {
          await postRepository.unlikePost(event.postId);
        } else {
          await postRepository.likePost(event.postId);
        }
      } catch (e) {
        // Revert optimistic update if needed, or show error
        // For now, we just reload the post to be safe
        add(FetchPostDetail(event.postId));
      }
    }
  }

  Future<void> _onCreateComment(
    CreateCommentEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final post = currentState.post;

      // Create temp comment
      final tempComment = CommentEntity(
        id: DateTime.now().toString(), // Temp ID
        postId: event.postId,
        userId: '4849fefc-fdf2-441f-bb5e-8318d3904b94', // Hardcoded from token
        parentId: event.parentId,
        fullName: 'Me', // Placeholder
        avatar: '', // Placeholder
        content: event.content,
        likeNumber: 0,
        isLike: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isMe: true,
      );

      // Update post locally
      final updatedCommentList = List<CommentEntity>.from(
        post.commentList ?? [],
      )..insert(0, tempComment);

      final updatedPost = PostEntity(
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
        likeNumber: post.likeNumber,
        liked: post.liked,
        isMyPost: post.isMyPost,
        commentNumber: post.commentNumber + 1,
        commentList: updatedCommentList,
        shareNumber: post.shareNumber,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      // Emit optimistic state
      emit(PostDetailLoaded(updatedPost));

      try {
        await postRepository.createComment(
          event.postId,
          event.content,
          parentId: event.parentId,
        );
        // Fetch to sync with server (get real ID, etc.)
        add(FetchPostDetail(event.postId, isRefresh: true));
      } catch (e) {
        // Revert to original state on failure
        emit(PostDetailLoaded(post));
        emit(PostDetailError(e.toString()));
      }
    }
  }

  Future<void> _onToggleLikeComment(
    ToggleLikeComment event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final post = currentState.post;

      if (post.commentList == null) return;

      // Find the comment and toggle like
      final updatedCommentList = post.commentList!.map((comment) {
        if (comment.id == event.commentId) {
          final newIsLike = !comment.isLike;
          final newLikeNumber = newIsLike
              ? comment.likeNumber + 1
              : comment.likeNumber - 1;
          return CommentEntity(
            id: comment.id,
            postId: comment.postId,
            userId: comment.userId,
            parentId: comment.parentId,
            fullName: comment.fullName,
            avatar: comment.avatar,
            content: comment.content,
            likeNumber: newLikeNumber,
            isLike: newIsLike,
            createdAt: comment.createdAt,
            updatedAt: comment.updatedAt,
            isMe: comment.isMe,
          );
        }
        return comment;
      }).toList();

      // Find original comment to determine API call
      final originalComment = post.commentList!.firstWhere(
        (c) => c.id == event.commentId,
      );

      // Optimistic update
      final updatedPost = PostEntity(
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
        likeNumber: post.likeNumber,
        liked: post.liked,
        isMyPost: post.isMyPost,
        commentNumber: post.commentNumber,
        commentList: updatedCommentList,
        shareNumber: post.shareNumber,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      emit(PostDetailLoaded(updatedPost));

      try {
        if (originalComment.isLike) {
          await postRepository.unlikeComment(event.commentId);
        } else {
          await postRepository.likeComment(event.commentId);
        }
      } catch (e) {
        // Revert on failure
        emit(PostDetailLoaded(post));
      }
    }
  }
}