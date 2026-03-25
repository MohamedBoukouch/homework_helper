import 'package:flutter/material.dart';

// ... (keep the documentation comments)

class SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? trailing;
  final bool isToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.isToggle = false,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isToggle ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0xFF6BCB77).withOpacity(0.08),
        highlightColor: Colors.black.withOpacity(0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // ── Icon bubble ──────────────────────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 14),

              // ── Label ────────────────────────────────────────────────────
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // ── Trailing ─────────────────────────────────────────────────
              if (isToggle && toggleValue != null)
                Switch(
                  value: toggleValue!,
                  onChanged: onToggle,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF6BCB77),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFDDDDDD),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              else if (trailing != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailing!,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFBBBBBB),
                      size: 20,
                    ),
                  ],
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBBBBBB),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
