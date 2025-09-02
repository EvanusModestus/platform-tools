#!/bin/bash

# Create new technology lab with proper structure and metadata
# Usage: ./create-lab.sh --tech "GraphQL" --level "beginner"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
TECH=""
LEVEL="beginner"
AUTHOR="Evan Rosado"
BASE_DIR="../labs"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tech)
            TECH="$2"
            shift 2
            ;;
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --tech <technology> [--level <level>] [--author <name>]"
            echo "  --tech    Technology name (required)"
            echo "  --level   Difficulty level (beginner|intermediate|advanced|expert)"
            echo "  --author  Author name (default: Evan Rosado)"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$TECH" ]; then
    echo -e "${RED}Error: --tech is required${NC}"
    exit 1
fi

# Convert tech name to lowercase for directory
TECH_DIR=$(echo "$TECH" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
LAB_PATH="$BASE_DIR/$TECH_DIR"

# Check if lab already exists
if [ -d "$LAB_PATH" ]; then
    echo -e "${YELLOW}Warning: Lab for $TECH already exists at $LAB_PATH${NC}"
    read -p "Do you want to add projects to existing lab? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Generate UUIDs
generate_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        # Fallback UUID generation
        cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$(date +%s)-$(shuf -i 1000-9999 -n 1)"
    fi
}

DOC_UUID=$(generate_uuid)
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# Create directory structure
echo -e "${BLUE}Creating lab structure for $TECH...${NC}"

mkdir -p "$LAB_PATH"/{00-setup,01-beginner,02-intermediate,03-advanced,04-expert,05-integration}
mkdir -p "$LAB_PATH"/{resources,challenges,solutions,templates}
mkdir -p "$LAB_PATH"/01-beginner/{project-01,project-02,challenges}
mkdir -p "$LAB_PATH"/02-intermediate/{project-01,project-02,challenges}

# Create main README with metadata
cat > "$LAB_PATH/README.md" << EOF
---
document_uuid: "$DOC_UUID"
id: "$YEAR-LAB-${TECH^^}-001"
title: "$TECH Mastery Lab"
category: "labs"
subcategory: "technology-practice"
technology: "$TECH"
type: "skill-development"
status: "active"
version: "1.0.0"
difficulty_range: "$LEVEL-expert"
tags: ["$TECH_DIR", "practice", "portfolio", "skills"]
date_created: "$TODAY"
date_modified: "$TODAY"
author: "$AUTHOR"
estimated_hours: 40
prerequisites:
  - "Basic programming knowledge"
  - "Command line familiarity"
---

# 🚀 $TECH Mastery Lab

> Comprehensive hands-on lab for mastering $TECH

## 🎯 Learning Objectives

By completing this lab series, you will:
- ✅ Master $TECH fundamentals
- ✅ Build production-ready applications
- ✅ Implement best practices and patterns
- ✅ Create portfolio-worthy projects
- ✅ Integrate with other technologies

## 📊 Skill Progression Path

\`\`\`mermaid
graph LR
    A[Setup] --> B[Fundamentals]
    B --> C[Core Concepts]
    C --> D[Advanced Patterns]
    D --> E[Production Skills]
    E --> F[Integration Projects]
\`\`\`

## 🗂️ Lab Structure

- **00-setup/** - Environment setup and prerequisites
- **01-beginner/** - Core concepts and basics
- **02-intermediate/** - Real-world applications
- **03-advanced/** - Complex patterns and optimization
- **04-expert/** - Cutting-edge implementations
- **05-integration/** - Multi-technology projects

## 🚀 Quick Start

\`\`\`bash
# Start with setup
cd 00-setup
cat README.md

# Move to first project
cd ../01-beginner/project-01
\`\`\`

## 📈 Progress Tracking

Track your progress in \`progress.yaml\`

## 🎮 Challenges

Daily challenges available in \`challenges/\` directory

## 📚 Resources

- Official Documentation
- Community Tutorials
- Best Practices Guide

---
*Part of the [Technology Labs](../README.md)*
EOF

# Create setup guide
cat > "$LAB_PATH/00-setup/README.md" << EOF
---
id: "$YEAR-LAB-${TECH^^}-SETUP"
title: "$TECH Lab Environment Setup"
type: "setup-guide"
---

# 🔧 $TECH Environment Setup

## Prerequisites

- [ ] Install $TECH
- [ ] Configure development environment
- [ ] Verify installation

## Installation Steps

### Option 1: Docker (Recommended)
\`\`\`bash
# Add Docker setup commands here
\`\`\`

### Option 2: Native Installation
\`\`\`bash
# Add native installation commands here
\`\`\`

## Verification

\`\`\`bash
# Add verification commands here
\`\`\`

## Troubleshooting

Common issues and solutions...

---
*Next: [First Project](../01-beginner/project-01/)*
EOF

# Create first project
PROJECT_UUID=$(generate_uuid)
cat > "$LAB_PATH/01-beginner/project-01/README.md" << EOF
---
document_uuid: "$PROJECT_UUID"
id: "$YEAR-PROJ-${TECH^^}-001"
title: "Hello $TECH - First Project"
type: "project"
difficulty: "beginner"
estimated_hours: 2
---

# 📘 Project 1: Hello $TECH

## 🎯 Objectives

Learn the basics of $TECH by building a simple application.

## 📋 Requirements

- [ ] Set up $TECH project
- [ ] Implement basic functionality
- [ ] Add error handling
- [ ] Write tests
- [ ] Document code

## 🏗️ Implementation Steps

### Step 1: Project Setup
\`\`\`bash
# Project setup commands
\`\`\`

### Step 2: Basic Implementation
\`\`\`javascript
// Sample code here
\`\`\`

### Step 3: Testing
\`\`\`bash
# Test commands
\`\`\`

## ✅ Success Criteria

- Application runs without errors
- All tests pass
- Code is documented

## 🎓 What You'll Learn

- $TECH project structure
- Basic syntax and concepts
- Testing approach
- Best practices

## 📚 Resources

- [$TECH Documentation](https://docs.example.com)
- [Tutorial Video](https://youtube.com/example)

---
*Next: [Project 2](../project-02/)*
EOF

# Create progress tracker
cat > "$LAB_PATH/progress.yaml" << EOF
---
technology: "$TECH"
current_level: "$LEVEL"
start_date: "$TODAY"
total_hours: 0
completed_projects: []
completed_challenges: []
skills_acquired: []
next_goals:
  - "Complete setup"
  - "Finish first project"
  - "Master fundamentals"
notes: |
  Starting $TECH journey with focus on practical applications
  for network automation and platform engineering.
EOF

# Create a sample challenge
cat > "$LAB_PATH/challenges/daily-001.md" << EOF
---
id: "CHAL-${TECH^^}-$YEAR-001"
title: "First $TECH Challenge"
difficulty: "⭐⭐☆☆☆"
time_limit: "30 minutes"
tags: ["$TECH_DIR", "basics"]
---

# Daily Challenge: $TECH Basics

## 🎯 Objective

Your first $TECH challenge to test fundamental understanding.

## 📋 Requirements

1. Create a simple $TECH application
2. Implement specific functionality
3. Handle edge cases

## 🚀 Starter Code

\`\`\`javascript
// Your code here
\`\`\`

## ✅ Validation

- [ ] Code compiles/runs
- [ ] Produces expected output
- [ ] Handles errors gracefully

## 💡 Hints

- Think about...
- Consider using...
- Remember to...

## 📊 Solution

[View Solution](../solutions/daily-001.md) (Try yourself first!)

---
*[Back to Challenges](./)*
EOF

echo -e "${GREEN}✅ Lab structure created successfully!${NC}"
echo
echo -e "${BLUE}Lab created at: ${NC}$LAB_PATH"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd $LAB_PATH"
echo "2. Edit README.md to add specific learning objectives"
echo "3. Customize setup instructions in 00-setup/"
echo "4. Add project details in 01-beginner/project-01/"
echo "5. Create additional projects and challenges"
echo
echo -e "${GREEN}Happy learning with $TECH! 🚀${NC}"