---
name: skill-builder
description: Create and scaffold new RooGent skills with proper structure, documentation templates, and helper scripts. Use when building custom automation capabilities.
tags: [skill-development, framework, automation, meta, roogent-skill, tooling, scaffolding]
permissions: [read_file, write_to_file, execute_command]
required_mode: [code]
---

# 🛠️ Skill Builder

## Overview

The skill-builder helps you create new RooGent skills with the correct directory structure, documentation templates, and helper scripts. Use this when building custom automation or extending RooGent capabilities.

## 🚀 Quick Start

To create a new skill:

```bash
.roo/skills/skill-builder/scripts/init_skill.sh my-skill-name
```

This generates:
- `.roo/skills/my-skill-name/` directory
- `SKILL.md` with proper frontmatter and structure
- `scripts/` directory with example script
- Executable permissions set automatically

## 📋 Instructions

### 1. Initialize the Skill

Run the initialization script with your skill name:

```bash
.roo/skills/skill-builder/scripts/init_skill.sh <skill-name>
```

**Naming requirements:**
- Use lowercase letters only
- Separate words with hyphens (kebab-case)
- Be descriptive but concise
- Examples: `pre-deployment-safety-checks`, `project-cost-analyzer`, `api-tester`

### 2. Edit SKILL.md

Open `.roo/skills/<skill-name>/SKILL.md` and customize:

1. **Frontmatter**: Update description, tags, permissions, and required_mode
2. **Overview**: Explain what the skill does and when to use it
3. **Instructions**: Provide step-by-step usage guide
4. **Examples**: Show expected inputs and outputs

### 3. Create Helper Scripts

Add scripts to `.roo/skills/<skill-name>/scripts/`:

```bash
# Create your script
touch .roo/skills/<skill-name>/scripts/my_script.sh

# Make it executable
chmod +x .roo/skills/<skill-name>/scripts/my_script.sh
```

**Script guidelines:**
- Start with `#!/bin/bash` and `set -e`
- Validate input parameters early
- Use emoji in output for clarity (🚀 ✅ ❌ ⚠️)
- Provide helpful error messages
- Exit with appropriate codes (0 = success, 1 = error)

### 4. Register the Skill

Add your skill to `.roo/skills.index.json`:

```json
{
  "name": "your-skill-name",
  "description": "Brief description of what it does",
  "tags": ["relevant", "tags"],
  "path": ".roo/skills/your-skill-name",
  "keywords": ["searchable", "terms"],
  "required_tools": ["execute_command"],
  "required_modes": ["code"]
}
```

### 5. Test the Skill

Verify your skill works:

```bash
# Test the script directly
.roo/skills/<skill-name>/scripts/your_script.sh <test-params>

# Test through RooGent
# Ask RooGent to use your skill with appropriate parameters
```

## 📝 SKILL.md Template Structure

```markdown
---
name: skill-name
description: What this skill does
tags: [category, keywords]
permissions: [required_tools]
required_mode: [allowed_modes]
---

# Skill Name

## Overview
Brief explanation of purpose and use cases

## Instructions
1. Step one with details
2. Step two with examples
3. Step three with expected results

## Prerequisites
- Required tools or permissions
- Environment setup needed

## Examples
Show typical usage patterns
```

## 🎯 Best Practices

### Documentation
- ✅ Use clear, action-oriented language
- ✅ Include code examples with syntax highlighting
- ✅ Show expected outputs for clarity
- ✅ Document prerequisites and dependencies
- ✅ Use emoji markers for visual scanning

### Scripts
- ✅ Validate all input parameters
- ✅ Provide informative error messages
- ✅ Use consistent exit codes
- ✅ Add comments for complex logic
- ✅ Test with various inputs

### Organization
- ✅ Keep related scripts in `scripts/` directory
- ✅ Use descriptive file names
- ✅ Set proper file permissions
- ✅ Document script parameters in SKILL.md

### Registration
- ✅ Choose relevant tags for discoverability
- ✅ Include comprehensive keywords
- ✅ Specify accurate tool requirements
- ✅ List appropriate modes

## 🔧 Helper Script Reference

### init_skill.sh

**Purpose**: Bootstrap a new skill with proper structure

**Usage**:
```bash
.roo/skills/skill-builder/scripts/init_skill.sh <skill-name>
```

**Parameters**:
- `skill-name`: Name in kebab-case (lowercase-with-hyphens)

**Output**:
- Creates skill directory structure
- Generates SKILL.md template
- Creates example script
- Sets executable permissions
- Provides next steps

**Validation**:
- Checks name format (lowercase, hyphens only)
- Prevents overwriting existing skills
- Ensures parent directories exist

## 💡 Common Patterns

### GCP Integration
```bash
# Get project ID from user
# Run gcloud commands
# Parse and format output
# Report results with emoji
```

### API Interaction
```bash
# Validate credentials
# Make API requests
# Handle errors gracefully
# Format response data
```

### File Processing
```bash
# Check file exists
# Validate file format
# Process content
# Generate output
```

## ⚠️ Troubleshooting

**Skill not found**: Ensure it's registered in `.roo/skills.index.json`

**Permission denied**: Run `chmod +x` on script files

**Invalid name format**: Use lowercase letters and hyphens only

**Skill already exists**: Choose a different name or remove existing skill

