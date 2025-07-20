import 'package:fluent_ui/fluent_ui.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  String _getBuildTime() {
    // 获取编译时间
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('关于'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hosts Manager',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('作者: skyjee 版本: 1.0.1'),
          const SizedBox(height: 8),
          Text('编译时间: ${_getBuildTime()}'),
          const SizedBox(height: 16),
          const Text(
            '这是一个Windows风格的hosts文件管理工具，可以帮助您轻松管理系统的hosts文件。',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            '功能特性：',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• 查看和编辑hosts文件'),
          const Text('• 启用/禁用hosts条目'),
          const Text('• 添加新的hosts条目'),
          const Text('• 从GitHub获取最新hosts'),
          const Text('• Windows原生界面风格'),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('确定'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
