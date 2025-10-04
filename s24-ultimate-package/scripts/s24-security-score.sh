#!/bin/sh
# S24 Security Score Calculator
# Gamified security assessment

calculate_score() {
    local score=0
    local max_score=100
    local grade="F"
    
    # VPN enabled (+20 points)
    if wg show | grep -q interface; then
        score=$((score + 20))
        echo "✓ VPN Enabled: +20 points"
    else
        echo "✗ VPN Disabled: +0 points"
    fi
    
    # Kill Switch enabled (+20 points)
    if [ -f "/tmp/s24_killswitch_enabled" ] && [ "$(cat /tmp/s24_killswitch_enabled)" = "1" ]; then
        score=$((score + 20))
        echo "✓ Kill Switch Active: +20 points"
    else
        echo "✗ Kill Switch Disabled: +0 points"
    fi
    
    # DNS Protection (+15 points)
    if iptables -L OUTPUT | grep -q "dpt:53.*DROP"; then
        score=$((score + 15))
        echo "✓ DNS Protection Enabled: +15 points"
    else
        echo "✗ DNS Protection Disabled: +0 points"
    fi
    
    # Ad Blocker (+15 points)
    if /etc/init.d/adblock status | grep -q "running"; then
        score=$((score + 15))
        echo "✓ Ad Blocker Active: +15 points"
    else
        echo "✗ Ad Blocker Disabled: +0 points"
    fi
    
    # Firewall configured (+15 points)
    if iptables -L | grep -q "Chain.*ACCEPT"; then
        score=$((score + 15))
        echo "✓ Firewall Configured: +15 points"
    else
        echo "✗ Firewall Not Configured: +0 points"
    fi
    
    # Stealth Mode (+15 points)
    if uci get wireless.@wifi-iface[0].hidden 2>/dev/null | grep -q "1"; then
        score=$((score + 15))
        echo "✓ Stealth Mode Active: +15 points"
    else
        echo "✗ Stealth Mode Disabled: +10 points"
        score=$((score + 10))
    fi
    
    # Calculate grade
    if [ $score -ge 90 ]; then
        grade="A"
    elif [ $score -ge 80 ]; then
        grade="B"
    elif [ $score -ge 70 ]; then
        grade="C"
    elif [ $score -ge 60 ]; then
        grade="D"
    else
        grade="F"
    fi
    
    echo ""
    echo "================================"
    echo "SECURITY SCORE: $score/$max_score"
    echo "GRADE: $grade"
    echo "================================"
    
    # Save score
    echo "$score" > /tmp/s24_security_score
    echo "$grade" > /tmp/s24_security_grade
}

calculate_score

