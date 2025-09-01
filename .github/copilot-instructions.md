# Fasd - Fast Command-line File and Directory Navigation

Fasd is a POSIX shell script that provides quick access to files and directories by tracking your access patterns and offering fuzzy matching. This tool learns from your usage and allows rapid navigation using simple commands.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Setup
- No special dependencies required - fasd is a self-contained POSIX shell script
- Requires basic UNIX tools: awk, sed, grep (available on all POSIX systems)
- Works with bash, zsh, and other POSIX-compatible shells

### Installation and Build Process
Installation is extremely simple with no compilation required:

```bash
# Clone or navigate to repository
cd /path/to/fasd

# Install system-wide (requires sudo)
make install

# Install to custom location (e.g., $HOME/bin)
PREFIX=$HOME make install

# Install to specific directory for testing
make install PREFIX=/tmp/test-install
```

**Timing**: Installation takes less than 1 second - it simply copies the fasd script.

### Shell Integration and Initialization
After installation, fasd must be initialized in your shell to function properly:

```bash
# Add to your shell rc file (.bashrc, .zshrc, etc.)
eval "$(fasd --init auto)"

# For manual testing without permanent installation
eval "$(./fasd --init auto)"

# To see what initialization code does:
./fasd --init auto
```

This sets up:
- Command aliases (a, s, d, f, z, zz, etc.)
- Command hook that tracks your file/directory access
- Tab completion (in zsh and bash)

## Basic Usage and Functionality Testing

### Core Commands and Aliases
```bash
# Query commands
fasd -l        # List all tracked entries
fasd -d        # List directories
fasd -f        # List files  
fasd -a        # List files and directories

# Search with patterns
fasd -d project    # Find directories matching "project"
fasd -f main       # Find files matching "main"

# Manual database management  
fasd --add /path/to/directory    # Manually add path to database
fasd --delete /path/to/remove    # Remove path from database

# Available aliases after initialization:
a='fasd -a'        # Any (files + directories)
s='fasd -si'       # Show/search/select interactively  
d='fasd -d'        # Directories only
f='fasd -f'        # Files only
z='fasd_cd -d'     # Change to directory (like autojump)
zz='fasd_cd -d -i' # Interactive directory change
```

### Manual Validation Scenarios

**CRITICAL**: Always run these validation scenarios after making changes:

1. **Basic Installation Test**:
   ```bash
   # Test that fasd can be installed and runs
   make install PREFIX=/tmp/test-fasd
   /tmp/test-fasd/bin/fasd --version  # Should output: 1.0.4
   /tmp/test-fasd/bin/fasd --help     # Should show help text
   ```

2. **Database Creation and Querying Test**:
   ```bash
   # Ensure cache directory exists
   mkdir -p ~/.cache
   
   # Create test directories
   mkdir -p /tmp/test-scenario/{project1/src,project2/tests,docs}
   
   # Add entries and test querying
   ./fasd --add /tmp/test-scenario/project1/src
   ./fasd --add /tmp/test-scenario/project2/tests  
   ./fasd --add /tmp/test-scenario/docs
   
   # Validate database
   ./fasd -l  # Should list the added directories
   ./fasd -d project  # Should find both project directories
   ./fasd -d tests    # Should find project2/tests
   ```

3. **Shell Integration Test**:
   ```bash
   # Test that initialization works without errors
   bash -c 'eval "$(./fasd --init auto)" && echo "Fasd initialized successfully"'
   
   # Test alias generation
   ./fasd --init posix-alias | grep "alias.*fasd"
   ```

4. **File vs Directory Detection Test**:
   ```bash
   # Add both files and directories
   touch /tmp/test-file.txt
   mkdir -p /tmp/test-dir
   ./fasd --add /tmp/test-file.txt
   ./fasd --add /tmp/test-dir
   
   # Verify correct categorization
   ./fasd -f test-file  # Should find the file
   ./fasd -d test-dir   # Should find the directory
   ```

## Key Repository Structure

```
fasd/
├── fasd                    # Main executable script (676 lines)
├── README.md              # Comprehensive documentation (382 lines)  
├── LICENSE                # MIT license
├── Makefile               # Simple install/uninstall rules (18 lines)
├── fasd.plugin.zsh        # ZSH plugin wrapper
├── fasd.plugin/           # Plugin directory structure
└── .github/
    └── workflows/
        └── makefile.yml   # CI workflow (may have outdated targets)
```

### Important Files and Their Purpose

- **fasd**: The complete implementation - a self-contained POSIX shell script
- **README.md**: Extensive documentation with usage examples and configuration options
- **Makefile**: Minimal makefile with install/uninstall targets only
- **fasd.plugin.zsh**: ZSH plugin manager integration

## Configuration and Customization

Fasd behavior can be customized via environment variables set before sourcing:

```bash
# Common configuration options (set in ~/.config/fasd/config)
export _FASD_DATA="$HOME/.cache/fasd"           # Database file location
export _FASD_MAX=2000                           # Max database entries  
export _FASD_FUZZY=2                           # Fuzzy matching level
export _FASD_TRACK_PWD=1                       # Track current directory
export _FASD_BACKENDS="native"                 # Data backends
export _FASD_SINK="/dev/null"                 # Error log destination
```

## Development and Testing

### Making Changes
- **Never modify the fasd script directly without testing** - it's used by many shell sessions
- Test changes in a separate environment first:
  ```bash
  # Copy to test location
  cp fasd /tmp/fasd-test
  chmod +x /tmp/fasd-test
  
  # Test with custom database
  export _FASD_DATA="/tmp/test-fasd-db" 
  /tmp/fasd-test --add /some/test/path
  /tmp/fasd-test -l
  ```

### Common Debugging Steps
```bash
# Enable debug logging
export _FASD_SINK="$HOME/.fasd-debug.log"

# Check database contents
cat ~/.cache/fasd

# Reset database for clean testing  
rm ~/.cache/fasd

# Test with verbose awk output (if issues with scoring)
export _FASD_AWK="gawk"  # or mawk, nawk as preferred
```

## CI and Quality Assurance

The GitHub workflow at `.github/workflows/makefile.yml` exists but contains outdated targets:
- ✅ `make` - works (does nothing, exits cleanly)
- ❌ `make check` - target doesn't exist  
- ❌ `make distcheck` - target doesn't exist
- ❌ `./configure` - script doesn't exist

**Do not rely on CI workflow for validation** - use the manual validation scenarios above instead.

## Performance and Timing Expectations

- **Installation**: < 1 second (just file copy)
- **Initialization**: < 0.1 seconds  
- **Database queries**: < 0.1 seconds for typical databases (< 2000 entries)
- **Adding entries**: < 0.1 seconds

## Troubleshooting Common Issues

1. **"mktemp: failed to create file" error**: Create `~/.cache` directory
2. **No results from queries**: Ensure paths were added with `fasd --add` or by shell hook
3. **Aliases not working**: Ensure `eval "$(fasd --init auto)"` was run in current shell
4. **Permission errors**: Check ownership of `$_FASD_DATA` file (usually `~/.cache/fasd`)

## Quick Reference Commands

```bash
# Essential testing commands after any changes:
make install PREFIX=/tmp/test               # Test installation
./fasd --version                           # Verify script works
./fasd --help                             # Verify help text
mkdir -p ~/.cache && ./fasd --add /tmp    # Test database creation  
./fasd -l                                 # Test database query
bash -c 'eval "$(./fasd --init auto)"'   # Test shell integration
```

Always run these validation steps before considering changes complete.