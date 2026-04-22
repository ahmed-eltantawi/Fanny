import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Generic use-case contract.
/// [Type] = return type on success, [Params] = input parameter object.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters.
abstract class NoParamUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Sentinel class used when a use case takes no parameters.
class NoParams {
  const NoParams();
}
