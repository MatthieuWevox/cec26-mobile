import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class CecBackground extends StatelessWidget {
  final Widget child;
  final bool accentTop;

  const CecBackground({super.key, required this.child, this.accentTop = true});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.canvasGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (accentTop)
            Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.accentColor.withAlpha(24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class CecContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CecContentWidth({super.key, required this.child, this.maxWidth = 880});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class CecGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const CecGlassPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.color,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.radius),
    ),
    this.blur = 18,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? AppTheme.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color ?? Colors.white.withAlpha(188),
              borderRadius: borderRadius,
              border:
                  border ??
                  Border.all(color: Colors.white.withAlpha(196), width: 1),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class CecGlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool dark;

  const CecGlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppTheme.primaryColor;
    return Tooltip(
      message: tooltip,
      child: CecGlassPanel(
        color: dark
            ? AppTheme.primaryDark.withAlpha(136)
            : Colors.white.withAlpha(190),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: const [],
        child: SizedBox.square(
          dimension: 44,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 21),
            color: foreground,
            disabledColor: foreground.withAlpha(96),
          ),
        ),
      ),
    );
  }
}

class CecGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const CecGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      leading: leading,
      backgroundColor: Colors.white.withAlpha(196),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(color: Colors.white.withAlpha(104)),
        ),
      ),
      shape: Border(
        bottom: BorderSide(color: AppTheme.primaryColor.withAlpha(18)),
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;

  const MemberAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
  });

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.isEmpty ? '?' : parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallback = DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.64,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(214),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipOval(
        child: imageUrl == null || imageUrl!.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(
                  color: AppTheme.surfaceMuted,
                  child: Center(
                    child: SizedBox.square(
                      dimension: radius * 0.65,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class CompanyLogo extends StatelessWidget {
  final String? logoUrl;
  final String companyName;
  final double size;

  const CompanyLogo({
    super.key,
    this.logoUrl,
    required this.companyName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(color: AppTheme.accentSoft),
      child: Center(
        child: Icon(Icons.apartment_rounded, color: AppTheme.primaryColor),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(236),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: Colors.white),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: logoUrl == null || logoUrl!.isEmpty
            ? fallback
            : Padding(
                padding: const EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl: logoUrl!,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => fallback,
                ),
              ),
      ),
    );
  }
}

class CecPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final Widget? bottom;
  final double contentMaxWidth;

  const CecPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.bottom,
    this.contentMaxWidth = 760,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo_purple_nobg.png',
                        width: 55,
                        height: 35,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'CEC',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 22,
                        color: AppTheme.dividerColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          eyebrow,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 10),
                        trailing!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 30,
                      height: 1.16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  if (bottom != null) ...[const SizedBox(height: 18), bottom!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The inset backplate reserves space so layered cards never cover neighbours.
class CecLayeredCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const CecLayeredCard({
    super.key,
    required this.child,
    this.color = AppTheme.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: 12,
          left: 8,
          right: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.primaryColor.withAlpha(18)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 8), child: child),
      ],
    );
  }
}

class CecSurface extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final bool glass;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const CecSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color = AppTheme.surfaceColor,
    this.glass = false,
    this.borderColor,
    this.boxShadow,
  });

  @override
  State<CecSurface> createState() => _CecSurfaceState();
}

class _CecSurfaceState extends State<CecSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final content = Padding(padding: widget.padding, child: widget.child);
    final material = Material(
      color: Colors.transparent,
      child: widget.onTap == null
          ? content
          : InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (value) {
                if (_pressed != value) setState(() => _pressed = value);
              },
              child: content,
            ),
    );

    Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.glass
            ? widget.color.withAlpha(188)
            : widget.color.withAlpha(244),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color:
              widget.borderColor ??
              (widget.glass
                  ? Colors.white.withAlpha(190)
                  : AppTheme.primaryColor.withAlpha(10)),
        ),
      ),
      child: material,
    );

    if (widget.glass) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: body,
      );
    }

    return AnimatedScale(
      scale: widget.onTap != null && _pressed ? 0.985 : 1,
      duration: reduceMotion ? Duration.zero : AppTheme.motionFast,
      curve: AppTheme.motionCurve,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: widget.boxShadow ?? AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: body,
      ),
    );
  }
}

class CecSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const CecSearchField({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.controller,
    this.onSubmitted,
    this.suffix,
  });

  @override
  State<CecSearchField> createState() => _CecSearchFieldState();
}

class _CecSearchFieldState extends State<CecSearchField> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void didUpdateWidget(CecSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_changed);
      if (_ownsController) _controller.dispose();
      _attachController();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 21),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                tooltip: 'Effacer la recherche',
                icon: const Icon(Icons.close_rounded, size: 19),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              )
            : widget.suffix,
        fillColor: AppTheme.surfaceMuted,
      ),
    );
  }
}

class CecMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const CecMeta({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppTheme.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: foreground),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class CecBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool inverted;

  const CecBadge({
    super.key,
    required this.label,
    this.color = AppTheme.primaryColor,
    this.icon,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = inverted ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: inverted ? color.withAlpha(214) : color.withAlpha(18),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: inverted ? Colors.white.withAlpha(24) : color.withAlpha(28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CecLoadingWidget extends StatelessWidget {
  final String? message;

  const CecLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: CecGlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: 34,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CecErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CecErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _CecStateWidget(
      icon: Icons.cloud_off_rounded,
      title: 'Connexion impossible',
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
    );
  }
}

class CecEmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const CecEmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return _CecStateWidget(
      icon: icon,
      title: 'Rien à afficher',
      message: message,
    );
  }
}

class _CecStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _CecStateWidget({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 100),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 90,
                child: CecLayeredCard(
                  child: CecSurface(
                    padding: const EdgeInsets.all(23),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 30),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 27, 2, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, size: 17, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CecReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const CecReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.035),
  });

  @override
  State<CecReveal> createState() => _CecRevealState();
}

class _CecRevealState extends State<CecReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future<void>.delayed(widget.delay);
      }
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : AppTheme.motionSlow;

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: duration,
      curve: AppTheme.motionCurve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.offset,
        duration: duration,
        curve: AppTheme.motionCurve,
        child: widget.child,
      ),
    );
  }
}
