import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/data/models/user_profile_model.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';

// Events
abstract class UserProfileEvent {}

class FetchUserProfile extends UserProfileEvent {
  final String userId;
  FetchUserProfile(this.userId);
}

class ToggleLikeInProfile extends UserProfileEvent {
  final String postId;
  ToggleLikeInProfile(this.postId);
}

class DeletePostInProfile extends UserProfileEvent {
  final String postId;
  DeletePostInProfile(this.postId);
}

// States
abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final PublicUserModel user;
  final List<PostEntity> posts;
  final int totalPosts;

  UserProfileLoaded({
    required this.user,
    required this.posts,
    required this.totalPosts,
  });
}

class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}

// BLoC
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final PostRemoteDataSource remoteDataSource;

  UserProfileBloc({required this.remoteDataSource})
    : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<ToggleLikeInProfile>(_onToggleLike);
    on<DeletePostInProfile>(_onDeletePost);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final response = await remoteDataSource.getUserProfile(event.userId);
      emit(
        UserProfileLoaded(
          user: response.user,
          posts: response.posts.map((e) => e.toEntity()).toList(),
          totalPosts: response.totalPosts,
        ),
      );
    } catch (e) {
      emit(UserProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeInProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
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

        emit(
          UserProfileLoaded(
            user: currentState.user,
            posts: posts,
            totalPosts: currentState.totalPosts,
          ),
        );

        try {
          if (isLiked) {
            await remoteDataSource.unlikePost(event.postId);
          } else {
            await remoteDataSource.likePost(event.postId);
          }
        } catch (e) {
          print('Failed to toggle like: $e');
        }
      }
    }
  }

  Future<void> _onDeletePost(
    DeletePostInProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is UserProfileLoaded) {
      final currentState = state as UserProfileLoaded;
      final posts = List<PostEntity>.from(currentState.posts);
      final index = posts.indexWhere((element) => element.id == event.postId);

      if (index != -1) {
        // Optimistic update: remove from UI first
        posts.removeAt(index);
        emit(
          UserProfileLoaded(
            user: currentState.user,
            posts: posts,
            totalPosts: currentState.totalPosts - 1,
          ),
        );

        try {
          await remoteDataSource.deletePost(event.postId);
          print('UserProfileBloc: Post deleted successfully');
        } catch (e) {
          print('UserProfileBloc: Failed to delete post: $e');
        }
      }
    }
  }
}
