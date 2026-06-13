import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});
  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  final _api = ApiService();
  List<Prescription> _prescriptions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final prescriptions = await _api.getPrescriptions();
      setState(() { _prescriptions = prescriptions; _loading = false; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '处方数据加载失败';
      });
    }
  }

  String _fmtTime(String t) {
    try {
      return DateFormat('MM-dd HH:mm').format(DateTime.parse(t));
    } catch (_) {
      return t;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DRAFT': return Colors.orange;
      case 'DISPENSED': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'DRAFT': return '待发药';
      case 'DISPENSED': return '已发药';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '处方管理',
      subtitle: '查看处方明细，完成发药和库存扣减',
      onRefresh: _load,
      child: _loading
          ? const Center(heightFactor: 8, child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _prescriptions.isEmpty
                  ? const EmptyState(title: '暂无处方', message: '处方创建后会出现在这里', icon: Icons.receipt_long)
                  : Column(
                      children: [
                        for (final p in _prescriptions) ...[
                          UiCard(
                            padding: EdgeInsets.zero,
                            child: ExpansionTile(
                              leading: Icon(Icons.receipt_long, color: _statusColor(p.status)),
                              title: Text('${p.visit.patient.name} · ${p.copies}剂', style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text('${_fmtTime(p.createdAt)}  ·  ${p.items?.length ?? 0} 味药'),
                              trailing: StatusPill(
                                label: _statusLabel(p.status),
                                icon: p.status == 'DISPENSED' ? Icons.check : Icons.medication,
                                color: _statusColor(p.status),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                if (p.items != null)
                                  for (final item in p.items!)
                                    ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(item.herb.name),
                                      subtitle: item.note?.isNotEmpty == true ? Text(item.note!) : null,
                                      trailing: Text('${item.doseG}g', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    ),
                                if (p.usageText != null && p.usageText!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: StatusPill(label: p.usageText!, icon: Icons.local_drink_outlined, color: const Color(0xFF1976D2)),
                                    ),
                                  ),
                                if (p.status == 'DRAFT')
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        await _api.dispensePrescription(p.id);
                                        if (!context.mounted) return;
                                        showAppMessage(context, '处方已发药');
                                        _load();
                                      },
                                      icon: const Icon(Icons.medication),
                                      label: const Text('发药'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
    );
  }
}
