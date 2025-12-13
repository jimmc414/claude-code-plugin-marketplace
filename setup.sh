#!/bin/bash
# Quick setup script for the Claude Code Plugin Marketplace
#
# Usage: ./setup.sh

set -e

echo "Setting up Claude Code Plugin Marketplace..."
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Python version: $PYTHON_VERSION"

# Make tools executable
echo "Making tools executable..."
chmod +x tools/*.py 2>/dev/null || true

# Make example plugin scripts executable
if [ -d "plugins/example-deployment/scripts" ]; then
    chmod +x plugins/example-deployment/scripts/*.sh 2>/dev/null || true
fi

# Validate JSON files
echo "Validating JSON files..."
for json_file in $(find . -name "*.json" -not -path "./.git/*"); do
    if ! python3 -m json.tool "$json_file" > /dev/null 2>&1; then
        echo "  Warning: Invalid JSON in $json_file"
    fi
done

# Validate existing plugins
echo "Validating plugins..."
if [ -d "plugins" ]; then
    for plugin_dir in plugins/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            if python3 tools/validate.py "$plugin_name" > /dev/null 2>&1; then
                echo "  $plugin_name: OK"
            else
                echo "  $plugin_name: ISSUES FOUND"
            fi
        fi
    done
fi

# Generate catalog
echo "Generating catalog..."
python3 tools/generate_catalog.py

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo ""
echo "  1. Create your first plugin:"
echo "     python tools/scaffold.py plugin my-first-plugin"
echo ""
echo "  2. Add components:"
echo "     python tools/scaffold.py command my-cmd --plugin my-first-plugin"
echo "     python tools/scaffold.py skill my-skill --plugin my-first-plugin"
echo ""
echo "  3. Validate:"
echo "     python tools/validate.py my-first-plugin"
echo ""
echo "  4. Test locally in Claude Code:"
echo "     /plugin marketplace add ./$(basename $(pwd))"
echo "     /plugin install my-first-plugin@community-claude-plugins"
echo ""
echo "  5. Push to GitHub and share:"
echo "     /plugin marketplace add yourname/this-repo"
echo ""
