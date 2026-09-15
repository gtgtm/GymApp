import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';
import 'package:gymapp_admin/features/plans/presentation/plan_providers.dart';

const _paymentMethods = ['cash', 'upi', 'card', 'bank_transfer', 'online'];

Future<void> showRenewMembershipSheet(BuildContext context, int memberId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _RenewMembershipSheet(memberId: memberId),
  );
}

class _RenewMembershipSheet extends ConsumerStatefulWidget {
  const _RenewMembershipSheet({required this.memberId});

  final int memberId;

  @override
  ConsumerState<_RenewMembershipSheet> createState() => _RenewMembershipSheetState();
}

class _RenewMembershipSheetState extends ConsumerState<_RenewMembershipSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _planId;
  String _paymentMethod = _paymentMethods.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _planId == null) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(memberRepositoryProvider).renew(
            widget.memberId,
            RenewMembershipInput(
              membershipPlanId: _planId!,
              amountPaid: double.parse(_amountController.text),
              paymentMethod: _paymentMethod,
            ),
          );
      ref.invalidate(memberDetailProvider(widget.memberId));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membership renewed.')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(planListProvider);

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
            Text('Renew Membership', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            plansAsync.when(
              data: (plans) => DropdownButtonFormField<int>(
                initialValue: _planId,
                decoration: const InputDecoration(labelText: 'Membership Plan'),
                items: [
                  for (final plan in plans)
                    DropdownMenuItem(value: plan.id, child: Text('${plan.name} (₹${plan.totalAmount})')),
                ],
                onChanged: (value) => setState(() => _planId = value),
                validator: (value) => value == null ? 'Select a plan' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Failed to load plans: $error'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount Paid'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: [
                for (final method in _paymentMethods)
                  DropdownMenuItem(value: method, child: Text(method.replaceAll('_', ' '))),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value ?? _paymentMethod),
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
                  : const Text('Confirm Renewal'),
            ),
          ],
        ),
      ),
    );
  }
}
