import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Provider/setup/Delivery_boy_provider.dart';
import '../../../model/setup/Delivery_boy_model.dart';



class DeliveryBoysScreen extends StatefulWidget {
  const DeliveryBoysScreen({super.key});

  @override
  State<DeliveryBoysScreen> createState() => _DeliveryBoysScreenState();
}

class _DeliveryBoysScreenState extends State<DeliveryBoysScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryBoyProvider>().fetchDeliveryBoys();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Delivery Boys',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
        actions: [
          Consumer<DeliveryBoyProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: provider.isLoading
                    ? null
                    : () => provider.fetchDeliveryBoys(),
              );
            },
          ),
        ],
      ),
      body: Consumer<DeliveryBoyProvider>(
        builder: (context, provider, _) {
          // ── Loading ─────────────────────────────────────────
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  SizedBox(height: 16),
                  Text(
                    'Fetching delivery boys...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // ── Error ────────────────────────────────────────────
          if (provider.status == DeliveryBoyStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 64, color: Color(0xFFEF4444)),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.fetchDeliveryBoys,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty ────────────────────────────────────────────
          if (provider.deliveryBoys.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining_rounded,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No delivery boys found',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
            );
          }

          // ── List ─────────────────────────────────────────────
          return RefreshIndicator(
            color: const Color(0xFF4F46E5),
            onRefresh: provider.fetchDeliveryBoys,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.deliveryBoys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final boy = provider.deliveryBoys[index];
                return _DeliveryBoyCard(deliveryBoy: boy);
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Delivery Boy Card ──────────────────────────────────────────
class _DeliveryBoyCard extends StatelessWidget {
  final DeliveryBoy deliveryBoy;

  const _DeliveryBoyCard({required this.deliveryBoy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  deliveryBoy.name.isNotEmpty
                      ? deliveryBoy.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deliveryBoy.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      _StatusBadge(isActive: deliveryBoy.active),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Username
                  Row(
                    children: [
                      const Icon(Icons.alternate_email_rounded,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        deliveryBoy.username,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Salesman
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Salesman',
                    value: deliveryBoy.salesmanName,
                  ),
                  const SizedBox(height: 4),

                  // Areas chip row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: deliveryBoy.areaNames
                        .split(',')
                        .map((area) => _AreaChip(area: area.trim()))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ───────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF10B981).withOpacity(0.12)
            : const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

// ─── Info Row ───────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Area Chip ──────────────────────────────────────────────────
class _AreaChip extends StatelessWidget {
  final String area;
  const _AreaChip({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        area,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}