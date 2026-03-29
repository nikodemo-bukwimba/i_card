import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/contacts_book_repository.dart';
import 'contacts_book_event.dart';
import 'contacts_book_state.dart';

class ContactsBookBloc extends Bloc<ContactsBookEvent, ContactsBookState> {
  final ContactsBookRepository _repo;

  ContactsBookBloc({required ContactsBookRepository repo})
      : _repo = repo,
        super(const ContactsBookInitial()) {
    on<ContactsBookLoadRequested>(_onLoad);
    on<ContactsBookDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ContactsBookLoadRequested event,
    Emitter<ContactsBookState> emit,
  ) async {
    emit(const ContactsBookLoading());
    try {
      final contacts = await _repo.loadAll();
      // Newest first
      contacts.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      emit(ContactsBookLoaded(contacts));
    } catch (e) {
      emit(ContactsBookError(e.toString()));
    }
  }

  Future<void> _onDelete(
    ContactsBookDeleteRequested event,
    Emitter<ContactsBookState> emit,
  ) async {
    try {
      await _repo.delete(event.id);
      final contacts = await _repo.loadAll();
      contacts.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      emit(ContactsBookLoaded(contacts));
    } catch (e) {
      emit(ContactsBookError(e.toString()));
    }
  }
}