import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tanie/tanie/bloc/content/content_event.dart';
import 'package:tanie/tanie/bloc/content/content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc() : super(const ContentState()) {
    on<LoadContentEvent>(_onLoadContent);
    on<RefreshContentEvent>(_onRefreshContent);
    on<LoadDetailEvent>(_onLoadDetail);
    on<CreateContentEvent>(_onCreateContent);
    on<DeleteContentEvent>(_onDeleteContent);
    on<StartLoadingEvent>(_onStartLoading);
    on<StopLoadingEvent>(_onStopLoading);
  }

  Future<void> _onStartLoading(
    StartLoadingEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
  }

  Future<void> _onStopLoading(
    StopLoadingEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onLoadContent(
    LoadContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockItems = List.generate(
        10,
        (index) => ContentItem(
          id: 'item_$index',
          title: 'Photo Reflection ${index + 1}',
          imageUrl: 'https://picsum.photos/300/300?random=$index',
          description: 'A beautiful photo reflection with AI analysis.',
          createdAt: DateTime.now().subtract(Duration(days: index)),
          likes: (index * 12) % 100,
          tags: ['reflection', 'ai', 'photo'],
        ),
      );

      emit(state.copyWith(
        isLoading: false,
        items: mockItems,
        hasReachedMax: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load content',
      ));
    }
  }

  Future<void> _onRefreshContent(
    RefreshContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockItems = List.generate(
        10,
        (index) => ContentItem(
          id: 'item_${index}_refresh',
          title: 'Photo Reflection ${index + 1}',
          imageUrl: 'https://picsum.photos/300/300?random=${index + 100}',
          description: 'A beautiful photo reflection with AI analysis.',
          createdAt: DateTime.now().subtract(Duration(minutes: index)),
          likes: (index * 15) % 100,
          tags: ['reflection', 'ai', 'photo'],
        ),
      );

      emit(state.copyWith(
        isLoading: false,
        items: mockItems,
        hasReachedMax: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh content',
      ));
    }
  }

  Future<void> _onLoadDetail(
    LoadDetailEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final item = ContentItem(
        id: event.itemId,
        title: 'Photo Reflection ${event.itemId}',
        imageUrl: 'https://picsum.photos/600/600?random=${event.itemId}',
        description: 'A beautiful photo reflection with AI analysis. This image has been processed using advanced AI algorithms to provide deep insights and reflections.',
        createdAt: DateTime.now(),
        likes: 42,
        tags: ['reflection', 'ai', 'photo', 'analysis'],
      );

      emit(state.copyWith(
        isLoading: false,
        selectedItem: item,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load detail',
      ));
    }
  }

  Future<void> _onCreateContent(
    CreateContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final newItem = ContentItem(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        title: event.data['title'] ?? 'New Reflection',
        imageUrl: event.data['imageUrl'],
        description: event.data['description'],
        createdAt: DateTime.now(),
        likes: 0,
        tags: event.data['tags'] ?? [],
      );

      emit(state.copyWith(
        isLoading: false,
        items: [newItem, ...state.items],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create content',
      ));
    }
  }

  Future<void> _onDeleteContent(
    DeleteContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedItems = state.items.where((item) => item.id != event.itemId).toList();

      emit(state.copyWith(
        isLoading: false,
        items: updatedItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete content',
      ));
    }
  }
}
