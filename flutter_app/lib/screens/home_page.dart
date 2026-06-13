import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/app_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  int _herbCount = 0;
  int _patientCount = 0;
  int _visitTodayCount = 0;
  int _lowStockCount = 0;
  int _prescriptionCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final herbs = await _api.getHerbs();
      final patients = await _api.getPatients();
      final visits = await _api.getVisits();
      final lowHerbs = await _api.getHerbs(lowStock: true);
      final prescriptions = await _api.getPrescriptions();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      setState(() {
        _herbCount = herbs.length;
        _patientCount = patients.length;
        _visitTodayCount = visits.where((v) => v.visitTime.startsWith(today)).length;
        _lowStockCount = lowHerbs.length;
        _prescriptionCount = prescriptions.where((p) => p.status == 'DRAFT').length;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = '无法连接后端服务，请确认 8090 已启动';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'ClinicHub 中医诊所',
      subtitle: '今日诊务、库存和处方状态一屏掌握',
      onRefresh: _loadStats,
      action: IconButton.filledTonal(
        tooltip: '刷新',
        onPressed: _loadStats,
        icon: const Icon(Icons.refresh),
      ),
      child: _loading
          ? const Center(heightFactor: 8, child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadStats)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth > 920 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: constraints.maxWidth > 920 ? 1.75 : 1.45,
                          children: [
                            _StatCard(title: '药材种类', value: '$_herbCount', icon: Icons.spa, color: const Color(0xFF2E7D32), note: '启用药材'),
                            _StatCard(title: '患者总数', value: '$_patientCount', icon: Icons.people, color: const Color(0xFF1976D2), note: '可检索档案'),
                            _StatCard(title: '今日就诊', value: '$_visitTodayCount', icon: Icons.event_available, color: const Color(0xFF6A4BBC), note: '今日记录'),
                            _StatCard(
                              title: '待处理',
                              value: '${_lowStockCount + _prescriptionCount}',
                              icon: Icons.task_alt,
                              color: _lowStockCount + _prescriptionCount > 0 ? const Color(0xFFC2410C) : const Color(0xFF64748B),
                              note: '$_lowStockCount 个库存预警 / $_prescriptionCount 张待发药',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    UiCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('诊所工作台', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              StatusPill(label: _lowStockCount > 0 ? '库存需关注' : '库存稳定', icon: Icons.inventory_2, color: _lowStockCount > 0 ? const Color(0xFFC2410C) : const Color(0xFF2E7D32)),
                              StatusPill(label: _prescriptionCount > 0 ? '有待发药处方' : '处方已处理', icon: Icons.receipt_long, color: _prescriptionCount > 0 ? const Color(0xFFC2410C) : const Color(0xFF2E7D32)),
                              StatusPill(label: '下拉刷新数据', icon: Icons.swipe_down, color: const Color(0xFF1976D2)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String note;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.note});

  @override
  Widget build(BuildContext context) {
    return UiCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 24, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 2),
                  Text(note, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
