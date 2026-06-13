import 'package:flutter/material.dart';
import '../models/herb.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class HerbsPage extends StatefulWidget {
  const HerbsPage({super.key});
  @override
  State<HerbsPage> createState() => _HerbsPageState();
}

class _HerbsPageState extends State<HerbsPage> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<Herb> _herbs = [];
  bool _loading = true;
  String? _error;

  List<Herb> get _filteredHerbs {
    final keyword = _searchCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) return _herbs;
    return _herbs.where((h) {
      return h.name.toLowerCase().contains(keyword) ||
          (h.aliasName ?? '').toLowerCase().contains(keyword) ||
          (h.pinyin ?? '').toLowerCase().contains(keyword);
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
      final herbs = await _api.getHerbs();
      setState(() { _herbs = herbs; _loading = false; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '药材数据加载失败';
      });
    }
  }

  Future<void> _showForm({Herb? herb}) async {
    final nameCtrl = TextEditingController(text: herb?.name ?? '');
    final aliasCtrl = TextEditingController(text: herb?.aliasName ?? '');
    final pinyinCtrl = TextEditingController(text: herb?.pinyin ?? '');
    final stockCtrl = TextEditingController(text: herb?.stockG.toString() ?? '0');
    final warnCtrl = TextEditingController(text: herb?.warnThresholdG.toString() ?? '0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(herb == null ? '新增药材' : '编辑药材'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '药材名')),
              TextField(controller: aliasCtrl, decoration: const InputDecoration(labelText: '别名')),
              TextField(controller: pinyinCtrl, decoration: const InputDecoration(labelText: '拼音')),
              TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: '库存(g)'), keyboardType: TextInputType.number),
              TextField(controller: warnCtrl, decoration: const InputDecoration(labelText: '预警阈值(g)'), keyboardType: TextInputType.number),
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
      final data = {
        'name': nameCtrl.text,
        'aliasName': aliasCtrl.text,
        'pinyin': pinyinCtrl.text,
        'stockG': int.tryParse(stockCtrl.text) ?? 0,
        'unit': 'g',
        'warnThresholdG': int.tryParse(warnCtrl.text) ?? 0,
      };
      if (herb == null) {
        await _api.createHerb(data);
        if (mounted) showAppMessage(context, '药材已新增');
      } else {
        await _api.updateHerb(herb.id, data);
        if (mounted) showAppMessage(context, '药材已更新');
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHerbs;
    return AppPage(
      title: '药材管理',
      subtitle: '库存、预警和基础药材信息集中维护',
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('新增药材'),
      ),
      child: Column(
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hint: '搜索药材、别名或拼音',
            onChanged: (_) => setState(() {}),
            onClear: () => setState(_searchCtrl.clear),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(heightFactor: 8, child: CircularProgressIndicator())
          else if (_error != null)
            ErrorState(message: _error!, onRetry: _load)
          else if (filtered.isEmpty)
            const EmptyState(title: '暂无药材', message: '新增药材后会显示在这里', icon: Icons.spa)
          else
            _HerbCollection(
              herbs: filtered,
              onEdit: (herb) => _showForm(herb: herb),
              onDelete: _confirmDelete,
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Herb herb) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除药材'),
        content: Text('确定删除 ${herb.name}？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirm == true) {
      await _api.deleteHerb(herb.id);
      if (mounted) showAppMessage(context, '药材已删除');
      _load();
    }
  }
}

class _HerbCollection extends StatelessWidget {
  final List<Herb> herbs;
  final ValueChanged<Herb> onEdit;
  final ValueChanged<Herb> onDelete;

  const _HerbCollection({required this.herbs, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return UiCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 58,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(label: Text('药材')),
                  DataColumn(label: Text('别名 / 拼音')),
                  DataColumn(label: Text('库存')),
                  DataColumn(label: Text('预警阈值')),
                  DataColumn(label: Text('状态')),
                  DataColumn(label: Text('操作')),
                ],
                rows: [
                  for (final herb in herbs)
                    DataRow(
                      cells: [
                        DataCell(Text(herb.name, style: const TextStyle(fontWeight: FontWeight.w800))),
                        DataCell(Text('${herb.aliasName ?? "无别名"}  ${herb.pinyin ?? ""}')),
                        DataCell(Text('${herb.stockG}g')),
                        DataCell(Text('${herb.warnThresholdG}g')),
                        DataCell(StatusPill(
                          label: herb.isLowStock ? '预警' : '正常',
                          icon: herb.isLowStock ? Icons.warning_amber : Icons.check,
                          color: herb.isLowStock ? const Color(0xFFC2410C) : const Color(0xFF2E7D32),
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(tooltip: '编辑', onPressed: () => onEdit(herb), icon: const Icon(Icons.edit_outlined)),
                            IconButton(tooltip: '删除', onPressed: () => onDelete(herb), icon: const Icon(Icons.delete_outline)),
                          ],
                        )),
                      ],
                    ),
                ],
              ),
            ),
          );
        }

        return ListSurface(
          children: [
            for (final herb in herbs)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: herb.isLowStock ? const Color(0xFFFFE7E0) : const Color(0xFFE5F5EA),
                  child: Icon(Icons.spa, color: herb.isLowStock ? const Color(0xFFC2410C) : const Color(0xFF2E7D32)),
                ),
                title: Text(herb.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${herb.aliasName ?? "无别名"}  ·  库存 ${herb.stockG}g  ·  预警 ${herb.warnThresholdG}g'),
                trailing: StatusPill(
                  label: herb.isLowStock ? '预警' : '正常',
                  icon: herb.isLowStock ? Icons.warning_amber : Icons.check,
                  color: herb.isLowStock ? const Color(0xFFC2410C) : const Color(0xFF2E7D32),
                ),
                onTap: () => onEdit(herb),
              ),
          ],
        );
      },
    );
  }
}
