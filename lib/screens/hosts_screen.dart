import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hosts_manager/models/host_entry.dart';
import 'package:hosts_manager/services/hosts_service.dart';
import 'package:hosts_manager/services/permission_service.dart';
import 'package:hosts_manager/widgets/add_host_dialog.dart';
import 'package:hosts_manager/widgets/about_dialog.dart';

class HostsScreen extends StatefulWidget {
  const HostsScreen({super.key});

  @override
  State<HostsScreen> createState() => _HostsScreenState();
}

class _HostsScreenState extends State<HostsScreen> {
  List<HostEntry> _hostEntries = [];
  bool _isLoading = false;
  bool _hasAdminPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadHosts();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await PermissionService.canAccessHostsFile();
    setState(() {
      _hasAdminPermission = hasPermission;
    });
  }

  Future<void> _loadHosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await HostsService.loadHostsFile();
      setState(() {
        _hostEntries = entries;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('加载hosts文件失败', e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHosts() async {
    if (!_hasAdminPermission) {
      _showErrorDialog('权限不足', '请以管理员身份启动程序');
      return;
    }
    
    try {
      await HostsService.saveHostsFile(_hostEntries);
      if (mounted) {
        _showInfoDialog('成功', 'hosts文件已保存');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('保存hosts文件失败', e.toString());
      }
    }
  }

  Future<void> _addNewHost() async {
    final result = await showDialog<HostEntry>(
      context: context,
      builder: (context) => const AddHostDialog(),
    );

    if (result != null) {
      setState(() {
        _hostEntries.add(result);
      });
      await _saveHosts();
    }
  }

  Future<void> _updateGithubHosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final githubHosts = await HostsService.fetchGithubHosts();
      final addedEntries = HostsService.mergeHosts(_hostEntries, githubHosts);
      
      if (addedEntries.isEmpty) {
        if (mounted) {
          _showInfoDialog('提示', '已是最新hosts');
        }
      } else {
        setState(() {
          _hostEntries = [..._hostEntries];
          // Update existing entries and add new ones
          for (HostEntry newEntry in githubHosts) {
            int existingIndex = _hostEntries.indexWhere((e) => e.primaryHostname == newEntry.primaryHostname);
            if (existingIndex != -1) {
              if (_hostEntries[existingIndex].ip != newEntry.ip) {
                _hostEntries[existingIndex] = HostEntry(
                  ip: newEntry.ip,
                  hostnames: _hostEntries[existingIndex].hostnames,
                  isEnabled: _hostEntries[existingIndex].isEnabled,
                  isComment: _hostEntries[existingIndex].isComment,
                );
              }
            } else {
              _hostEntries.add(newEntry);
            }
          }
        });
        await _saveHosts();
        if (mounted) {
          _showInfoDialog('成功', '已更新 ${addedEntries.length} 个hosts条目');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('获取GitHub hosts失败', e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => const AboutDialog(),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _toggleHostEntry(int index) {
    setState(() {
      _hostEntries[index].isEnabled = !_hostEntries[index].isEnabled;
    });
    _saveHosts();
  }

  void _deleteHostEntry(int index) {
    setState(() {
      _hostEntries.removeAt(index);
    });
    _saveHosts();
  }

  Future<void> _editHostEntry(int index) async {
    final result = await showDialog<HostEntry>(
      context: context,
      builder: (context) => AddHostDialog(editEntry: _hostEntries[index]),
    );

    if (result != null) {
      setState(() {
        _hostEntries[index] = result;
      });
      await _saveHosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Container(
          height: 40, // 固定标题栏高度
          child: Row(
            children: [
              const Text('Hosts Manager'),
              const SizedBox(width: 16),
              Container(
                height: 24, // 固定标签高度
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _hasAdminPermission ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasAdminPermission ? FluentIcons.shield : FluentIcons.warning,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _hasAdminPermission ? '管理员' : '无权限',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false, // 隐藏返回按钮
        actions: Container(
          height: 40, // 固定按钮区域高度
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: _hasAdminPermission ? '添加新的hosts条目' : '请以管理员身份启动',
                child: SizedBox(
                  height: 32, // 固定按钮高度
                  child: Button(
                    onPressed: (_isLoading || !_hasAdminPermission) ? null : _addNewHost,
                    child: const Text('新增'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32, // 固定按钮高度
                child: Button(
                  onPressed: _isLoading ? null : _loadHosts,
                  child: const Text('刷新'),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _hasAdminPermission ? '从GitHub获取最新hosts' : '请以管理员身份启动',
                child: SizedBox(
                  height: 32, // 固定按钮高度
                  child: Button(
                    onPressed: (_isLoading || !_hasAdminPermission) ? null : _updateGithubHosts,
                    child: const Text('获取GitHub新地址'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32, // 固定按钮高度
                child: Button(
                  onPressed: _showAbout,
                  child: const Text('关于'),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
      content: _isLoading
          ? const Center(child: ProgressRing())
          : _buildHostsList(),
    );
  }

  Widget _buildHostsList() {
    if (_hostEntries.isEmpty) {
      return const Center(
        child: Text('没有hosts条目'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hostEntries.length,
      itemBuilder: (context, index) {
        final entry = _hostEntries[index];
        // 计算需要的高度，基于主机名数量
        int hostnameCount = entry.hostnames.length;
        double itemHeight = math.max(60, 40 + (hostnameCount > 6 ? (hostnameCount - 6) * 16 : 0));
        
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: Container(
            constraints: BoxConstraints(minHeight: itemHeight),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                alignment: Alignment.topLeft,
                child: Checkbox(
                  checked: entry.isEnabled,
                  onChanged: _hasAdminPermission ? (_) => _toggleHostEntry(index) : null,
                ),
              ),
              title: Container(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Text(
                  entry.hostnamesDisplay,
                  style: TextStyle(
                    decoration: entry.isEnabled ? null : TextDecoration.lineThrough,
                    color: entry.isEnabled ? null : Colors.grey,
                    fontSize: 14,
                  ),
                  maxLines: null, // 允许多行显示
                  overflow: TextOverflow.visible,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  entry.ip,
                  style: TextStyle(
                    color: entry.isEnabled ? null : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: Container(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: _hasAdminPermission ? '编辑hosts条目' : '请以管理员身份启动',
                      child: Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(FluentIcons.edit, size: 16),
                          onPressed: _hasAdminPermission ? () => _editHostEntry(index) : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: _hasAdminPermission ? '删除hosts条目' : '请以管理员身份启动',
                      child: Container(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(FluentIcons.delete, size: 16),
                          onPressed: _hasAdminPermission ? () => _deleteHostEntry(index) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}