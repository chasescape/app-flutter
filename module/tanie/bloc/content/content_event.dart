import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadContentEvent extends ContentEvent {
  const LoadContentEvent();
}

class RefreshContentEvent extends ContentEvent {
  const RefreshContentEvent();
}

class LoadDetailEvent extends ContentEvent {
  final String itemId;

  const LoadDetailEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class CreateContentEvent extends ContentEvent {
  final Map<String, dynamic> data;

  const CreateContentEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteContentEvent extends ContentEvent {
  final String itemId;

  const DeleteContentEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class StartLoadingEvent extends ContentEvent {
  const StartLoadingEvent();
}

class StopLoadingEvent extends ContentEvent {
  const StopLoadingEvent();
}
