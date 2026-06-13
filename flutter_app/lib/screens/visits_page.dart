import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});
  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  final _api = ApiService();
  List<Visit> _visits = [];
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
      final visits = await _api.getVisits();
      setState(() { _visits = visits; _loading = false; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '就诊记录加载失败';
      });
    }
  }

  String _fmtTime(String t) {
    try {
      final dt = DateTime.parse(t);
      return DateFormat('MM-dd HH:mm').format(dt);
    } catch (_) {
      return t;
    }
  }

  Future<void> _showVisitDetail(Visit visit) async {
    final ccCtrl = TextEditingController(text: visit.chiefComplaint ?? '');
    final piCtrl = TextEditingController(text: visit.presentIllness ?? '');
    final phCtrl = TextEditingController(text: visit.pastHistory ?? '');
    final ahCtrl = TextEditingController(text: visit.allergyHistory ?? '');
    final diagCtrl = TextEditingController(text: visit.diagnosis ?? '');
    final advCtrl = TextEditingController(text: visit.advice ?? '');
    final noteCtrl = TextEditingController(text: visit.doctorNote ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('就诊 - ${visit.patient.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('就诊时间: ${_fmtTime(visit.visitTime)}', style: TextStyle(color: Colors.grey[600])),
              const Divider(),
              TextField(controller: ccCtrl, decoration: const InputDecoration(labelText: '主诉'), maxLines: 2),
              TextField(controller: piCtrl, decoration: const InputDecoration(labelText: '现病史'), maxLines: 2),
              TextField(controller: phCtrl, decoration: const InputDecoration(labelText: '既往史'), maxLines: 2),
              TextField(controller: ahCtrl, decoration: const InputDecoration(labelText: '过敏史'), maxLines: 1),
              TextField(controller: diagCtrl, decoration: const InputDecoration(labelText: '诊断'), maxLines: 3),
              TextField(controller: advCtrl, decoration: const InputDecoration(labelText: '医嘱'), maxLines: 3),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: '备注')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
        ],
      ),
    );

    if (ok == true) {
      await _api.updateVisit(visit.id, {
        'chiefComplaint': ccCtrl.text,
        'presentIllness': piCtrl.text,
        'pastHistory': phCtrl.text,
        'allergyHistory': ahCtrl.text,
        'diagnosis': diagCtrl.text,
        'advice': advCtrl.text,
        'doctorNote': noteCtrl.text,
      });
      if (mounted) showAppMessage(context, '就诊记录已保存');
      _load();
    }
  }

  Future<void> _showNewVisit() async {
    List<Patient> patients = await _api.getPatients();
    if (!mounted) return;

    Patient? selectedPatient;
    final complaintCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新建就诊'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Patient>(
                  initialValue: selectedPatient,
                  decoration: const InputDecoration(labelText: '选择患者'),
                  items: patients.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (p) => setDialogState(() => selectedPatient = p),
                ),
                TextField(controller: complaintCtrl, decoration: const InputDecoration(labelText: '主诉'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(
              onPressed: selectedPatient == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && selectedPatient != null) {
      await _api.createVisit({
        'patient': {'id': selectedPatient!.id},
        'chiefComplaint': complaintCtrl.text,
      });
      if (mounted) showAppMessage(context, '就诊记录已创建');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '就诊记录',
      subtitle: '记录主诉、诊断、医嘱和复诊备注',
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: _showNewVisit,
        icon: const Icon(Icons.add),
        label: const Text('新建就诊'),
      ),
      child: _loading
          ? const Center(heightFactor: 8, child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _visits.isEmpty
                  ? const EmptyState(title: '暂无就诊记录', message: '创建就诊后可补充病历与诊断', icon: Icons.event_note)
                  : ListSurface(
                      children: [
                        for (final v in _visits)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(v.patient.name.isEmpty ? '?' : v.patient.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
                            ),
                            title: Text(v.patient.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text('${_fmtTime(v.visitTime)}  ·  ${v.chiefComplaint?.isNotEmpty == true ? v.chiefComplaint! : "未填写主诉"}'),
                            trailing: StatusPill(
                              label: v.diagnosis?.isNotEmpty == true ? '已诊断' : '待完善',
                              icon: v.diagnosis?.isNotEmpty == true ? Icons.check : Icons.edit_note,
                              color: v.diagnosis?.isNotEmpty == true ? const Color(0xFF2E7D32) : const Color(0xFFC2410C),
                            ),
                            onTap: () => _showVisitDetail(v),
                          ),
                      ],
                    ),
    );
  }
}
