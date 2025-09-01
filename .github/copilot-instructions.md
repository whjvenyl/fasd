# Fasd - Command-line Productivity Booster

Fasd is a self-contained POSIX shell script that provides quick access to files and directories for POSIX shells. It tracks files and directories you access by "frecency" (frequency + recency).

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Dependencies
- Install required dependencies:
  ```bash
  # Standard Unix tools (usually pre-installed)
  which awk sed grep sort
  
  # Verify awk variants available (fasd auto-detects best one)
  which mawk gawk nawk awk
  ```
- **CRITICAL**: Create cache directory before using fasd:
  ```bash
  mkdir -p ~/.cache
  ```
- No compilation needed - fasd is a single executable shell script

### Installation
- **System-wide install**:
  ```bash
  make install
  # Installs to /usr/local/bin/fasd
  ```
- **User install**:
  ```bash
  PREFIX=$HOME make install
  # Installs to $HOME/bin/fasd
  ```
- **Direct usage** (no installation):
  ```bash
  ./fasd --version  # Should output: 1.0.4
  ```

### Shell Integration
- **Basic initialization** (all shells):
  ```bash
  eval "$(fasd --init auto)"
  ```
- **Custom initialization** options:
  - `posix-alias` - Define standard aliases (a, s, d, f, z, zz)
  - `bash-hook` - Add command tracking hook
  - `bash-ccomp` - Command completion definitions
  - `bash-ccomp-install` - Install command completion
- **Example bash setup**:
  ```bash
  eval "$(fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install)"
  ```

## Validation

### ALWAYS validate fasd functionality with this complete scenario:
```bash
# 1. Initialize fasd
mkdir -p ~/.cache
eval "$(./fasd --init posix-alias bash-hook)"

# 2. Add test entries
./fasd -A /tmp/test-dir
./fasd -A /tmp/test-file.txt

# 3. Test basic queries
./fasd -l               # List all entries
./fasd -d test          # Query directories
./fasd -f test          # Query files
./fasd -s               # Show with scores

# 4. Test interactive mode (requires user input)
./fasd -si test         # Interactive selection

# 5. Verify aliases work (if initialized)
which z && z test-dir || echo "z alias not available"
```

### Performance Expectations
- **NEVER CANCEL**: All operations complete in under 1 second
- Initialization: ~0.004 seconds
- Adding entries: ~0.010 seconds  
- Queries: ~0.012 seconds
- No long-running operations exist in this project

### Manual Testing Scenarios
**CRITICAL**: After making changes, always run this validation:
1. **Basic functionality**: Initialize fasd, add entries, query them
2. **Shell integration**: Test in bash, sh, and dash if available
3. **Different modes**: Test directory-only (-d), file-only (-f), and interactive (-i) modes
4. **Backend testing**: Test with `-b current` backend
5. **Error handling**: Test with missing cache directory, invalid queries

## Common Tasks

### Repository Structure
```
/home/runner/work/fasd/fasd/
├── fasd                    # Main executable (676 lines of shell script)
├── README.md              # Comprehensive documentation  
├── LICENSE                # MIT license
├── Makefile               # Simple install script
├── .github/workflows/     # CI workflow (NOTE: references non-existent targets)
├── fasd.plugin/           # Plugin files
└── fasd.plugin.zsh        # ZSH plugin
```

### Key Functions in fasd script
- `fasd()` - Main function (line 43)
- `get_vcs()` - VCS detection (line 30)
- `fasd_cd()` - Directory changing function (line 125)
- Shell-specific hooks and completion functions

### Working with the Code
- **Main script**: All logic in single file `fasd` (POSIX shell script)
- **No build process**: Script is executed directly
- **Configuration**: Uses XDG Base Directory specification
  - Config: `$HOME/.config/fasd/config`
  - Data: `$HOME/.cache/fasd`

### Testing Changes
```bash
# Test basic functionality
./fasd --version
./fasd --help

# Test initialization modes
./fasd --init auto
./fasd --init posix-alias
./fasd --init bash-hook

# Validate with different shells
dash -c './fasd --version'
sh -c './fasd --version'
```

### Known Issues
- **GitHub Actions CI**: Workflow references `./configure` and `make check`/`make distcheck` which do not exist
- **Cache requirement**: Must create `~/.cache` directory before first use
- **Dependencies**: Requires POSIX-compliant shell and standard Unix utilities (awk, sed, grep, sort)

### Backends Available
- `current` - Files in current directory
- `viminfo` - Vim editing history  
- `recently-used` - GTK recently used files
- `spotlight` - macOS Spotlight (macOS only)

### Configuration Variables
Key environment variables (set in `$HOME/.config/fasd/config`):
- `_FASD_DATA` - Data file path
- `_FASD_MAX` - Max total score (default: 2000)
- `_FASD_FUZZY` - Fuzzy matching level (default: 2)
- `_FASD_SINK` - Error log file (default: /dev/null)

## Debugging
- Set `_FASD_SINK="$HOME/.fasd.log"` to enable logging
- Check `~/.cache/fasd` for database contents
- Use `-s` flag to see frecency scores
- Test with `-b current` to verify backend functionality