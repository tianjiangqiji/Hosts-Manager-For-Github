class HostEntry {
  final String ip;
  final List<String> hostnames;
  bool isEnabled;
  bool isComment;

  HostEntry({
    required this.ip,
    required this.hostnames,
    this.isEnabled = true,
    this.isComment = false,
  });

  // Constructor for single hostname (backward compatibility)
  HostEntry.single({
    required this.ip,
    required String hostname,
    this.isEnabled = true,
    this.isComment = false,
  }) : hostnames = [hostname];

  factory HostEntry.fromLine(String line) {
    String trimmedLine = line.trim();
    bool isComment = trimmedLine.startsWith('#');
    
    if (isComment) {
      // Remove the # and any following whitespace
      trimmedLine = trimmedLine.substring(1).trim();
    }
    
    List<String> parts = trimmedLine.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      String ip = parts[0];
      List<String> hostnames = parts.sublist(1);
      return HostEntry(
        ip: ip,
        hostnames: hostnames,
        isEnabled: !isComment,
        isComment: isComment,
      );
    }
    
    throw ArgumentError('Invalid host line: $line');
  }

  String toHostsLine() {
    String line = '$ip\t${hostnames.join(' ')}';
    if (!isEnabled) {
      line = '# $line';
    }
    return line;
  }

  // Get primary hostname (first one)
  String get primaryHostname => hostnames.isNotEmpty ? hostnames.first : '';

  // Get all hostnames as a formatted string
  String get hostnamesDisplay => hostnames.join(', ');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HostEntry &&
        other.ip == ip &&
        _listEquals(other.hostnames, hostnames);
  }

  @override
  int get hashCode => ip.hashCode ^ hostnames.join(',').hashCode;

  @override
  String toString() {
    return 'HostEntry(ip: $ip, hostnames: $hostnames, isEnabled: $isEnabled)';
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}