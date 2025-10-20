# Changes in This Release

This release addresses three main requirements:
1. Speed improvements
2. Benchmark suite
3. Deepjump feature

## Speed Improvements

### Optimized Query Algorithm
- **Single-pass AWK processing**: Combined deduplication, scoring, and filtering into a single AWK pass
- **Reduced subshell spawning**: Moved file existence checks from shell while-loops to AWK END block
- **Performance**: ~75 queries/sec with 13ms average latency (200 entries), ~64 queries/sec with 15ms average latency (1000 entries)

### Database Initialization Fix
- Fixed bug where fasd couldn't create database on first use
- Now properly handles non-existent database file by using /dev/null as input

### Database Cleanup Command
- Added `--clean` command to remove non-existent paths from database
- Helps maintain database performance by removing stale entries
- Usage: `fasd --clean`

## Benchmark Suite

Created `benchmark.sh` - a comprehensive performance testing tool that:

### Features
- Configurable test parameters (database size, number of queries)
- Tests multiple query types: simple patterns, multi-word, fuzzy, recent, rank-based
- Measures database operations (add, delete)
- Reports memory usage
- Compares with alternative tools (pazi, jump) if installed

### Usage
```bash
# Default settings (1000 entries, 100 queries)
./benchmark.sh

# Custom settings
BENCHMARK_DATA_SIZE=500 BENCHMARK_QUERIES=50 ./benchmark.sh

# Custom fasd binary
FASD_BIN=/path/to/fasd ./benchmark.sh
```

### Sample Output
```
============================================
Query Performance Tests
============================================

Running: Query with simple pattern (project)
  Total: 780ms
  Average: 15ms per query
  Throughput: 64 queries/sec

Running: Fuzzy query
  Total: 259ms
  Average: 12ms per query
  Throughput: 77 queries/sec
```

## Deepjump Feature

Implemented jump to VCS root functionality, similar to [jump](https://github.com/gsamokovarov/jump).

### How It Works
When you access a deeply nested directory within a VCS repository, deepjump takes you to the repository root instead.

### Usage
```bash
# Add the -j flag to any directory query
fasd -d -j components

# Use with execution
fasd -d -j -e 'cd' components

# Or use the zj alias (after sourcing fasd)
zj components
```

### Example
```bash
# You frequently visit /home/user/projects/myapp/src/components
cd /home/user/projects/myapp/src/components

# Later, use deepjump
zj components
# Takes you to /home/user/projects/myapp (the .git root)
```

### Supported VCS
- Git (.git directory)
- Mercurial (.hg directory)

## Updated Documentation

- Added performance section to README with benchmark results
- Documented deepjump feature with examples
- Added benchmarking section with usage instructions
- Updated help text to include new flags and commands
- Added performance tips including database cleanup

## Compatibility

All changes are backward compatible. Existing functionality remains unchanged:
- Original query algorithm behavior preserved
- All existing flags and options work as before
- Database format unchanged
- Aliases unchanged (except for new `zj` alias)

## Testing

All features have been tested:
- Database operations (add, delete, clean)
- Query performance with various patterns
- Deepjump functionality with Git repositories
- Benchmark suite with different configurations
- Help text and version information
