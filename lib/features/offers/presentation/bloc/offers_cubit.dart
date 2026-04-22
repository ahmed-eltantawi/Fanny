import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/offers_repository.dart';
import 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepository _repository;

  OffersCubit(this._repository) : super(const OffersInitial());

  Future<void> loadOffers(String requestId) async {
    emit(const OffersLoading());
    final result = await _repository.getOffers(GetOffersParams(requestId));
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  Future<void> submitOffer(SubmitOfferParams params) async {
    emit(const OfferSubmitting());
    final result = await _repository.submitOffer(params);
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offer) => emit(OfferSubmitted(offer)),
    );
  }

  Future<void> acceptOffer(String offerId) async {
    emit(const OfferAccepting());
    final result = await _repository.acceptOffer(offerId);
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offer) => emit(OfferAccepted(offer)),
    );
  }
}
