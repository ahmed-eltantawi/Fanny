import 'package:equatable/equatable.dart';
import '../../domain/entities/request_entity.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();
  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState { const RequestsInitial(); }
class RequestsLoading extends RequestsState { const RequestsLoading(); }

class RequestsLoaded extends RequestsState {
  final List<RequestEntity> requests;
  const RequestsLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

class RequestsError extends RequestsState {
  final String message;
  const RequestsError(this.message);
  @override
  List<Object?> get props => [message];
}

class RequestCreating extends RequestsState { const RequestCreating(); }

class RequestCreated extends RequestsState {
  final RequestEntity request;
  const RequestCreated(this.request);
  @override
  List<Object?> get props => [request];
}

class RequestCreateError extends RequestsState {
  final String message;
  const RequestCreateError(this.message);
  @override
  List<Object?> get props => [message];
}
