#!/usr/bin/env python3
"""
ISE Log Parser - Extract insights from Cisco ISE authentication logs
Author: Evan Rosado
Version: 1.0.0
"""

import re
import json
import sys
from datetime import datetime
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import click
import pandas as pd
from rich.console import Console
from rich.table import Table
from rich.progress import track

console = Console()


class ISELogParser:
    """Parse and analyze Cisco ISE authentication logs"""
    
    # Common ISE log patterns
    PATTERNS = {
        'timestamp': r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})',
        'message_code': r'(\d{5})',
        'username': r'User-Name=([^,\s]+)',
        'mac_address': r'Calling-Station-ID=([0-9A-Fa-f:.-]+)',
        'ip_address': r'Framed-IP-Address=(\d+\.\d+\.\d+\.\d+)',
        'nas_ip': r'NAS-IP-Address=(\d+\.\d+\.\d+\.\d+)',
        'auth_status': r'(PASSED|FAILED)',
        'failure_reason': r'FailureReason=([^,]+)',
        'endpoint_profile': r'EndpointProfile=([^,]+)',
        'device_type': r'Device Type=([^,]+)',
        'auth_protocol': r'Protocol=([^,\s]+)',
    }
    
    # ISE message codes
    MESSAGE_CODES = {
        '5200': 'Authentication succeeded',
        '5400': 'Authentication failed',
        '5411': 'Invalid credentials',
        '5434': 'Endpoint not found',
        '5440': 'Endpoint abandoned EAP session',
        '11036': 'Authorization profile matched',
        '11051': 'Guest authentication failed',
        '86013': 'EAP timeout',
        '86014': 'EAP failure',
    }
    
    def __init__(self):
        self.logs = []
        self.parsed_entries = []
        
    def parse_file(self, filepath: Path) -> None:
        """Parse ISE log file"""
        console.print(f"[cyan]Parsing {filepath}...[/cyan]")
        
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            self.logs = f.readlines()
            
        for line in track(self.logs, description="Processing logs..."):
            entry = self._parse_line(line)
            if entry:
                self.parsed_entries.append(entry)
                
        console.print(f"[green]✓ Parsed {len(self.parsed_entries)} log entries[/green]")
    
    def _parse_line(self, line: str) -> Optional[Dict]:
        """Parse a single log line"""
        entry = {}
        
        # Extract fields using patterns
        for field, pattern in self.PATTERNS.items():
            match = re.search(pattern, line)
            if match:
                entry[field] = match.group(1)
        
        # Parse message code meaning
        if 'message_code' in entry:
            code = entry['message_code']
            entry['message_description'] = self.MESSAGE_CODES.get(code, 'Unknown')
        
        # Clean MAC address format
        if 'mac_address' in entry:
            entry['mac_address'] = self._normalize_mac(entry['mac_address'])
        
        return entry if entry else None
    
    def _normalize_mac(self, mac: str) -> str:
        """Normalize MAC address to XX:XX:XX:XX:XX:XX format"""
        mac = re.sub(r'[.:-]', '', mac)
        mac = mac.upper()
        return ':'.join(mac[i:i+2] for i in range(0, 12, 2))
    
    def analyze(self) -> Dict:
        """Analyze parsed logs for insights"""
        if not self.parsed_entries:
            return {}
        
        df = pd.DataFrame(self.parsed_entries)
        
        analysis = {
            'total_events': len(df),
            'unique_users': df['username'].nunique() if 'username' in df else 0,
            'unique_devices': df['mac_address'].nunique() if 'mac_address' in df else 0,
            'auth_summary': {},
            'top_failures': [],
            'suspicious_activity': [],
            'timeline': {}
        }
        
        # Authentication summary
        if 'auth_status' in df:
            status_counts = df['auth_status'].value_counts().to_dict()
            analysis['auth_summary'] = status_counts
            
            # Calculate success rate
            total = sum(status_counts.values())
            passed = status_counts.get('PASSED', 0)
            analysis['success_rate'] = f"{(passed/total)*100:.2f}%" if total > 0 else "0%"
        
        # Top failure reasons
        if 'failure_reason' in df:
            failures = df[df['auth_status'] == 'FAILED']['failure_reason'].value_counts().head(10)
            analysis['top_failures'] = [(reason, count) for reason, count in failures.items()]
        
        # Detect suspicious patterns
        analysis['suspicious_activity'] = self._detect_suspicious(df)
        
        # Timeline analysis
        if 'timestamp' in df:
            df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
            df = df.dropna(subset=['timestamp'])
            if not df.empty:
                df['hour'] = df['timestamp'].dt.hour
                hourly = df.groupby('hour').size().to_dict()
                analysis['timeline'] = hourly
        
        return analysis
    
    def _detect_suspicious(self, df: pd.DataFrame) -> List[Dict]:
        """Detect suspicious authentication patterns"""
        suspicious = []
        
        # Check for brute force attempts (multiple failures from same source)
        if 'username' in df and 'auth_status' in df:
            user_fails = df[df['auth_status'] == 'FAILED'].groupby('username').size()
            for user, count in user_fails.items():
                if count >= 5:
                    suspicious.append({
                        'type': 'Potential brute force',
                        'user': user,
                        'failed_attempts': count
                    })
        
        # Check for MAC spoofing (same MAC, different users)
        if 'mac_address' in df and 'username' in df:
            mac_users = df.groupby('mac_address')['username'].nunique()
            for mac, user_count in mac_users.items():
                if user_count > 2:
                    suspicious.append({
                        'type': 'Possible MAC spoofing',
                        'mac': mac,
                        'user_count': user_count
                    })
        
        return suspicious
    
    def generate_report(self, analysis: Dict, format: str = 'table') -> str:
        """Generate analysis report"""
        if format == 'table':
            return self._generate_table_report(analysis)
        elif format == 'json':
            return json.dumps(analysis, indent=2, default=str)
        elif format == 'csv':
            df = pd.DataFrame(self.parsed_entries)
            return df.to_csv(index=False)
        else:
            return str(analysis)
    
    def _generate_table_report(self, analysis: Dict) -> str:
        """Generate rich table report"""
        # Summary table
        summary = Table(title="ISE Log Analysis Summary", title_style="bold magenta")
        summary.add_column("Metric", style="cyan")
        summary.add_column("Value", style="green")
        
        summary.add_row("Total Events", str(analysis.get('total_events', 0)))
        summary.add_row("Unique Users", str(analysis.get('unique_users', 0)))
        summary.add_row("Unique Devices", str(analysis.get('unique_devices', 0)))
        summary.add_row("Success Rate", analysis.get('success_rate', 'N/A'))
        
        console.print(summary)
        
        # Auth summary
        if analysis.get('auth_summary'):
            auth_table = Table(title="Authentication Summary", title_style="bold cyan")
            auth_table.add_column("Status", style="yellow")
            auth_table.add_column("Count", style="white")
            
            for status, count in analysis['auth_summary'].items():
                auth_table.add_row(status, str(count))
            
            console.print(auth_table)
        
        # Top failures
        if analysis.get('top_failures'):
            failure_table = Table(title="Top Failure Reasons", title_style="bold red")
            failure_table.add_column("Reason", style="red")
            failure_table.add_column("Count", style="white")
            
            for reason, count in analysis['top_failures']:
                failure_table.add_row(reason, str(count))
            
            console.print(failure_table)
        
        # Suspicious activity
        if analysis.get('suspicious_activity'):
            console.print("\n[bold red]⚠️  Suspicious Activity Detected:[/bold red]")
            for item in analysis['suspicious_activity']:
                console.print(f"  • {item['type']}: {item}")
        
        return ""


@click.command()
@click.option('--input', '-i', type=click.Path(exists=True), required=True, help='ISE log file path')
@click.option('--output', '-o', type=click.Path(), help='Output file path')
@click.option('--format', '-f', type=click.Choice(['table', 'json', 'csv']), default='table', help='Output format')
@click.option('--analyze/--no-analyze', default=True, help='Perform analysis')
def main(input, output, format, analyze):
    """
    ISE Log Parser - Extract insights from Cisco ISE logs
    
    Examples:
        python ise_log_parser.py -i ise_auth.log
        python ise_log_parser.py -i ise_auth.log -o report.json -f json
        python ise_log_parser.py -i ise_auth.log -o events.csv -f csv
    """
    parser = ISELogParser()
    
    try:
        # Parse the log file
        parser.parse_file(Path(input))
        
        if analyze:
            # Analyze the logs
            analysis = parser.analyze()
            
            # Generate report
            report = parser.generate_report(analysis, format)
            
            # Save to file if specified
            if output:
                with open(output, 'w') as f:
                    f.write(report if format != 'table' else json.dumps(analysis, indent=2, default=str))
                console.print(f"[green]✓ Report saved to {output}[/green]")
        else:
            # Just dump parsed data
            df = pd.DataFrame(parser.parsed_entries)
            if output:
                if format == 'csv':
                    df.to_csv(output, index=False)
                elif format == 'json':
                    df.to_json(output, orient='records', indent=2)
                console.print(f"[green]✓ Data saved to {output}[/green]")
            else:
                console.print(df)
                
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)


if __name__ == '__main__':
    main()