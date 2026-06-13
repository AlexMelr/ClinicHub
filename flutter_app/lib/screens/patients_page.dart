import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});
  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<Patient> _patients = [];
  bool _loading = true;
  String? _error;

  List<Patient> get _filteredPatients {
    final keyword = _searchCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) return _patients;
    return _patients.where((p) {
      return p.name.toLowerCase().contains(keyword) || (p.phone ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final patients = await _api.getPatients();
      setState(() { _patients = patients; _loading = false; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '患者数据加载失败';
      });
    }
  }

  Future<void> _showForm({Patient? patient}) async {
    final nameCtrl = TextEditingController(text: patient?.name ?? '');
    final ageCtrl = TextEditingController(text: patient?.age?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: patient?.phone ?? '');
    String gender = patient?.gender ?? '男';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(patient == null ? '新增患者' : '编辑患者'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '姓名')),
                TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: '年龄'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '男', label: Text('男')),
                    ButtonSegment(value: '女', label: Text('女')),
                  ],
                  selected: {gender},
                  onSelectionChanged: (s) => setDialogState(() => gender = s.first),
                ),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: '电话'), keyboardType: TextInputType.phone),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
          ],
        ),
      ),
    );

    if (ok == true) {
      final data = {
        'name': nameCtrl.text,
        'age': int.tryParse(ageCtrl.text),
        'gender': gender,
        'phone': phoneCtrl.text,
      };
      if (patient == null) {
        await _api.createPatient(data);
        if (mounted) showAppMessage(context, '患者已新增');
      } else {
        await _api.updatePatient(patient.id, data);
        if (mounted) showAppMessage(context, '患者已更新');
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;
    return AppPage(
      title: '患者管理',
      subtitle: '快速查找患者档案，维护基础联系方式',
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('新增患者'),
      ),
      child: Column(
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hint: '搜索姓名或电话',
            onChanged: (_) => setState(() {}),
            onClear: () => setState(_searchCtrl.clear),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(heightFactor: 8, child: CircularProgressIndicator())
          else if (_error != null)
            ErrorState(message: _error!, onRetry: _load)
          else if (filtered.isEmpty)
            const EmptyState(title: '暂无患者', message: '新增患者后可在这里建立就诊记录', icon: Icons.people_outline)
          else
            _PatientCollection(
              patients: filtered,
              onEdit: (patient) => _showForm(patient: patient),
            ),
        ],
      ),
    );
  }
}

class _PatientCollection extends StatelessWidget {
  final List<Patient> patients;
  final ValueChanged<Patient> onEdit;

  const _PatientCollection({required this.patients, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return UiCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 58,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(label: Text('患者')),
                  DataColumn(label: Text('性别')),
                  DataColumn(label: Text('年龄')),
                  DataColumn(label: Text('电话')),
                  DataColumn(label: Text('操作')),
                ],
                rows: [
                  for (final p in patients)
                    DataRow(cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(p.name.isEmpty ? '?' : p.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      )),
                      DataCell(Text(p.gender ?? '未填')),
                      DataCell(Text(p.age == null ? '未填' : '${p.age}岁')),
                      DataCell(Text(p.phone?.isNotEmpty == true ? p.phone! : '未填')),
                      DataCell(IconButton(tooltip: '编辑', onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined))),
                    ]),
                ],
              ),
            ),
          );
        }

        return ListSurface(
          children: [
            for (final p in patients)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(p.name.isEmpty ? '?' : p.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${p.gender ?? "未填性别"}  ·  ${p.age != null ? "${p.age}岁" : "年龄未填"}  ·  ${p.phone?.isNotEmpty == true ? p.phone! : "电话未填"}'),
                trailing: IconButton(tooltip: '编辑', onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined)),
                onTap: () => onEdit(p),
              ),
          ],
        );
      },
    );
  }
}
