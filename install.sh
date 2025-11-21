#!/bin/bash

#############################################################################
# RooGent Skills Installer
# 
# One-click installation script for RooGent Skills framework
# 
# This script will:
# - Create .roo directory structure in your home directory
# - Copy skill files and scripts
# - Backup existing files if they exist
# - Validate installation
# - Provide clear success/error messages
#############################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emoji support
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"

# Installation paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.roo"
BACKUP_DIR="${HOME}/.roo.backup.$(date +%Y%m%d_%H%M%S)"

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

#############################################################################
# Validation Functions
#############################################################################

validate_source_files() {
    print_info "Validating source files..."
    
    local missing_files=()
    
    # Check for required directories
    if [ ! -d "${SCRIPT_DIR}/.roo" ]; then
        missing_files+=(".roo directory")
    fi
    
    # Check for required core files
    local required_files=(
        ".roo/skills.index.json"
        ".roo/rules/skills-global.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${SCRIPT_DIR}/${file}" ]; then
            missing_files+=("${file}")
        fi
    done
    
    # Dynamically discover skills in the bundle
    if [ -d "${SCRIPT_DIR}/.roo/skills" ]; then
        for skill_dir in "${SCRIPT_DIR}/.roo/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                # Check for SKILL.md in each skill
                if [ ! -f "$skill_dir/SKILL.md" ]; then
                    missing_files+=(".roo/skills/${skill_name}/SKILL.md")
                fi
            fi
        done
    else
        missing_files+=(".roo/skills directory")
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - ${file}"
        done
        return 1
    fi
    
    print_success "All source files validated"
    return 0
}

#############################################################################
# Backup Functions
#############################################################################

backup_existing_files() {
    if [ -d "${TARGET_DIR}" ]; then
        print_warning "Existing .roo directory found"
        print_info "Creating backup at: ${BACKUP_DIR}"
        
        # Create backup directory
        mkdir -p "${BACKUP_DIR}"
        
        # Copy existing files to backup
        cp -r "${TARGET_DIR}"/* "${BACKUP_DIR}/" 2>/dev/null || true
        
        print_success "Backup created successfully"
        return 0
    else
        print_info "No existing .roo directory found (fresh installation)"
        return 0
    fi
}

#############################################################################
# Installation Functions
#############################################################################

create_directory_structure() {
    print_info "Creating directory structure..."
    
    # Create main directories
    mkdir -p "${TARGET_DIR}/skills"
    mkdir -p "${TARGET_DIR}/rules"
    
    # Dynamically create skill directories based on what's in the bundle
    if [ -d "${SCRIPT_DIR}/.roo/skills" ]; then
        for skill_dir in "${SCRIPT_DIR}/.roo/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                mkdir -p "${TARGET_DIR}/skills/${skill_name}"
                
                # Create scripts directory if it exists in source
                if [ -d "$skill_dir/scripts" ]; then
                    mkdir -p "${TARGET_DIR}/skills/${skill_name}/scripts"
                fi
            fi
        done
    fi
    
    print_success "Directory structure created"
}

copy_files() {
    print_info "Copying skill files..."
    
    # Copy skills.index.json
    cp "${SCRIPT_DIR}/.roo/skills.index.json" "${TARGET_DIR}/"
    print_success "Copied skills.index.json"
    
    # Copy rules
    cp "${SCRIPT_DIR}/.roo/rules/skills-global.md" "${TARGET_DIR}/rules/"
    print_success "Copied skills-global.md"
    
    # Dynamically copy all skills
    local skill_count=0
    if [ -d "${SCRIPT_DIR}/.roo/skills" ]; then
        for skill_dir in "${SCRIPT_DIR}/.roo/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                
                # Copy all files from skill directory
                cp -r "$skill_dir"/* "${TARGET_DIR}/skills/${skill_name}/"
                print_success "Copied ${skill_name} files"
                ((skill_count++))
            fi
        done
    fi
    
    print_success "Copied ${skill_count} skill(s)"
}

set_permissions() {
    print_info "Setting file permissions..."
    
    # Dynamically set permissions for all scripts in all skills
    local script_count=0
    if [ -d "${TARGET_DIR}/skills" ]; then
        for skill_dir in "${TARGET_DIR}/skills"/*; do
            if [ -d "$skill_dir/scripts" ]; then
                for script in "$skill_dir/scripts"/*.sh; do
                    if [ -f "$script" ]; then
                        chmod +x "$script" 2>/dev/null || true
                        ((script_count++))
                    fi
                done
            fi
        done
    fi
    
    print_success "Set permissions for ${script_count} script(s)"
}

#############################################################################
# Validation Functions
#############################################################################

validate_installation() {
    print_info "Validating installation..."
    
    local validation_errors=()
    
    # Check directory structure
    if [ ! -d "${TARGET_DIR}" ]; then
        validation_errors+=("Target directory ${TARGET_DIR} not found")
    fi
    
    if [ ! -d "${TARGET_DIR}/skills" ]; then
        validation_errors+=("Skills directory not found")
    fi
    
    if [ ! -d "${TARGET_DIR}/rules" ]; then
        validation_errors+=("Rules directory not found")
    fi
    
    # Check required core files
    if [ ! -f "${TARGET_DIR}/skills.index.json" ]; then
        validation_errors+=("skills.index.json not found")
    fi
    
    if [ ! -f "${TARGET_DIR}/rules/skills-global.md" ]; then
        validation_errors+=("skills-global.md not found")
    fi
    
    # Dynamically validate all skills
    if [ -d "${TARGET_DIR}/skills" ]; then
        for skill_dir in "${TARGET_DIR}/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                
                # Check for SKILL.md
                if [ ! -f "$skill_dir/SKILL.md" ]; then
                    validation_errors+=("SKILL.md not found for ${skill_name}")
                fi
                
                # Check if scripts directory exists and has executable scripts
                if [ -d "$skill_dir/scripts" ]; then
                    local has_scripts=false
                    for script in "$skill_dir/scripts"/*.sh; do
                        if [ -f "$script" ]; then
                            has_scripts=true
                            if [ ! -x "$script" ]; then
                                validation_errors+=("Script not executable: $(basename $script) in ${skill_name}")
                            fi
                        fi
                    done
                fi
            fi
        done
    fi
    
    # Validate JSON syntax
    if command -v python3 &> /dev/null; then
        if ! python3 -m json.tool "${TARGET_DIR}/skills.index.json" > /dev/null 2>&1; then
            validation_errors+=("Invalid JSON in skills.index.json")
        fi
    fi
    
    if [ ${#validation_errors[@]} -gt 0 ]; then
        print_error "Validation failed with the following errors:"
        for error in "${validation_errors[@]}"; do
            echo "  - ${error}"
        done
        return 1
    fi
    
    print_success "Installation validated successfully"
    return 0
}

#############################################################################
# Main Installation Flow
#############################################################################

main() {
    print_header "RooGent Skills Installer ${ROCKET}"
    
    echo "This script will install RooGent Skills to: ${TARGET_DIR}"
    echo ""
    
    # Step 1: Validate source files
    if ! validate_source_files; then
        print_error "Installation aborted: Source files validation failed"
        exit 1
    fi
    
    # Step 2: Backup existing files
    if ! backup_existing_files; then
        print_error "Installation aborted: Backup failed"
        exit 1
    fi
    
    # Step 3: Create directory structure
    if ! create_directory_structure; then
        print_error "Installation aborted: Failed to create directory structure"
        exit 1
    fi
    
    # Step 4: Copy files
    if ! copy_files; then
        print_error "Installation aborted: Failed to copy files"
        exit 1
    fi
    
    # Step 5: Set permissions
    if ! set_permissions; then
        print_warning "Warning: Failed to set some file permissions"
    fi
    
    # Step 6: Validate installation
    if ! validate_installation; then
        print_error "Installation completed but validation failed"
        print_warning "You may need to manually verify the installation"
        exit 1
    fi
    
    # Count installed skills
    local skill_count=0
    local skill_names=()
    if [ -d "${TARGET_DIR}/skills" ]; then
        for skill_dir in "${TARGET_DIR}/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                skill_names+=("$skill_name")
                ((skill_count++))
            fi
        done
    fi
    
    # Success!
    print_header "Installation Complete! ${CHECK}"
    
    echo -e "${GREEN}RooGent Skills has been successfully installed!${NC}"
    echo ""
    echo "Installation details:"
    echo "  - Location: ${TARGET_DIR}"
    echo "  - Skills installed: ${skill_count}"
    for skill_name in "${skill_names[@]}"; do
        echo "    • ${skill_name}"
    done
    
    if [ -d "${BACKUP_DIR}" ]; then
        echo ""
        echo "Backup created at: ${BACKUP_DIR}"
    fi
    
    echo ""
    echo "Next steps:"
    echo "  1. Configure your AI agent to use RooGent Skills"
    echo "  2. Try asking: 'Create a new skill for database backups'"
    echo "  3. Or: 'Check if it's safe to deploy to my-project'"
    echo ""
    echo "Documentation:"
    echo "  - README.md - Quick start guide"
    echo "  - OVERVIEW.md - Comprehensive framework documentation"
    echo ""
    print_success "Happy automating! ${ROCKET}"
}

#############################################################################
# Error Handling
#############################################################################

# Trap errors and provide helpful messages
trap 'print_error "Installation failed at line $LINENO. Please check the error message above."; exit 1' ERR

#############################################################################
# Execute Main
#############################################################################

main "$@"