import 'package:flutter/material.dart';
import '../theme.dart';

// ══════════════════════════════════════════════════
//  BACKGROUND GRADIENT
// ══════════════════════════════════════════════════
class NvBackground extends StatelessWidget {
  final Widget child;
  const NvBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [AppColors.backgroundTop, AppColors.background],
          ),
        ),
        child: child,
      );
}

// ══════════════════════════════════════════════════
//  GLASS CARD
// ══════════════════════════════════════════════════
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 32,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardGlass.withOpacity(0.6),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.purpleLight.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: child,
      );
}

// ══════════════════════════════════════════════════
//  PURPLE CARD
// ══════════════════════════════════════════════════
class PurpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const PurpleCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: child,
      );
}

// ══════════════════════════════════════════════════
//  ICON CIRCLE
// ══════════════════════════════════════════════════
class IconCircle extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final double size;

  const IconCircle({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppColors.purpleLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.purpleLight).withOpacity(0.4),
              blurRadius: 15,
            ),
          ],
        ),
        child: icon,
      );
}

// ══════════════════════════════════════════════════
//  MENU ITEM ROW
// ══════════════════════════════════════════════════
class MenuItemRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const MenuItemRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              IconCircle(icon: icon, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.purpleLight, size: 22),
            ],
          ),
        ),
      );
}

// ══════════════════════════════════════════════════
//  GRADIENT BUTTON
// ══════════════════════════════════════════════════
class GradButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const GradButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.purpleDark, AppColors.purple],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      );
}

// ══════════════════════════════════════════════════
//  OUTLINE BUTTON
// ══════════════════════════════════════════════════
class OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;

  const OutlineBtn({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textGrey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color != null
                ? color!.withOpacity(0.4)
                : AppColors.borderPurple,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                color: c,
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  NV TEXT FIELD
// ══════════════════════════════════════════════════
class NvTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;

  const NvTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        decoration: InputDecoration(hintText: hint),
      );
}

// ══════════════════════════════════════════════════
//  RADIO OPTION
// ══════════════════════════════════════════════════
class RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RadioOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.purpleLight.withOpacity(0.1)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.purpleLight
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.purpleLight : AppColors.textGrey,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.purpleLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
}

// ══════════════════════════════════════════════════
//  SECTION LABEL
// ══════════════════════════════════════════════════
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
}

// ══════════════════════════════════════════════════
//  DIVIDER
// ══════════════════════════════════════════════════
class NvDivider extends StatelessWidget {
  const NvDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      );
}

// ══════════════════════════════════════════════════
//  LOGO PILL
// ══════════════════════════════════════════════════
class LogoPill extends StatelessWidget {
  const LogoPill({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.purple.withOpacity(0.4),
          ),
        ),
        child: const Text(
          'NeuroVoice',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textWhite,
            letterSpacing: 0.5,
          ),
        ),
      );
}
