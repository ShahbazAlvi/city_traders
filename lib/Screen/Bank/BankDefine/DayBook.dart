// screens/daybook_ledger_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Provider/BankProvider/DayBookProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/BankModel/DayBookmodel.dart';


class DaybookLedgerScreen extends StatefulWidget {
  const DaybookLedgerScreen({super.key});

  @override
  State<DaybookLedgerScreen> createState() => _DaybookLedgerScreenState();
}

class _DaybookLedgerScreenState extends State<DaybookLedgerScreen> {
  final _currencyFormat = NumberFormat('#,##0', 'en_PK');

  static const _appGradient = LinearGradient(
    colors: [AppColors.secondary,AppColors.primary, ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DaybookLedgerProvider>().fetchLedger();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<DaybookLedgerProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) provider.changeDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ── Plain AppBar ───────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daybook Ledger',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => context.read<DaybookLedgerProvider>().refresh(),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Date pill + Summary cards (outside AppBar) ─────────────────────
          _buildSubHeader(context),

          // ── Body ───────────────────────────────────────────────────────────
          Expanded(
            child: Consumer<DaybookLedgerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return _buildShimmer();
                if (provider.hasError) return _buildError(provider);
                if (provider.hasData) return _buildContent(provider);
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-header: date pill + summary cards ──────────────────────────────────
  Widget _buildSubHeader(BuildContext context) {
    return Consumer<DaybookLedgerProvider>(
      builder: (_, provider, __) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: _appGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            children: [
              // ── Date picker pill ──────────────────────────────────────────
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(provider.selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Summary cards ─────────────────────────────────────────────
              if (provider.hasData)
                _buildSummaryCards(provider.summary!)
              else
                _buildHeaderShimmer(),
            ],
          ),
        );
      },
    );
  }

  // ── Summary shimmer inside sub-header ─────────────────────────────────────
  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Row(
        children: List.generate(
          3,
              (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Summary cards row ──────────────────────────────────────────────────────
  Widget _buildSummaryCards(DaybookSummary summary) {
    return Row(
      children: [
        _SummaryCard(
          label: 'Total Receipt',
          amount: summary.totalReceipt,
          icon: Icons.arrow_downward_rounded,
          accentColor: const Color(0xFFB2FFEE),
          formatter: _currencyFormat,
        ),
        const SizedBox(width: 8),
        _SummaryCard(
          label: 'Total Payment',
          amount: summary.totalPayment,
          icon: Icons.arrow_upward_rounded,
          accentColor: const Color(0xFFFFB3B3),
          formatter: _currencyFormat,
        ),
        const SizedBox(width: 8),
        _SummaryCard(
          label: 'Balance',
          amount: summary.closingBalance,
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.white,
          formatter: _currencyFormat,
        ),
      ],
    );
  }

  // ── Body shimmer (table area) ──────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              6,
                  (_) => Container(
                margin: const EdgeInsets.only(bottom: 7),
                height: 58,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError(DaybookLedgerProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFE74C3C), size: 56),
          const SizedBox(height: 12),
          Text('Failed to load data',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(provider.errorMessage,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: _appGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────────────────
  Widget _buildContent(DaybookLedgerProvider provider) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: provider.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(),
            const SizedBox(height: 8),
            ...provider.entries.map(_buildEntryRow),
            const SizedBox(height: 8),
            _buildTotalsRow(provider.summary!),
          ],
        ),
      ),
    );
  }

  // ── Table header ───────────────────────────────────────────────────────────
  Widget _buildTableHeader() {
    const s = TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: _appGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(width: 26, child: Text('SR', style: s)),
          SizedBox(width: 76, child: Text('Voucher', style: s)),
          Expanded(child: Text('Account', style: s)),
          SizedBox(width: 66, child: Text('Receipt', style: s, textAlign: TextAlign.right)),
          SizedBox(width: 66, child: Text('Payment', style: s, textAlign: TextAlign.right)),
          SizedBox(width: 66, child: Text('Balance', style: s, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ── Entry row ──────────────────────────────────────────────────────────────
  Widget _buildEntryRow(DaybookEntry entry) {
    final isCRV = entry.voucherType == 'CRV';
    final badgeBg = isCRV ? const Color(0xFFD5F5E3) : const Color(0xFFFFE0E0);
    final badgeFg = isCRV ? const Color(0xFF1E8449) : const Color(0xFFC0392B);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('${entry.sr}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
          ),
          SizedBox(
            width: 76,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(5)),
              child: Text(
                entry.voucherNo,
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700, color: badgeFg),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.accountName,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.narration.isNotEmpty)
                  Text(entry.narration,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFFAAAAAA)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(
            width: 66,
            child: Text(
              entry.receipt > 0 ? _currencyFormat.format(entry.receipt) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: entry.receipt > 0
                      ? const Color(0xFF1E8449)
                      : const Color(0xFFCCCCCC)),
            ),
          ),
          SizedBox(
            width: 66,
            child: Text(
              entry.payment > 0 ? _currencyFormat.format(entry.payment) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: entry.payment > 0
                      ? const Color(0xFFC0392B)
                      : const Color(0xFFCCCCCC)),
            ),
          ),
          SizedBox(
            width: 66,
            child: ShaderMask(
              shaderCallback: (b) => _appGradient.createShader(b),
              child: Text(
                _currencyFormat.format(entry.balance),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Totals footer ──────────────────────────────────────────────────────────
  Widget _buildTotalsRow(DaybookSummary summary) {
    const s = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: _appGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 26),
          const SizedBox(width: 76),
          const Expanded(child: Text('Total', style: s)),
          SizedBox(
              width: 66,
              child: Text(_currencyFormat.format(summary.totalReceipt),
                  textAlign: TextAlign.right,
                  style: s.copyWith(color: const Color(0xFFB2FFEE)))),
          SizedBox(
              width: 66,
              child: Text(_currencyFormat.format(summary.totalPayment),
                  textAlign: TextAlign.right,
                  style: s.copyWith(color: const Color(0xFFFFB3B3)))),
          SizedBox(
              width: 66,
              child: Text(_currencyFormat.format(summary.closingBalance),
                  textAlign: TextAlign.right,
                  style: s)),
        ],
      ),
    );
  }
}

// ── Frosted-glass summary card ─────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color accentColor;
  final NumberFormat formatter;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              formatter.format(amount),
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: accentColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}