import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
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
          const Text('作者: skyjee'),
          const SizedBox(height: 8),
          Text('版本号: ${AppConstants.appVersion}'),
          const SizedBox(height: 16),
          const Text(
            '这是一个WinUI风格的hosts文件管理工具，可以帮助您轻松管理系统的hosts文件。',
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
          const Text('• WinUI风格的界面'),
          const SizedBox(height: 16),
          const Text(
            '开源项目：',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchUrl(AppConstants.githubUrl),
            child: Text(
              'https://github.com/tianjiangqiji/Hosts-Manager-For-Github',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '如果这个项目对您有帮助，请给我们一个 ⭐ Star！',
            style: TextStyle(fontSize: 13),
          ),
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
