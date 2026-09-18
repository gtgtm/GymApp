import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';
import 'package:gymapp_admin/features/payments/domain/payment_models.dart';
import 'package:gymapp_admin/features/payments/presentation/payment_providers.dart';

const _paymentMethods = ['cash', 'upi', 'card', 'bank_transfer', 'online'];

Future<void> showRecordPaymentSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _RecordPaymentSheet(),
  );
}

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  const _RecordPaymentSheet();

  @override
  ConsumerState<_RecordPaymentSheet> createState() =>
      _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();
  String _search = '';
  Member? _selectedMember;
  String _method = _paymentMethods.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) ||
        _selectedMember == null)
      return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(paymentRepositoryProvider)
          .create(
            PaymentInput(
              memberId: _selectedMember!.id,
              amount: double.parse(_amountController.text),
              method: _method,
            ),
          );
      ref.invalidate(paymentListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Payment recorded.')));
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListProvider(_search));

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Collect Payment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_selectedMember == null) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search member by name, mobile, or ID',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: membersAsync.when(
                  data: (page) {
                    if (_search.trim().length < 2) {
                      return const Center(
                        child: Text('Type to search for a member.'),
                      );
                    }
                    if (page.members.isEmpty) {
                      return const Center(child: Text('No members found.'));
                    }
                    return ListView.builder(
                      itemCount: page.members.length,
                      itemBuilder: (context, index) {
                        final member = page.members[index];
                        return ListTile(
                          title: Text(member.fullName),
                          subtitle: Text(member.mobile),
                          onTap: () => setState(() => _selectedMember = member),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                ),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedMember!.fullName),
                subtitle: Text(_selectedMember!.mobile),
                trailing: TextButton(
                  onPressed: () => setState(() => _selectedMember = null),
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  if (double.tryParse(value) == null)
                    return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: [
                  for (final method in _paymentMethods)
                    DropdownMenuItem(
                      value: method,
                      child: Text(method.replaceAll('_', ' ')),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _method = value ?? _method),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Record Payment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
