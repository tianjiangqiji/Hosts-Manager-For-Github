import 'dart:io';

class PermissionService {
  static Future<bool> isRunningAsAdmin() async {
    try {
      // 尝试创建一个临时文件在需要管理员权限的目录
      final testFile = File(r'C:\Windows\System32\drivers\etc\hosts_test_temp');
      
      // 尝试写入测试文件
      await testFile.writeAsString('test');
      
      // 如果成功，删除测试文件并返回true
      if (await testFile.exists()) {
        await testFile.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      // 如果出现权限错误，说明没有管理员权限
      return false;
    }
  }
  
  static Future<bool> canAccessHostsFile() async {
    try {
      final hostsFile = File(r'C:\Windows\System32\drivers\etc\hosts');
      
      // 尝试读取hosts文件
      await hostsFile.readAsString();
      
      // 尝试以追加模式打开文件（不实际写入）
      final randomAccess = await hostsFile.open(mode: FileMode.append);
      await randomAccess.close();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}