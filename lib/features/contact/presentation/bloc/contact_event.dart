import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

class ContactLoadRequested extends ContactEvent {
  const ContactLoadRequested();
}

class ContactSaveRequested extends ContactEvent {
  final ContactEntity contact;
  const ContactSaveRequested(this.contact);
  @override
  List<Object?> get props => [contact];
}