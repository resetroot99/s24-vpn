'use client';

import { useState, useEffect } from 'react';

export default function SimpleDashboard() {
  const [vpnConfig, setVpnConfig] = useState('');
  const [routerIP, setRouterIP] = useState('192.168.8.1');
  const [wifiSSID, setWifiSSID] = useState('Strat24-Secure');
  const [wifiPassword, setWifiPassword] = useState('');
  const [routerPassword, setRouterPassword] = useState('');

  const generateProvisionScript = () => {
    const script = `#!/bin/sh
# Strat24 GL.iNet Router Configuration
# Generated: ${new Date().toISOString()}

# Your WireGuard Configuration
cat > /etc/wireguard/wg0.conf << 'EOF'
${vpnConfig || '# Paste your WireGuard config here'}
EOF

# Configure WiFi
uci set wireless.@wifi-iface[0].ssid="${wifiSSID}"
uci set wireless.@wifi-iface[0].key="${wifiPassword}"
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.radio0.disabled='0'
uci commit wireless

# Apply WireGuard
wg-quick down wg0 2>/dev/null || true
wg-quick up wg0

# Configure firewall (kill switch)
uci set firewall.vpn_zone='zone'
uci set firewall.vpn_zone.name='vpn'
uci set firewall.vpn_zone.input='REJECT'
uci set firewall.vpn_zone.output='ACCEPT'
uci set firewall.vpn_zone.forward='REJECT'
uci set firewall.vpn_zone.masq='1'
uci add_list firewall.vpn_zone.network='wg0'
uci commit firewall

/etc/init.d/network restart
/etc/init.d/firewall restart
wifi reload

echo "✅ Router configured successfully!"
echo "Connect to WiFi: ${wifiSSID}"
`;
    
    return script;
  };

  const downloadScript = () => {
    const script = generateProvisionScript();
    const blob = new Blob([script], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'configure-router.sh';
    a.click();
    URL.revokeObjectURL(url);
  };

  const copyCommand = () => {
    const command = `ssh root@${routerIP} 'sh -s' < configure-router.sh`;
    navigator.clipboard.writeText(command);
    alert('Command copied to clipboard!');
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mr-4">
              <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                Strat24 VPN Dashboard
              </h1>
              <p className="text-gray-600 dark:text-gray-300">GL.iNet Opal Router Configuration</p>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {/* Instructions */}
        <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-6 mb-6">
          <h2 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-3">
            🚀 Quick Setup Guide
          </h2>
          <ol className="space-y-2 text-blue-800 dark:text-blue-200">
            <li><strong>1.</strong> Get a WireGuard VPN config from your VPN provider (Mullvad, ProtonVPN, etc.)</li>
            <li><strong>2.</strong> Paste it below and configure your WiFi settings</li>
            <li><strong>3.</strong> Download the configuration script</li>
            <li><strong>4.</strong> Connect to your GL.iNet router and run the script</li>
            <li><strong>5.</strong> Your router becomes a secure VPN access point! 🎉</li>
          </ol>
        </div>

        {/* VPN Configuration */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            📋 Step 1: WireGuard Configuration
          </h2>
          <p className="text-sm text-gray-600 dark:text-gray-300 mb-4">
            Paste your WireGuard configuration file here (from Mullvad, ProtonVPN, or any WireGuard provider)
          </p>
          <textarea
            value={vpnConfig}
            onChange={(e) => setVpnConfig(e.target.value)}
            placeholder={`[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.x.x.x/32
DNS = 10.64.0.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = server.example.com:51820`}
            className="w-full h-64 px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white font-mono text-sm"
          />
        </div>

        {/* Router & WiFi Settings */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            📡 Step 2: Router & WiFi Settings
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Router IP Address
              </label>
              <input
                type="text"
                value={routerIP}
                onChange={(e) => setRouterIP(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Router Password (for SSH)
              </label>
              <input
                type="password"
                value={routerPassword}
                onChange={(e) => setRouterPassword(e.target.value)}
                placeholder="Your router admin password"
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                WiFi SSID (Network Name)
              </label>
              <input
                type="text"
                value={wifiSSID}
                onChange={(e) => setWifiSSID(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                WiFi Password
              </label>
              <input
                type="password"
                value={wifiPassword}
                onChange={(e) => setWifiPassword(e.target.value)}
                placeholder="Minimum 8 characters"
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
              />
            </div>
          </div>
        </div>

        {/* Download & Deploy */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            🎯 Step 3: Download & Deploy
          </h2>
          <div className="space-y-4">
            <button
              onClick={downloadScript}
              disabled={!vpnConfig || !wifiPassword}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              📥 Download Configuration Script
            </button>

            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
              <p className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Then run this command from your computer:
              </p>
              <div className="flex gap-2">
                <code className="flex-1 bg-gray-900 text-green-400 px-4 py-2 rounded font-mono text-sm overflow-x-auto">
                  ssh root@{routerIP} 'sh -s' &lt; configure-router.sh
                </code>
                <button
                  onClick={copyCommand}
                  className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded"
                >
                  Copy
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Status */}
        <div className="mt-6 bg-green-50 dark:bg-green-900/20 rounded-lg p-6">
          <div className="flex items-center">
            <div className="text-3xl mr-4">✅</div>
            <div>
              <h3 className="text-lg font-semibold text-green-900 dark:text-green-100 mb-1">
                Ready to Configure
              </h3>
              <p className="text-green-800 dark:text-green-200 text-sm">
                Your GL.iNet Opal will become a secure VPN access point with kill switch protection
              </p>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
}

