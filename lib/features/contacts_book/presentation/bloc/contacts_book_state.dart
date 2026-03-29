import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_contact.dart';

abstract class ContactsBookState extends Equatable {
  const ContactsBookState();
  @override List<Object?> get props => [];
}

class ContactsBookInitial extends ContactsBookState {
  const ContactsBookInitial();
}

class ContactsBookLoading extends ContactsBookState {
  const ContactsBookLoading();
}

class ContactsBookLoaded extends ContactsBookState {
  final List<SavedContact> contacts;
  const ContactsBookLoaded(this.contacts);
  @override List<Object?> get props => [contacts];
}

class ContactsBookError extends ContactsBookState {
  final String message;
  const ContactsBookError(this.message);
  @override List<Object?> get props => [message];
}