import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/requests_repository.dart';
import 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final RequestsRepository _repository;

  RequestsCubit(this._repository) : super(const RequestsInitial());

  Future<void> loadRequests(GetRequestsParams params) async {
    emit(const RequestsLoading());
    final result = await _repository.getRequests(params);
    result.fold(
      (failure) => emit(RequestsError(failure.message)),
      (requests) => emit(RequestsLoaded(requests)),
    );
  }

  Future<void> createRequest(CreateRequestParams params) async {
    emit(const RequestCreating());
    final result = await _repository.createRequest(params);
    result.fold(
      (failure) => emit(RequestCreateError(failure.message)),
      (request) => emit(RequestCreated(request)),
    );
  }
}
