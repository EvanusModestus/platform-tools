---
id: "ISE-AUTO-001"
title: "Cisco ISE Automation Toolkit"
parent: "NET-SEC-001"
type: "tool"
status: "production"
version: "3.2.0"
created: "2024-06-15"
modified: "2025-09-01"
tested_with:
  - ise_version: ["3.0", "3.1", "3.2", "3.3"]
  - python: ["3.8", "3.9", "3.10", "3.11"]
api_version: "ERS API v1.4"
author: "Evan Rosado"
tags: ["cisco", "ise", "automation", "rest-api", "802.1x", "radius"]
metrics:
  api_calls_optimized: "85%"
  deployment_time: "10 minutes"
  error_rate: "<0.1%"
---

# 🔐 Cisco ISE Automation Toolkit

> Production-ready Python toolkit for automating Cisco Identity Services Engine (ISE) deployments

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [API Reference](#-api-reference)
- [Examples](#-examples)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

### Core Capabilities
- ✅ **Policy Management**: Create, update, delete authorization policies
- ✅ **Endpoint Administration**: Bulk import/export, profiling
- ✅ **Network Device Management**: Add switches, WLCs, routers
- ✅ **Guest Portal**: Automate guest sponsor accounts
- ✅ **Certificate Management**: EAP-TLS certificate lifecycle
- ✅ **Compliance Reporting**: Automated audit reports
- ✅ **Change Tracking**: Git-like versioning for policies

### Performance Features
- 🚀 Connection pooling for high-volume operations
- 🔄 Automatic retry with exponential backoff
- 📊 Rate limiting to prevent API throttling
- 🎯 Batch operations for bulk changes
- 💾 Redis caching for frequently accessed data

## 📦 Prerequisites

```yaml
requirements:
  cisco_ise:
    version: ">=3.0"
    license: ["Base", "Plus", "Apex"]
  python:
    version: ">=3.8"
  network:
    connectivity: "HTTPS to ISE Admin Nodes"
    ports: [443, 9060]
```

## 🔧 Installation

### Method 1: pip install (Recommended)
```bash
pip install ise-automation-toolkit
```

### Method 2: From source
```bash
git clone https://github.com/EvanusModestus/ise-automation.git
cd ise-automation
pip install -e .
```

### Configuration
```bash
# Create environment file
cat > .env << EOF
ISE_HOST=ise.example.com
ISE_USERNAME=admin
ISE_PASSWORD=YourSecurePassword
ISE_VERIFY_SSL=true
ISE_TIMEOUT=30
ISE_MAX_RETRIES=3
REDIS_HOST=localhost
REDIS_PORT=6379
EOF
```

## 🚀 Quick Start

### Basic Usage
```python
from ise_automation import ISEController
import os

# Initialize controller
ise = ISEController(
    host=os.getenv("ISE_HOST"),
    username=os.getenv("ISE_USERNAME"),
    password=os.getenv("ISE_PASSWORD"),
    verify_ssl=True
)

# Create authorization policy
policy = ise.create_policy(
    name="Employee_WiFi_Access",
    condition_type="compound",
    conditions={
        "and": [
            {"attribute": "AD:ExternalGroups", "operator": "equals", "value": "Domain Users"},
            {"attribute": "Network Access:AuthenticationMethod", "operator": "equals", "value": "x509_PKI"}
        ]
    },
    profile="Employee_Access_Profile"
)

print(f"Policy created: {policy['id']}")
```

### Bulk Operations
```python
# Import endpoints from CSV
results = ise.bulk_import_endpoints(
    csv_file="endpoints.csv",
    batch_size=100,
    validate=True
)

print(f"Imported: {results['success']}")
print(f"Failed: {results['failed']}")
print(f"Errors: {results['errors']}")
```

## 📚 API Reference

### ISEController Class

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `create_policy()` | Create authorization policy | name, conditions, profile | Policy object |
| `bulk_import_endpoints()` | Import endpoints from CSV | csv_file, batch_size | Results dict |
| `create_network_device()` | Add network device | name, ip, shared_secret | Device object |
| `generate_report()` | Create compliance report | report_type, filters | Report URL |
| `backup_configuration()` | Backup ISE config | backup_type | Backup file path |

### Error Handling
```python
from ise_automation.exceptions import (
    ISEAuthenticationError,
    ISEPolicyError,
    ISERateLimitError
)

try:
    ise.create_policy(...)
except ISEAuthenticationError:
    print("Authentication failed - check credentials")
except ISEPolicyError as e:
    print(f"Policy error: {e.details}")
except ISERateLimitError:
    print("Rate limited - waiting before retry")
```

## 💡 Examples

### Example 1: 802.1X Deployment
```python
# Deploy complete 802.1X configuration
from ise_automation.templates import dot1x_deployment

deployment = dot1x_deployment.deploy(
    ise_controller=ise,
    vlan_mappings={
        "Employees": 100,
        "Contractors": 200,
        "Guests": 300,
        "IoT": 400
    },
    radius_servers=["10.0.1.10", "10.0.1.11"],
    certificate_template="Corporate_Device_Cert"
)
```

### Example 2: Guest Portal Automation
```python
# Create guest sponsor account
guest = ise.guest_portal.create_sponsor(
    username="contractor123",
    email="contractor@example.com",
    duration_days=90,
    portal="Contractor_Portal",
    send_email=True
)
```

## 🧪 Testing

```bash
# Run unit tests
pytest tests/unit/

# Run integration tests (requires ISE lab)
pytest tests/integration/ --ise-host=lab-ise.example.com

# Run with coverage
pytest --cov=ise_automation tests/
```

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| SSL Certificate Error | Set `ISE_VERIFY_SSL=false` for lab environments |
| Rate Limiting | Increase `ISE_TIMEOUT` and reduce batch size |
| Authentication Failure | Verify ERS API is enabled in ISE |
| Connection Timeout | Check firewall rules for port 9060 |

### Debug Mode
```python
# Enable debug logging
import logging
logging.basicConfig(level=logging.DEBUG)

ise = ISEController(..., debug=True)
```

## 📊 Performance Metrics

```yaml
benchmarks:
  single_policy_creation: "~500ms"
  bulk_endpoint_import:
    100_endpoints: "~5 seconds"
    1000_endpoints: "~45 seconds"
    10000_endpoints: "~7 minutes"
  api_cache_hit_rate: "85%"
  concurrent_operations: "50 threads"
```

## 🤝 Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - See [LICENSE](../../LICENSE)

## 🔗 Related Projects

- [802.1X Deployment Toolkit](../dot1x-deployment/)
- [RADIUS Profile Generator](../radius-profiles/)
- [Network Diagram Generator](../diagram-generator/)

---
*Part of the [Network Security Suite](../README.md)*