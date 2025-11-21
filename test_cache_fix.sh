#!/usr/bin/env bash
# Test cache performance and verify the fix

echo "=== CACHE PERFORMANCE TEST ==="
echo ""

# Test current implementation
echo "Test 1: Current cache key generation cost"
test_string="Test string with emoji 📁 and CJK 中文"

echo "1a. Perl width calculation (baseline):"
start=$(date +%s%N)
for i in {1..100}; do
    echo -n "$test_string" | perl -C -ne 'print length($_)' >/dev/null 2>&1
done
end=$(date +%s%N)
perl_time=$(( (end - start) / 100 / 1000 ))
echo "  Average: ${perl_time}µs per call"

echo ""
echo "1b. Current cache key generation (od + tr):"
start=$(date +%s%N)
for i in {1..100}; do
    cache_key=$(printf '%s' "$test_string" | LC_ALL=C od -An -tx1 | tr -d ' \n')
done
end=$(date +%s%N)
cache_key_time=$(( (end - start) / 100 / 1000 ))
echo "  Average: ${cache_key_time}µs per call"

echo ""
echo "1c. Comparison:"
echo "  Perl call:        ${perl_time}µs"
echo "  Cache key gen:    ${cache_key_time}µs"
if [ "$cache_key_time" -gt "$perl_time" ]; then
    overhead=$(( (cache_key_time - perl_time) * 100 / perl_time ))
    echo "  ❌ Cache key is ${overhead}% SLOWER than Perl!"
else
    improvement=$(( (perl_time - cache_key_time) * 100 / perl_time ))
    echo "  ✅ Cache key is ${improvement}% faster than Perl"
fi

echo ""
echo "=== PROPOSED FIX: Simpler Cache Key ==="
echo ""

# Test alternative approaches
echo "2a. Length-based key:"
start=$(date +%s%N)
for i in {1..100}; do
    cache_key="${#test_string}_${test_string}"
done
end=$(date +%s%N)
simple_time=$(( (end - start) / 100 / 1000 ))
echo "  Average: ${simple_time}µs per call"
speedup=$(( cache_key_time * 100 / simple_time ))
echo "  Speedup vs current: ${speedup}×"

echo ""
echo "2b. Direct string key (if supported):"
start=$(date +%s%N)
for i in {1..100}; do
    cache_key="$test_string"
done
end=$(date +%s%N)
direct_time=$(( (end - start) / 100 / 1000 ))
echo "  Average: ${direct_time}µs per call"
speedup=$(( cache_key_time * 100 / direct_time ))
echo "  Speedup vs current: ${speedup}×"

echo ""
echo "2c. Hash-based key (cksum):"
start=$(date +%s%N)
for i in {1..100}; do
    cache_key=$(printf '%s' "$test_string" | cksum | cut -d' ' -f1)
done
end=$(date +%s%N)
hash_time=$(( (end - start) / 100 / 1000 ))
echo "  Average: ${hash_time}µs per call"
if [ "$hash_time" -lt "$cache_key_time" ]; then
    speedup=$(( cache_key_time * 100 / hash_time ))
    echo "  Speedup vs current: ${speedup}×"
else
    echo "  Still slower than Perl!"
fi

echo ""
echo "=== RECOMMENDATION ==="
echo ""

if [ "$simple_time" -lt "$perl_time" ]; then
    saving=$(( perl_time - simple_time ))
    echo "✅ Use length-based key: ${simple_time}µs (saves ${saving}µs vs Perl)"
    echo "   Implementation: cache_key=\"\${#clean}_\${clean}\""
elif [ "$direct_time" -lt "$perl_time" ]; then
    saving=$(( perl_time - direct_time ))
    echo "✅ Use direct string key: ${direct_time}µs (saves ${saving}µs vs Perl)"
    echo "   Implementation: cache_key=\"\$clean\""
else
    echo "❌ No cache key approach is faster than Perl!"
    echo "   Consider: Removing cache on Bash 3.x entirely"
fi

echo ""
echo "Expected impact:"
echo "  Cache miss: ${cache_key_time}µs + ${perl_time}µs → ${simple_time}µs + ${perl_time}µs"
echo "  Cache hit:  ${cache_key_time}µs → ${simple_time}µs"
if [ "$simple_time" -lt 100 ]; then
    echo "  ✅ Cache hits become essentially free (<100µs)"
fi

echo ""
echo "=== FULL CACHE TEST ==="
echo ""

# Test Bash 4+ associative array if available
if [ "${BASH_VERSINFO[0]}" -ge 4 ] 2>/dev/null; then
    echo "Bash 4+ detected - testing associative array cache"

    declare -A TEST_CACHE

    # Test with simple key
    echo "3a. Cache miss + hit with simple key:"
    start=$(date +%s%N)
    cache_key="${#test_string}_${test_string}"
    width=$(echo -n "$test_string" | perl -C -ne 'print length($_)' 2>/dev/null)
    TEST_CACHE[$cache_key]="$width"
    end=$(date +%s%N)
    miss_time=$(( (end - start) / 1000 ))
    echo "  Miss: ${miss_time}µs"

    start=$(date +%s%N)
    width="${TEST_CACHE[$cache_key]}"
    end=$(date +%s%N)
    hit_time=$(( (end - start) / 1000 ))
    echo "  Hit: ${hit_time}µs"

    if [ "$hit_time" -gt 0 ]; then
        speedup=$(( miss_time / hit_time ))
        echo "  Speedup: ${speedup}×"
    fi
else
    echo "Bash 3.x - associative arrays not available"
    echo "Cache is not functional on this system"
fi
