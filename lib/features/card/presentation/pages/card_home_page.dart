import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../brand/presentation/pages/edit_page.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/domain/usecases/build_vcard_usecase.dart';
import '../../../contact/presentation/bloc/contact_bloc.dart';
import '../../../contact/presentation/bloc/contact_event.dart';
import '../../../contact/presentation/bloc/contact_state.dart';
import '../../../qr/presentation/widgets/qr_section.dart';
import '../widgets/card_widget.dart';
import '../widgets/quick_links.dart';

class CardHomePage extends StatefulWidget {
  final BrandConfig brand;
  final ValueChanged<BrandConfig> onBrandUpdated;

  const CardHomePage({
    super.key,
    required this.brand,
    required this.onBrandUpdated,
  });

  @override
  State<CardHomePage> createState() => _CardHomePageState();
}

class _CardHomePageState extends State<CardHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: AppConstants.fadeInDuration);
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    context.read<ContactBloc>().add(const ContactLoadRequested());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEdit(ContactEntity contact) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditPage(contact: contact, brand: widget.brand),
      ),
    );
    if (result == null || !mounted) return;

    final updatedContact = result['contact'] as ContactEntity;
    final updatedBrand   = result['brand']   as BrandConfig;

    // Persist contact via BLoC
    context.read<ContactBloc>().add(ContactSaveRequested(updatedContact));

    // Persist brand + notify parent so MaterialApp theme rebuilds
    widget.onBrandUpdated(updatedBrand);
  }

  ContactEntity _contactFrom(ContactState state) => switch (state) {
        ContactLoaded(:final contact)  => contact,
        ContactSaved(:final contact)   => contact,
        ContactSaving(:final contact)  => contact,
        _                              => ContactEntity.empty,
      };

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactLoaded || state is ContactSaved) {
            _animCtrl.forward(from: 0);
          }
        },
        builder: (context, state) {
          if (state is ContactInitial || state is ContactLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purpleMid),
            );
          }

          if (state is ContactError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.redAccent)),
            );
          }

          final contact = _contactFrom(state);

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.darkSurface,
                  pinned: true,
                  title: Text(
                    brand.appBarTitle,
                    style: TextStyle(
                      color: brand.primaryColor.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _openEdit(contact),
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.textMuted),
                      tooltip: 'Hariri / Edit',
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      CardWidget(contact: contact, brand: brand),
                      const SizedBox(height: 16),
                      QrSection(
                        contact: contact,
                        brand: brand,
                        buildVCard: const BuildVCardUseCase(),
                      ),
                      const SizedBox(height: 16),
                      QuickLinks(contact: contact, brand: brand),
                      const SizedBox(height: 16),
                      _EditButton(
                          onTap: () => _openEdit(contact), brand: brand),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  final BrandConfig brand;
  const _EditButton({required this.onTap, required this.brand});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.edit_outlined, size: 17),
        label: const Text(
          'Hariri Taarifa · Edit Info',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}