import 'package:equatable/equatable.dart';
import '../../../../core/config/brand_config.dart';

abstract class BrandEvent extends Equatable {
  const BrandEvent();
  @override
  List<Object?> get props => [];
}

class BrandLoadRequested extends BrandEvent {
  const BrandLoadRequested();
}

class BrandSaveRequested extends BrandEvent {
  final BrandConfig brand;
  const BrandSaveRequested(this.brand);
  @override
  List<Object?> get props => [brand];
}