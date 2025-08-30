import 'package:flutter/material.dart';
import '../constants/phase_status_constants.dart';

class PhaseStatusBadge extends StatelessWidget {
  final dynamic phaseStatus;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const PhaseStatusBadge({
    super.key,
    required this.phaseStatus,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    // Handle both int and string status values
    PhaseStatus status;
    if (phaseStatus is int) {
      status = PhaseStatus.fromValue(phaseStatus);
    } else if (phaseStatus is String) {
      // Try to find by name first, then fallback to notStarted
      try {
        status = PhaseStatus.fromName(phaseStatus);
      } catch (e) {
        // If not found, try to map common status names
        switch (phaseStatus.toLowerCase()) {
          case 'notstarted':
            status = PhaseStatus.notStarted;
            break;
          case 'dealed':
            status = PhaseStatus.dealed;
            break;
          case 'deposited':
            status = PhaseStatus.deposited;
            break;
          case 'withdrawed':
            status = PhaseStatus.withdrawed;
            break;
          case 'inprogress':
          case 'in_progress':
            status = PhaseStatus.inProgress;
            break;
          case 'rework':
            status = PhaseStatus.rework;
            break;
          case 'done':
            status = PhaseStatus.done;
            break;
          case 'refund':
            status = PhaseStatus.refund;
            break;
          default:
            status = PhaseStatus.notStarted;
        }
      }
    } else {
      status = PhaseStatus.notStarted;
    }

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.icon, color: status.color, size: iconSize ?? 16),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
