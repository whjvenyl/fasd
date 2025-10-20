#!/usr/bin/env bash
#
# Benchmark script for fasd
# Compares performance of fasd query operations
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BENCHMARK_DATA_SIZE=${BENCHMARK_DATA_SIZE:-1000}
BENCHMARK_QUERIES=${BENCHMARK_QUERIES:-100}
FASD_BIN="${FASD_BIN:-./fasd}"

echo "============================================"
echo "Fasd Performance Benchmark Suite"
echo "============================================"
echo ""

# Check if fasd exists
if [ ! -x "$FASD_BIN" ]; then
    echo -e "${RED}Error: fasd binary not found at $FASD_BIN${NC}"
    exit 1
fi

# Create a temporary directory for benchmark data
BENCHMARK_DIR=$(mktemp -d)
export _FASD_DATA="$BENCHMARK_DIR/fasd-benchmark-db"
export _FASD_SINK="/dev/null"

cleanup() {
    rm -rf "$BENCHMARK_DIR"
}
trap cleanup EXIT

echo "Setup:"
echo "  Data size: $BENCHMARK_DATA_SIZE entries"
echo "  Queries: $BENCHMARK_QUERIES queries per test"
echo "  Database: $_FASD_DATA"
echo ""

# Generate test data
echo -e "${BLUE}Generating test data...${NC}"
mkdir -p "$BENCHMARK_DIR/test_dirs"
for i in $(seq 1 $BENCHMARK_DATA_SIZE); do
    # Create varied directory names for realistic testing
    case $((i % 5)) in
        0) dir="$BENCHMARK_DIR/test_dirs/project${i}/src";;
        1) dir="$BENCHMARK_DIR/test_dirs/work/code/module${i}";;
        2) dir="$BENCHMARK_DIR/test_dirs/dev/app${i}/lib";;
        3) dir="$BENCHMARK_DIR/test_dirs/home/user/documents/file${i}";;
        4) dir="$BENCHMARK_DIR/test_dirs/tmp/build${i}/output";;
    esac
    mkdir -p "$dir"
    # Add to database with varied frequency (rank)
    rank=$((1 + i % 20))
    timestamp=$(date +%s)
    echo "$dir|$rank|$timestamp" >> "$_FASD_DATA"
done
echo -e "${GREEN}✓ Generated $BENCHMARK_DATA_SIZE test entries${NC}"
echo ""

# Benchmark function
benchmark() {
    local name=$1
    local command=$2
    
    echo -e "${YELLOW}Running: $name${NC}"
    
    # Warm up
    for i in $(seq 1 5); do
        eval "$command" > /dev/null 2>&1 || true
    done
    
    # Actual benchmark
    local start=$(date +%s%N)
    for i in $(seq 1 $BENCHMARK_QUERIES); do
        eval "$command" > /dev/null 2>&1 || true
    done
    local end=$(date +%s%N)
    
    local elapsed=$(( (end - start) / 1000000 )) # Convert to milliseconds
    local avg=$(( elapsed / BENCHMARK_QUERIES ))
    
    echo -e "  Total: ${elapsed}ms"
    echo -e "  Average: ${avg}ms per query"
    echo -e "  Throughput: $(( BENCHMARK_QUERIES * 1000 / elapsed )) queries/sec"
    echo ""
}

# Run benchmarks
echo "============================================"
echo "Query Performance Tests"
echo "============================================"
echo ""

benchmark "List all directories" \
    "$FASD_BIN -d -l"

benchmark "List all files" \
    "$FASD_BIN -f -l"

benchmark "Query with simple pattern (project)" \
    "$FASD_BIN -d project"

benchmark "Query with multi-word pattern (work code)" \
    "$FASD_BIN -d work code"

benchmark "Fuzzy query" \
    "$FASD_BIN -d prj"

benchmark "Recent access query" \
    "$FASD_BIN -d -t project"

benchmark "Rank-based query" \
    "$FASD_BIN -d -r project"

echo "============================================"
echo "Database Operations"
echo "============================================"
echo ""

# Test add operation
benchmark "Add new entry" \
    "$FASD_BIN --add $BENCHMARK_DIR/test_dirs/newdir"

# Test delete operation
benchmark "Delete entry" \
    "$FASD_BIN --delete $BENCHMARK_DIR/test_dirs/project1"

echo "============================================"
echo "Memory Usage"
echo "============================================"
echo ""

# Check database file size
db_size=$(wc -c < "$_FASD_DATA")
echo "Database size: $((db_size / 1024))KB"
echo "Average entry size: $((db_size / BENCHMARK_DATA_SIZE)) bytes"
echo ""

echo "============================================"
echo "Comparison with alternatives (if available)"
echo "============================================"
echo ""

# Check for pazi
if command -v pazi &> /dev/null; then
    echo -e "${GREEN}pazi found - comparing...${NC}"
    # Note: pazi uses different database format, comparison is informational only
    export PAZI_DATA_DIR="$BENCHMARK_DIR/pazi"
    mkdir -p "$PAZI_DATA_DIR"
    
    # Import some data to pazi
    for i in $(seq 1 100); do
        dir="$BENCHMARK_DIR/test_dirs/project${i}/src"
        pazi visit "$dir" 2>/dev/null || true
    done
    
    benchmark "pazi query" \
        "pazi view project"
    echo ""
else
    echo -e "${YELLOW}pazi not found - skipping comparison${NC}"
    echo "To install pazi: cargo install pazi"
    echo ""
fi

# Check for jump
if command -v jump &> /dev/null; then
    echo -e "${GREEN}jump found - comparing...${NC}"
    export JUMP_CHDIR="$BENCHMARK_DIR/jump"
    mkdir -p "$JUMP_CHDIR"
    
    # Import some data to jump
    for i in $(seq 1 100); do
        dir="$BENCHMARK_DIR/test_dirs/project${i}/src"
        jump cd "$dir" 2>/dev/null || true
    done
    
    benchmark "jump query" \
        "jump cd project"
    echo ""
else
    echo -e "${YELLOW}jump not found - skipping comparison${NC}"
    echo "To install jump: go install github.com/gsamokovarov/jump@latest"
    echo ""
fi

echo "============================================"
echo "Benchmark Complete!"
echo "============================================"
echo ""
echo "Summary:"
echo "  fasd is optimized for frecency-based navigation"
echo "  For best performance:"
echo "    - Keep database size under 2000 entries (configured via _FASD_MAX)"
echo "    - Use specific query patterns"
echo "    - Enable fuzzy matching cautiously (_FASD_FUZZY)"
echo ""
