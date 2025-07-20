# Hosts Manager

一个Windows风格的hosts文件管理工具，使用Flutter开发。可以自动同步 GitHub 可用 IP

## 功能特性

- ✅ Windows原生界面风格
- ✅ 查看和编辑hosts文件
- ✅ **多主机名支持** - 一个IP可对应多个主机名
- ✅ 启用/禁用hosts条目（通过复选框控制）
- ✅ 添加新的hosts条目（支持多主机名输入）
- ✅ **编辑现有条目** - 每个条目都有编辑按钮
- ✅ **刷新功能** - 重新加载hosts文件
- ✅ 从GitHub获取最新hosts配置
- ✅ 自动合并和更新hosts条目
- ✅ 支持注释掉的hosts条目识别
- ✅ **管理员权限检测** - 实时显示权限状态
- ✅ **权限保护** - 无权限时禁用修改功能
- ✅ **自适应列表高度** - 多主机名时自动调整列表项高度
- ✅ **最小窗口大小限制** - 使用Windows API确保最小窗口尺寸(1000x700)
- ✅ **统一界面高度** - 标题栏标签和按钮高度保持一致

## 安装和运行

### 前提条件

1. 安装Flutter SDK
2. 确保Windows开发环境已配置

### 运行步骤

1. 克隆或下载项目

2. **编译Windows平台**：
   ```bash
   flutter pub get
   flutter run -d windows
   ```

### 权限要求

- 程序可以在普通权限下启动和查看hosts文件
- **修改hosts文件需要管理员权限**
- 程序会实时检测权限状态并在标题栏显示
- 无管理员权限时，修改相关功能会被禁用并显示提示

## 文件结构

```
lib/
├── main.dart                 # 应用入口
├── hosts_manager_app.dart    # 应用主体
├── models/
│   └── host_entry.dart       # hosts条目数据模型
├── services/
│   └── hosts_service.dart    # hosts文件操作服务
├── screens/
│   └── hosts_screen.dart     # 主界面
└── widgets/
    ├── add_host_dialog.dart  # 添加hosts对话框
    └── about_dialog.dart     # 关于对话框
```

## 致谢
[Github 优选IP提供](https://github.com/521xueweihan/GitHub520)

## MIT 许可证
此项目采用MIT许可证，详情请参阅 [LICENSE](LICENSE) 文件。
