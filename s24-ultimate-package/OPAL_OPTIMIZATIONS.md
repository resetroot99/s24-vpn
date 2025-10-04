# S24 VPN Router - Opal Optimizations

## Hardware Constraints
- **CPU**: MediaTek MT7621A @ 880 MHz (dual-core MIPS)
- **RAM**: 128 MB
- **Flash**: 16 MB
- **Network**: 5x Gigabit Ethernet ports

## Optimization Strategy

### 1. MEMORY OPTIMIZATION
- Reduce polling from 5s to 10s (50% less overhead)
- Use lightweight shell scripts (no Python/Node.js)
- Cache API responses for 30s
- Minimize concurrent processes
- Use busybox utilities only

### 2. STORAGE OPTIMIZATION
- Minified dashboard: ~35KB (was 107KB)
- Logo embedded as optimized base64
- No external dependencies
- Total package: <100KB

### 3. CPU OPTIMIZATION
- Avoid complex regex operations
- Use simple string matching
- Minimize iptables lookups
- Batch operations where possible
- Use efficient data structures

### 4. NETWORK OPTIMIZATION
- Reduce API polling frequency
- Cache status for 30s
- Compress responses
- Minimize DNS lookups

### 5. OPENWRT-SPECIFIC
- Use UCI for all configs (native to OpenWRT)
- Leverage existing GL.iNet services
- Use native WireGuard kernel module
- Avoid external process spawning

## Performance Targets
- Dashboard load: <500ms
- API response: <100ms
- Memory usage: <10MB
- CPU usage: <5% idle, <20% active
- Storage usage: <500KB total

## Implementation
All scripts optimized for busybox ash shell with minimal external calls.

