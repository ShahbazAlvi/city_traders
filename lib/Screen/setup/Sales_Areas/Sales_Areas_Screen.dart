import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/setup/SalesAreasProvider.dart';

class SalesAreasScreen extends StatefulWidget {
  const SalesAreasScreen({super.key});

  @override
  State<SalesAreasScreen> createState() => _SalesAreasScreenState();
}

class _SalesAreasScreenState extends State<SalesAreasScreen> {
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Color> _cardColors = const [
    Color(0xFF185FA5),
    Color(0xFF0F6E56),
    Color(0xFF534AB7),
    Color(0xFF854F0B),
    Color(0xFF993C1D),
    Color(0xFF993556),
  ];

  final List<Color> _cardBgColors = const [
    Color(0xFFE6F1FB),
    Color(0xFFE1F5EE),
    Color(0xFFEEEDFE),
    Color(0xFFFAEEDA),
    Color(0xFFFAECE7),
    Color(0xFFFBEAF0),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SalesAreasProvider>(context, listen: false).fetchSalesAreas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildSearchBar(colorScheme),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<SalesAreasProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return _buildShimmer();
                  if (provider.error.isNotEmpty) return _buildError(provider.error, colorScheme);

                  final filtered = provider.areas
                      .where((a) =>
                  a.name.toLowerCase().contains(_searchQuery) ||
                      a.id.toString().contains(_searchQuery))
                      .toList();

                  if (filtered.isEmpty) return _buildEmpty(colorScheme);

                  return _isGridView
                      ? _buildGrid(filtered, colorScheme)
                      : _buildList(filtered, colorScheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                size: 18, color: Color(0xFF185FA5)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales Areas',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
              Consumer<SalesAreasProvider>(
                builder: (_, provider, __) => Text(
                  provider.isLoading
                      ? 'Loading...'
                      : '${provider.areas.length} areas',
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4), width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search areas...',
            hintStyle:
            TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            prefixIcon:
            Icon(Icons.search_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(Icons.close_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List areas, ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: areas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final area = areas[index];
        final color = _cardColors[index % _cardColors.length];
        final bgColor = _cardBgColors[index % _cardBgColors.length];
        return _buildListCard(area, color, bgColor, colorScheme);
      },
    );
  }

  Widget _buildListCard(dynamic area, Color color, Color bgColor, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: color.withOpacity(0.25), width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      _initials(area.name),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),

                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List areas, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: areas.length,
      itemBuilder: (context, index) {
        final area = areas[index];
        final color = _cardColors[index % _cardColors.length];
        final bgColor = _cardBgColors[index % _cardBgColors.length];
        return _buildGridCard(area, color, bgColor, colorScheme);
      },
    );
  }

  Widget _buildGridCard(dynamic area, Color color, Color bgColor, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withOpacity(0.25), width: 0.5),
                  ),
                  child: Center(
                    child: Text(_initials(area.name),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(area.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${area.id}',
                    style: TextStyle(
                        fontSize: 11, color: colorScheme.onSurfaceVariant)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Active',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: color)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 13,
                          width: double.infinity,
                          color: Colors.white),
                      const SizedBox(height: 8),
                      Container(
                          height: 10, width: 80, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                    width: 50,
                    height: 22,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFA32D2D), size: 28),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () =>
                  Provider.of<SalesAreasProvider>(context, listen: false)
                      .fetchSalesAreas(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF185FA5),
                backgroundColor: const Color(0xFFE6F1FB),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.search_off_rounded,
                color: colorScheme.onSurfaceVariant, size: 28),
          ),
          const SizedBox(height: 14),
          Text('No results found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Try a different search term',
              style: TextStyle(
                  fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}