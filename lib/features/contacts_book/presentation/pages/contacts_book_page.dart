import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/saved_contact.dart';
import '../bloc/contacts_book_bloc.dart';
import '../bloc/contacts_book_event.dart';
import '../bloc/contacts_book_state.dart';
import 'saved_contact_detail_page.dart';

class ContactsBookPage extends StatelessWidget {
  final BrandConfig brand;
  const ContactsBookPage({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        automaticallyImplyLeading: false,
        title: Text(
          'Anwani Zangu',
          style: TextStyle(
            color: brand.primaryColor.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: BlocBuilder<ContactsBookBloc, ContactsBookState>(
        builder: (context, state) {
          if (state is ContactsBookLoading || state is ContactsBookInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purpleMid),
            );
          }

          if (state is ContactsBookError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.redAccent)),
            );
          }

          if (state is ContactsBookLoaded) {
            if (state.contacts.isEmpty) {
              return _EmptyState(brand: brand);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              itemCount: state.contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ContactCard(
                saved: state.contacts[i],
                brand: brand,
                onDelete: () => context.read<ContactsBookBloc>().add(
                      ContactsBookDeleteRequested(state.contacts[i].id),
                    ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SavedContact saved;
  final BrandConfig brand;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.saved,
    required this.brand,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = saved.contact;
    final hasPhoto = c.photoBase64.isNotEmpty;
    final hasPortfolio = saved.portfolioItems.isNotEmpty;

    return Dismissible(
      key: ValueKey(saved.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline,
            color: Colors.redAccent, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedContactDetailPage(
              saved: saved,
              brand: brand,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.purpleMid.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brand.primaryColor.withValues(alpha: 0.18),
                border: Border.all(
                    color: brand.primaryColor.withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: ClipOval(
                child: hasPhoto
                    ? Image.memory(base64Decode(c.photoBase64),
                        fit: BoxFit.cover)
                    : Icon(Icons.person,
                        color: brand.primaryColor, size: 24),
              ),
            ),
            const SizedBox(width: 13),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    c.title.isNotEmpty ? c.title : c.org,
                    style: TextStyle(
                        color: brand.goldColor, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(
                      DateTimeUtils.timeAgo(saved.scannedAt),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10),
                    ),
                    if (hasPortfolio) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: brand.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${saved.portfolioItems.length} portfolio',
                          style: TextStyle(
                              color: brand.accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ]),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final BrandConfig brand;
  const _EmptyState({required this.brand});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                color: AppColors.textMuted.withValues(alpha: 0.5), size: 56),
            const SizedBox(height: 16),
            const Text('Bado hujascan mtu yeyote',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 8),
            const Text(
              'Bonyeza kitufe cha scan\nkuscan QR ya mtu mwingine',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
}