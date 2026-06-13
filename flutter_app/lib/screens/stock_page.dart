import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_flow.dart';
import '../models/herb.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _api = ApiService();
  List<StockFlow> _flows = [];
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
      final flows = await _api.getStockFlows();
      setState(() { _flows = flows; _loading = false; });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '库存流水加载失败';
      });
    }
  }

  Future<void> _showStockIn() async {
    List<Herb> herbs = await _api.getHerbs();
    if (!mounted) return;

    Herb? selectedHerb;
    final qtyCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('药材入库'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Herb>(
                  initialValue: selectedHerb,
                  decoration: const InputDecoration(labelText: '选择药材'),
                  items: herbs.map((h) => DropdownMenuItem(
                    value: h,
                    child: Text('${h.name} (库存 ${h.stockG}g)'),
                  )).toList(),
                  onChanged: (h) => setDialogState(() => selectedHerb = h),
                ),
                TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: '入库数量(g)'), keyboardType: TextInputType.number),
                TextField(controller: remarkCtrl, decoration: const InputDecoration(labelText: '备注')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(
              onPressed: selectedHerb == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('入库'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && selectedHerb != null) {
      await _api.stockIn(selectedHerb!.id, int.tryParse(qtyCtrl.text) ?? 0, remarkCtrl.text);
      if (mounted) showAppMessage(context, '入库完成');
      _load();
    }
  }

  String _fmtTime(String t) {
    try {
      return DateFormat('MM-dd HH:mm').format(DateTime.parse(t));
    } catch (_) {
      return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '库存流水',
      subtitle: '追踪入库、出库与发药后的库存余额',
      onRefresh: _load,
      action: FilledButton.icon(
        onPressed: _showStockIn,
        icon: const Icon(Icons.add),
        label: const Text('入库'),
      ),
      child: _loading
          ? const Center(heightFactor: 8, child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _flows.isEmpty
                  ? const EmptyState(title: '暂无库存流水', message: '入库或发药后会产生库存记录', icon: Icons.inventory_2)
                  : ListSurface(
                      children: [
                        for (final f in _flows)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: f.isIn ? const Color(0xFFE5F5EA) : const Color(0xFFFFE7E0),
                              child: Icon(f.isIn ? Icons.add : Icons.remove, color: f.isIn ? const Color(0xFF2E7D32) : const Color(0xFFC2410C)),
                            ),
                            title: Text('${f.herb.name} · ${f.isIn ? "入库" : "出库"} ${f.qtyG}g', style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text('${_fmtTime(f.createdAt)}  ·  剩余 ${f.remainG ?? "?"}g  ·  ${f.remark?.isNotEmpty == true ? f.remark! : "无备注"}'),
                            trailing: StatusPill(
                              label: f.isIn ? '入库' : '出库',
                              icon: f.isIn ? Icons.arrow_downward : Icons.arrow_upward,
                              color: f.isIn ? const Color(0xFF2E7D32) : const Color(0xFFC2410C),
                            ),
                          ),
                      ],
                    ),
    );
  }
}
