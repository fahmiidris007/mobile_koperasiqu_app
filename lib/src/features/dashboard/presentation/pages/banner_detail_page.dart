import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../data/datasources/banner_datasource.dart';

/// Halaman detail banner/promo
class BannerDetailPage extends StatelessWidget {
  const BannerDetailPage({super.key, required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero image / AppBar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: banner.hasImage ? 280 : 140,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: banner.hasImage
                  ? _HeroImage(banner: banner)
                  : _HeroPlaceholder(banner: banner),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + title
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Meta info (tanggal, tipe)
                  _buildMetaInfo()
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms),

                  if (banner.description != null &&
                      banner.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDescription()
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 400.ms),
                  ],

                  const SizedBox(height: 28),

                  // Divider
                  Divider(color: AppColors.accentLight),

                  const SizedBox(height: 20),

                  // Info card
                  // _buildInfoCard()
                  //     .animate(delay: 200.ms)
                  //     .fadeIn(duration: 400.ms)
                  //     .slideY(begin: 0.05, end: 0),

                  // const SizedBox(height: 28),

                  // CTA button jika ada link
                  if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty)
                    _buildLinkButton(
                      context,
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeBadge(type: banner.type),
        const SizedBox(height: 12),
        Text(
          banner.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfo() {
    final published = banner.publishedAt != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(banner.publishedAt!)
        : null;

    return Row(
      children: [
        if (published != null) ...[
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            published,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(width: 16),
        ],
        Icon(
          banner.isPromo
              ? Icons.local_offer_outlined
              : Icons.newspaper_outlined,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 5),
        Text(
          _typeLabel,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          banner.description!,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.info_outline,
            label: 'Kategori',
            value: _typeLabel,
          ),
          if (banner.publishedAt != null) ...[
            Divider(color: AppColors.accentLight, height: 1),
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: 'Dipublikasikan',
              value: DateFormat(
                'dd MMMM yyyy, HH:mm',
                'id_ID',
              ).format(banner.publishedAt!),
            ),
          ],
          if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty) ...[
            Divider(color: AppColors.accentLight, height: 1),
            _InfoRow(
              icon: Icons.link_outlined,
              label: 'Link',
              value: banner.linkUrl!,
              isLink: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final url = Uri.tryParse(banner.linkUrl!);
          if (url != null && await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak dapat membuka tautan')),
              );
            }
          }
        },
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text('Buka Tautan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String get _typeLabel => switch (banner.type) {
    'promo' => 'Promosi',
    'news' => 'Berita & Info',
    _ => banner.type,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.banner});
  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          banner.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.backgroundAlt,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => const _HeroPlaceholderContent(),
        ),

        // Gradient bawah agar konten di bawahnya seamless
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.banner});
  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.12), AppColors.accentLight],
        ),
      ),
      child: const _HeroPlaceholderContent(),
    );
  }
}

class _HeroPlaceholderContent extends StatelessWidget {
  const _HeroPlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 56,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'KoperasiQu',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  Color get _color => switch (type) {
    'promo' => const Color(0xFF6C63FF),
    'news' => AppColors.primary,
    _ => AppColors.accent,
  };

  String get _label => switch (type) {
    'promo' => 'PROMO',
    'news' => 'INFO',
    _ => type.toUpperCase(),
  };

  IconData get _icon => switch (type) {
    'promo' => Icons.local_offer_rounded,
    'news' => Icons.newspaper_rounded,
    _ => Icons.campaign_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLink ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: isLink ? TextDecoration.underline : null,
                    decorationColor: isLink ? AppColors.primary : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
