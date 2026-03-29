import 'package:equatable/equatable.dart';

abstract class ContactsBookEvent extends Equatable {
  const ContactsBookEvent();
  @override List<Object?> get props => [];
}

class ContactsBookLoadRequested extends ContactsBookEvent {
  const ContactsBookLoadRequested();
}

class ContactsBookDeleteRequested extends ContactsBookEvent {
  final String id;
  const ContactsBookDeleteRequested(this.id);
  @override List<Object?> get props => [id];
}