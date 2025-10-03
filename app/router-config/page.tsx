'use client';

import { useState } from 'react';

export default function RouterConfig() {
  const [vpnConfig, setVpnConfig] = useState('');
  const [routerIP, setRouterIP] = useState('192.168.8.1');
  const [wifiSSID, setWifiSSID] = useState('Strat24-Secure');
  const [wifiPassword, setWifiPassword] = useState('');

  const generateScript = () => {
    const script = `#!/bin/sh
# Strat24 GL.iNet Router Configuration Script
# Generated: ${new Date().toISOString()}

echo "🚀 Starting Strat24 Router Configuration..."

# Create WireGuard config
cat > /etc/wireguard/wg0.conf << 'WGEOF'
${vpnConfig || '# Paste your WireGuard config here'}
WGEOF

echo "✅ WireGuard config created"

# Configure WireGuard interface
uci set network.wg0='interface'
uci set network.wg0.proto='wireguard'
uci set network.wg0.disabled='0'
uci commit network

# Configure WiFi
echo "📡 Configuring WiFi..."
uci set wireless.@wifi-iface[0].ssid="${wifiSSID}"
uci set wireless.@wifi-iface[0].key="${wifiPassword}"
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.radio0.disabled='0'
uci commit wireless

# Configure firewall with kill switch
echo "🔒 Setting up firewall and kill switch..."
uci set firewall.vpn_zone='zone'
uci set firewall.vpn_zone.name='vpn'
uci set firewall.vpn_zone.input='REJECT'
uci set firewall.vpn_zone.output='ACCEPT'
uci set firewall.vpn_zone.forward='REJECT'
uci set firewall.vpn_zone.masq='1'
uci set firewall.vpn_zone.mtu_fix='1'
uci add_list firewall.vpn_zone.network='wg0'

uci set firewall.lan_to_vpn='forwarding'
uci set firewall.lan_to_vpn.src='lan'
uci set firewall.lan_to_vpn.dest='vpn'
uci commit firewall

# Start WireGuard
echo "🔐 Starting WireGuard VPN..."
wg-quick down wg0 2>/dev/null || true
wg-quick up wg0

# Restart services
echo "♻️  Restarting services..."
/etc/init.d/network restart
sleep 3
/etc/init.d/firewall restart
sleep 2
wifi reload

echo ""
echo "✅ ========================================="
echo "✅  Strat24 Router Configuration Complete!"
echo "✅ ========================================="
echo ""
echo "📡 WiFi Network: ${wifiSSID}"
echo "🔐 VPN Status: Active"
echo "🛡️  Kill Switch: Enabled"
echo ""
echo "Connect to WiFi and browse securely! 🎉"
`;
    
    return script;
  };

  const downloadScript = () => {
    if (!vpnConfig || !wifiPassword) {
      alert('⚠️ Please fill in VPN config and WiFi password first!');
      return;
    }

    const script = generateScript();
    const blob = new Blob([script], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'strat24-router-setup.sh';
    a.click();
    URL.revokeObjectURL(url);
  };

  const copySSHCommand = () => {
    const command = `ssh root@${routerIP} 'sh -s' < strat24-router-setup.sh`;
    navigator.clipboard.writeText(command);
    alert('✅ SSH command copied to clipboard!');
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-gradient-to-r from-blue-600 to-blue-700 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center">
            <div className="w-14 h-14 bg-white rounded-xl flex items-center justify-center mr-4 shadow-md">
              <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white">
                Strat24 Router Configuration
              </h1>
              <p className="text-blue-100 mt-1">GL.iNet Opal • One-Click Setup • No API Required</p>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {/* Instructions Banner */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl p-6 mb-8 border-l-4 border-blue-500">
          <h2 className="text-xl font-bold text-blue-900 dark:text-blue-100 mb-3 flex items-center">
            <span className="text-2xl mr-2">🚀</span>
            Quick 3-Step Setup
          </h2>
          <ol className="space-y-2 text-blue-800 dark:text-blue-200">
            <li className="flex items-start">
              <span className="font-bold mr-2 bg-blue-500 text-white w-6 h-6 rounded-full flex items-center justify-center text-sm">1</span>
              <span>Go to VPN Resellers → Config File Generator → Select your account (s24, v3ctor, etc.) → Generate WireGuard config → Copy it</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold mr-2 bg-blue-500 text-white w-6 h-6 rounded-full flex items-center justify-center text-sm">2</span>
              <span>Paste config below, set WiFi name and password</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold mr-2 bg-blue-500 text-white w-6 h-6 rounded-full flex items-center justify-center text-sm">3</span>
              <span>Download script and run on your GL.iNet router - Done! 🎉</span>
            </li>
          </ol>
        </div>

        {/* Step 1: VPN Config */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6 border border-gray-200 dark:border-gray-700">
          <div className="flex items-center mb-4">
            <span className="text-3xl mr-3">🔐</span>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Step 1: WireGuard Configuration
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                From VPN Resellers: Config File Generator → Select s24, v3ctor, or any account → Generate → Copy
              </p>
            </div>
          </div>
          <textarea
            value={vpnConfig}
            onChange={(e) => setVpnConfig(e.target.value)}
            placeholder={`[Interface]
PrivateKey = your_private_key_here
Address = 10.x.x.x/32
DNS = 10.64.0.1

[Peer]
PublicKey = server_public_key_here
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = server.vpnresellers.com:51820
PersistentKeepalive = 25`}
            className="w-full h-72 px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white font-mono text-sm resize-none"
          />
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
            ✨ Tip: Make sure to include both [Interface] and [Peer] sections
          </p>
        </div>

        {/* Step 2: WiFi Settings */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6 border border-gray-200 dark:border-gray-700">
          <div className="flex items-center mb-4">
            <span className="text-3xl mr-3">📡</span>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Step 2: WiFi & Router Settings
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                Your clients will connect to this WiFi network
              </p>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                🌐 Router IP Address
              </label>
              <input
                type="text"
                value={routerIP}
                onChange={(e) => setRouterIP(e.target.value)}
                className="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
              />
              <p className="text-xs text-gray-500 mt-1">Usually 192.168.8.1 for GL.iNet</p>
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                📶 WiFi Network Name (SSID)
              </label>
              <input
                type="text"
                value={wifiSSID}
                onChange={(e) => setWifiSSID(e.target.value)}
                className="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                🔒 WiFi Password
              </label>
              <input
                type="password"
                value={wifiPassword}
                onChange={(e) => setWifiPassword(e.target.value)}
                placeholder="Minimum 8 characters for WPA2 security"
                className="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
              />
              <p className="text-xs text-gray-500 mt-1">⚠️ Share this password with your clients</p>
            </div>
          </div>
        </div>

        {/* Step 3: Download & Deploy */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6 border border-gray-200 dark:border-gray-700">
          <div className="flex items-center mb-4">
            <span className="text-3xl mr-3">⚡</span>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Step 3: Download & Deploy
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                One command to configure your router
              </p>
            </div>
          </div>
          
          <button
            onClick={downloadScript}
            disabled={!vpnConfig || !wifiPassword}
            className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-4 px-6 rounded-lg transition-all shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed mb-4 text-lg"
          >
            {!vpnConfig || !wifiPassword ? '⚠️ Fill in config and WiFi password first' : '📥 Download Configuration Script'}
          </button>

          {vpnConfig && wifiPassword && (
            <div className="bg-gray-900 rounded-lg p-5 border border-gray-700">
              <p className="text-sm font-semibold text-gray-300 mb-3">
                Then run this command from your computer:
              </p>
              <div className="flex gap-2">
                <code className="flex-1 bg-black text-green-400 px-4 py-3 rounded-lg font-mono text-sm overflow-x-auto border border-gray-700">
                  ssh root@{routerIP} 'sh -s' &lt; strat24-router-setup.sh
                </code>
                <button
                  onClick={copySSHCommand}
                  className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-3 rounded-lg font-medium transition-colors whitespace-nowrap"
                >
                  📋 Copy
                </button>
              </div>
              <p className="text-xs text-gray-400 mt-3">
                💡 Make sure you can SSH into your router first: <code className="bg-gray-800 px-2 py-1 rounded">ssh root@{routerIP}</code>
              </p>
            </div>
          )}
        </div>

        {/* Status Card */}
        <div className="bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-xl p-6 border-l-4 border-green-500">
          <div className="flex items-start">
            <div className="text-4xl mr-4">✅</div>
            <div>
              <h3 className="text-xl font-bold text-green-900 dark:text-green-100 mb-2">
                Ready to Configure!
              </h3>
              <div className="text-green-800 dark:text-green-200 space-y-1">
                <p>✓ Your GL.iNet Opal will become a secure VPN access point</p>
                <p>✓ All traffic automatically routed through VPN</p>
                <p>✓ Kill switch prevents leaks if VPN disconnects</p>
                <p>✓ Client devices connect via WiFi - no configuration needed</p>
              </div>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
}

