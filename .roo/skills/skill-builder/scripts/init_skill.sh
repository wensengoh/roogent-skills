#!/bin/bash
set -e

# Skill Builder - Initialize New Skill
# Creates directory structure, templates, and helper scripts for a new RooGent skill

SKILL_NAME=$1

# Validate parameter
if [ -z "$SKILL_NAME" ]; then
    echo "❌ Error: Skill name required"
    echo "Usage: $0 <skill-name>"
    echo ""
    echo "Example: $0 my-awesome-skill"
    exit 1
fi

# Validate name format (lowercase with hyphens only)
if ! echo "$SKILL_NAME" | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$'; then
    echo "❌ Error: Invalid skill name format"
    echo ""
    echo "Requirements:"
    echo "  • Use lowercase letters only"
    echo "  • Separate words with hyphens"
    echo "  • Start with a letter"
    echo "  • End with a letter or number"
    echo ""
    echo "Valid examples:"
    echo "  ✅ pre-deployment-safety-checks"
    echo "  ✅ project-cost-analyzer"
    echo "  ✅ api-tester"
    echo ""
    echo "Invalid examples:"
    echo "  ❌ PreDeploymentSafetyChecks (no uppercase)"
    echo "  ❌ pre_deployment_safety_checks (use hyphens, not underscores)"
    echo "  ❌ -deployment (cannot start with hyphen)"
    exit 1
fi

# Define paths
SKILLS_DIR=".roo/skills"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"
SCRIPTS_DIR="$SKILL_DIR/scripts"

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    echo "❌ Error: Skill '$SKILL_NAME' already exists"
    echo ""
    echo "Location: $SKILL_DIR"
    echo ""
    echo "Options:"
    echo "  • Choose a different name"
    echo "  • Remove existing skill: rm -rf $SKILL_DIR"
    exit 1
fi

echo "🚀 Creating new skill: $SKILL_NAME"
echo "================================================"

# Create directory structure
echo "📦 Creating directories..."
mkdir -p "$SCRIPTS_DIR"
echo "  ✅ $SKILL_DIR"
echo "  ✅ $SCRIPTS_DIR"

# Generate SKILL.md template
echo ""
echo "📝 Generating SKILL.md..."
cat > "$SKILL_DIR/SKILL.md" << 'EOF'
---
name: SKILL_NAME_PLACEHOLDER
description: Brief description of what this skill does
tags: [category, keywords]
permissions: [execute_command]
required_mode: [code]
---

# Skill Name

## Overview

Explain what this skill does and when to use it.

## Instructions

1. Get required parameters from user
2. Run the helper script:
   ```bash
   .roo/skills/SKILL_NAME_PLACEHOLDER/scripts/example.sh <parameters>
   ```
3. Report results to user

## Prerequisites

- List any required tools or permissions
- Document environment setup needed

## Examples

Show typical usage patterns and expected outputs.
EOF

# Replace placeholder with actual skill name
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/SKILL.md"
echo "  ✅ $SKILL_DIR/SKILL.md"

# Generate example script
echo ""
echo "🔧 Creating example script..."
cat > "$SCRIPTS_DIR/example.sh" << 'EOF'
#!/bin/bash
set -e

# Example script for SKILL_NAME_PLACEHOLDER
# Replace this with your actual implementation

PARAM=$1

if [ -z "$PARAM" ]; then
    echo "❌ Error: Parameter required"
    echo "Usage: $0 <parameter>"
    exit 1
fi

echo "🔍 Running SKILL_NAME_PLACEHOLDER"
echo "================================================"
echo "📍 Parameter: $PARAM"
echo ""

# Your implementation here
echo "✅ Processing complete"

exit 0
EOF

# Replace placeholder with actual skill name
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SCRIPTS_DIR/example.sh"

# Set executable permissions
chmod +x "$SCRIPTS_DIR/example.sh"
echo "  ✅ $SCRIPTS_DIR/example.sh (executable)"

# Success message
echo ""
echo "================================================"
echo "✅ Skill '$SKILL_NAME' created successfully!"
echo ""
echo "📂 Location: $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md"
echo "     • Update description, tags, and permissions"
echo "     • Write clear instructions"
echo "     • Add usage examples"
echo ""
echo "  2. Implement $SCRIPTS_DIR/example.sh"
echo "     • Add your logic"
echo "     • Validate inputs"
echo "     • Provide helpful output"
echo ""
echo "  3. Register in .roo/skills.index.json"
echo "     • Add skill metadata"
echo "     • Include keywords for discovery"
echo "     • Specify required tools and modes"
echo ""
echo "  4. Test your skill"
echo "     • Run scripts directly"
echo "     • Test through RooGent"
echo ""
echo "🎉 Happy building!"

exit 0

