import 'package:fluent_ui/fluent_ui.dart';
import 'package:hosts_manager/models/host_entry.dart';

class AddHostDialog extends StatefulWidget {
  final HostEntry? editEntry;
  
  const AddHostDialog({super.key, this.editEntry});

  @override
  State<AddHostDialog> createState() => _AddHostDialogState();
}

class _AddHostDialogState extends State<AddHostDialog> {
  final _ipController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editEntry != null) {
      _ipController.text = widget.editEntry!.ip;
      _hostnameController.text = widget.editEntry!.hostnamesDisplay;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _hostnameController.dispose();
    super.dispose();
  }

  String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入IP地址';
    }
    
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(value)) {
      return '请输入有效的IP地址';
    }
    
    final parts = value.split('.');
    for (String part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return '请输入有效的IP地址';
      }
    }
    
    return null;
  }

  String? _validateHostname(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入主机名';
    }
    
    // Split by spaces or commas and validate each hostname
    List<String> hostnames = value.split(RegExp(r'[,\s]+'))
        .where((h) => h.isNotEmpty)
        .toList();
    
    if (hostnames.isEmpty) {
      return '请输入至少一个主机名';
    }
    
    // Basic hostname validation for each hostname
    final hostnameRegex = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-\.]*[a-zA-Z0-9])?$');
    for (String hostname in hostnames) {
      if (!hostnameRegex.hasMatch(hostname)) {
        return '主机名格式无效: $hostname';
      }
    }
    
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Parse hostnames from input (split by spaces or commas)
      List<String> hostnames = _hostnameController.text
          .split(RegExp(r'[,\s]+'))
          .where((h) => h.isNotEmpty)
          .toList();
      
      final entry = HostEntry(
        ip: _ipController.text.trim(),
        hostnames: hostnames,
      );
      Navigator.of(context).pop(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.editEntry != null;
    
    return ContentDialog(
      title: Text(isEditing ? '编辑hosts条目' : '添加新的hosts条目'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IP地址:'),
            const SizedBox(height: 8),
            TextFormBox(
              controller: _ipController,
              placeholder: '例如: 192.168.1.1',
              validator: _validateIP,
            ),
            const SizedBox(height: 16),
            const Text('主机名:'),
            const SizedBox(height: 4),
            const Text(
              '支持多个主机名，用空格或逗号分隔',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormBox(
              controller: _hostnameController,
              placeholder: '例如: example.com www.example.com api.example.com',
              validator: _validateHostname,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
}