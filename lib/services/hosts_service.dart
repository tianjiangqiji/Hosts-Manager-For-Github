import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hosts_manager/models/host_entry.dart';

class HostsService {
  static const String hostsPath = r'C:\Windows\System32\drivers\etc\hosts';
  static const String githubHostsUrl = 'https://raw.hellogithub.com/hosts.json';

  static Future<List<HostEntry>> loadHostsFile() async {
    try {
      final file = File(hostsPath);
      if (!await file.exists()) {
        return [];
      }

      final lines = await file.readAsLines();
      final List<HostEntry> entries = [];

      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty || (line.startsWith('#') && !_isCommentedHostEntry(line))) {
          continue; // Skip empty lines and pure comments
        }

        try {
          final entry = HostEntry.fromLine(line);
          entries.add(entry);
        } catch (e) {
          // Skip invalid lines
          continue;
        }
      }

      return entries;
    } catch (e) {
      throw Exception('Failed to load hosts file: $e');
    }
  }

  static bool _isCommentedHostEntry(String line) {
    String trimmed = line.substring(1).trim();
    List<String> parts = trimmed.split(RegExp(r'\s+'));
    return parts.length >= 2 && _isValidIP(parts[0]);
  }

  static bool _isValidIP(String ip) {
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipRegex.hasMatch(ip);
  }

  static Future<void> saveHostsFile(List<HostEntry> entries) async {
    try {
      final file = File(hostsPath);
      
      // Read existing file to preserve other content
      List<String> existingLines = [];
      if (await file.exists()) {
        existingLines = await file.readAsLines();
      }

      // Filter out existing host entries, keep only comments and other content
      List<String> nonHostLines = [];
      for (String line in existingLines) {
        line = line.trim();
        if (line.isEmpty || (line.startsWith('#') && !_isCommentedHostEntry(line))) {
          nonHostLines.add(line);
        }
      }

      // Combine non-host lines with new entries
      List<String> newLines = [...nonHostLines];
      newLines.add(''); // Add empty line before host entries
      newLines.add('# Managed by Hosts Manager');
      
      for (HostEntry entry in entries) {
        newLines.add(entry.toHostsLine());
      }

      await file.writeAsString(newLines.join('\n'));
    } catch (e) {
      throw Exception('Failed to save hosts file: $e');
    }
  }

  static Future<List<HostEntry>> fetchGithubHosts() async {
    try {
      final response = await http.get(Uri.parse(githubHostsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => HostEntry.single(
          ip: item[0] as String,
          hostname: item[1] as String,
        )).toList();
      } else {
        throw Exception('Failed to fetch GitHub hosts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch GitHub hosts: $e');
    }
  }

  static List<HostEntry> mergeHosts(List<HostEntry> currentHosts, List<HostEntry> newHosts) {
    Map<String, HostEntry> hostMap = {};
    
    // Add current hosts to map (using primary hostname as key)
    for (HostEntry entry in currentHosts) {
      hostMap[entry.primaryHostname] = entry;
    }
    
    List<HostEntry> addedEntries = [];
    
    // Add new hosts, updating existing ones
    for (HostEntry newEntry in newHosts) {
      String key = newEntry.primaryHostname;
      if (hostMap.containsKey(key)) {
        HostEntry existing = hostMap[key]!;
        if (existing.ip != newEntry.ip) {
          // Update IP if different
          existing = HostEntry(
            ip: newEntry.ip,
            hostnames: existing.hostnames,
            isEnabled: existing.isEnabled,
            isComment: existing.isComment,
          );
          hostMap[key] = existing;
          addedEntries.add(existing);
        }
      } else {
        // Add new entry
        hostMap[key] = newEntry;
        addedEntries.add(newEntry);
      }
    }
    
    return addedEntries;
  }
}