import 'package:equatable/equatable.dart';
import '../../../../core/config/brand_config.dart';

abstract class BrandState extends Equatable {
  const BrandState();
  @override
  List<Object?> get props => [];
}

class BrandInitial extends BrandState {
  const BrandInitial();
}

class BrandLoading extends BrandState {
  const BrandLoading();
}

class BrandLoaded extends BrandState {
  final BrandConfig brand;
  const BrandLoaded(this.brand);
  @override
  List<Object?> get props => [brand];
}

class BrandSaved extends BrandState {
  final BrandConfig brand;
  const BrandSaved(this.brand);
  @override
  List<Object?> get props => [brand];
}

class BrandError extends BrandState {
  final String message;
  const BrandError(this.message);
  @override
  List<Object?> get props => [message];
}