import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/load_contact_usecase.dart';
import '../../domain/usecases/save_contact_usecase.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final LoadContactUseCase _load;
  final SaveContactUseCase _save;

  ContactBloc({
    required LoadContactUseCase loadContact,
    required SaveContactUseCase saveContact,
  })  : _load = loadContact,
        _save = saveContact,
        super(const ContactInitial()) {
    on<ContactLoadRequested>(_onLoad);
    on<ContactSaveRequested>(_onSave);
  }

  Future<void> _onLoad(
    ContactLoadRequested event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      final contact = await _load();
      emit(ContactLoaded(contact));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onSave(
    ContactSaveRequested event,
    Emitter<ContactState> emit,
  ) async {
    emit(ContactSaving(event.contact));
    try {
      await _save(event.contact);
      emit(ContactSaved(event.contact));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}