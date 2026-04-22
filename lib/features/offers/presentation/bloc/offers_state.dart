import 'package:equatable/equatable.dart';
import '../../domain/entities/offer_entity.dart';

abstract class OffersState extends Equatable {
  const OffersState();
  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState { const OffersInitial(); }
class OffersLoading extends OffersState { const OffersLoading(); }

class OffersLoaded extends OffersState {
  final List<OfferEntity> offers;
  const OffersLoaded(this.offers);
  @override
  List<Object?> get props => [offers];
}

class OffersError extends OffersState {
  final String message;
  const OffersError(this.message);
  @override
  List<Object?> get props => [message];
}

class OfferSubmitting extends OffersState { const OfferSubmitting(); }

class OfferSubmitted extends OffersState {
  final OfferEntity offer;
  const OfferSubmitted(this.offer);
  @override
  List<Object?> get props => [offer];
}

class OfferAccepting extends OffersState { const OfferAccepting(); }

class OfferAccepted extends OffersState {
  final OfferEntity offer;
  const OfferAccepted(this.offer);
  @override
  List<Object?> get props => [offer];
}
