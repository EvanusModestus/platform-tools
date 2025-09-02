# 🚀 ISE Log Parser - Quick Start

## Installation & Usage

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run the parser
python3 ise_log_parser.py -i example_ise.log

# 3. Export to different formats
python3 ise_log_parser.py -i example_ise.log -o report.json -f json
python3 ise_log_parser.py -i example_ise.log -o report.csv -f csv
```

## Features

- ✅ Parses Cisco ISE authentication logs
- ✅ Detects suspicious activity (brute force, MAC spoofing)
- ✅ Generates reports in multiple formats
- ✅ Rich terminal output with tables
- ✅ Handles large log files efficiently

## Example Output

The tool will:
1. Parse authentication events
2. Calculate success/failure rates
3. Identify top failure reasons
4. Detect security issues
5. Generate timeline analysis

Try it with the included `example_ise.log` file!