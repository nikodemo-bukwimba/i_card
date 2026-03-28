import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {
  const ContactInitial();
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class ContactLoaded extends ContactState {
  final ContactEntity contact;
  const ContactLoaded(this.contact);
  @override
  List<Object?> get props => [contact];
}

class ContactSaving extends ContactState {
  final ContactEntity contact;
  const ContactSaving(this.contact);
  @override
  List<Object?> get props => [contact];
}

class ContactSaved extends ContactState {
  final ContactEntity contact;
  const ContactSaved(this.contact);
  @override
  List<Object?> get props => [contact];
}

class ContactError extends ContactState {
  final String message;
  const ContactError(this.message);
  @override
  List<Object?> get props => [message];
}