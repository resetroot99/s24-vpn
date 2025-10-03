'use client';

import { useState, useEffect } from 'react';

interface Server {
  id: number;
  name: string;
  ip: string;
  country_code: string;
  city: string;
  capacity: number;
}

interface Account {
  id: number;
  username: string;
  status: string;
}

export default function VPNDashboard() {
  const [servers, setServers] = useState<Server[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [selectedServer, setSelectedServer] = useState<number | null>(null);
  const [selectedAccount, setSelectedAccount] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState('');

  // New account creation
  const [newUsername, setNewUsername] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError('');

      // Load servers
      const serversRes = await fetch('/api/vpn/resellers-servers');
      const serversData = await serversRes.json();
      
      if (serversData.success) {
        setServers(serversData.servers);
        if (serversData.servers.length > 0) {
          setSelectedServer(serversData.servers[0].id);
        }
      }

      // Load accounts
      const accountsRes = await fetch('/api/vpn/resellers-accounts');
      const accountsData = await accountsRes.json();
      
      if (accountsData.success) {
        setAccounts(accountsData.accounts);
        if (accountsData.accounts.length > 0) {
          setSelectedAccount(accountsData.accounts[0].id);
        }
      }
    } catch (err) {
      setError('Failed to load data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const createAccount = async () => {
    if (!newUsername || !newPassword) {
      alert('Username and password are required');
      return;
    }

    // Validate username format
    if (!/^[a-zA-Z0-9_-]+$/.test(newUsername)) {
      alert('Username must be alphanumeric (letters, numbers, dashes, underscores only). No @ symbols or special characters.');
      return;
    }

    if (newUsername.length < 3 || newUsername.length > 50) {
      alert('Username must be 3-50 characters');
      return;
    }

    if (newPassword.length < 3 || newPassword.length > 50) {
      alert('Password must be 3-50 characters');
      return;
    }

    try {
      setCreating(true);
      setError('');

      const res = await fetch('/api/vpn/resellers-create-account', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: newUsername, password: newPassword }),
      });

      const data = await res.json();

      if (data.success) {
        alert(`✅ Account created successfully!\n\nUsername: ${data.account.username}\nStatus: ${data.account.status}`);
        setNewUsername('');
        setNewPassword('');
        loadData(); // Reload accounts
      } else {
        alert(`❌ Failed to create account\n\n${data.error || 'Unknown error'}`);
      }
    } catch (err) {
      alert('❌ Failed to create account - network error');
      console.error(err);
    } finally {
      setCreating(false);
    }
  };

  const generateConfig = async (platform: string) => {
    if (!selectedServer || !selectedAccount) {
      alert('Please select a server and account');
      return;
    }

    try {
      setGenerating(true);
      setError('');

      const url = `/api/vpn/resellers-config?account_id=${selectedAccount}&server_id=${selectedServer}&platform=${platform}`;
      window.location.href = url;

      setTimeout(() => setGenerating(false), 2000);
    } catch (err) {
      alert('Failed to generate config');
      console.error(err);
      setGenerating(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-300">Loading VPN data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
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
                <p className="text-gray-600 dark:text-gray-300">Powered by VPN Resellers</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-sm text-gray-500">{accounts.length} Accounts</p>
              <p className="text-sm text-gray-500">{servers.length} Servers</p>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {error && (
          <div className="bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg p-4 mb-6">
            {error}
          </div>
        )}

        {/* Create New Account */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            ➕ Create New VPN Account
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <input
              type="text"
              value={newUsername}
              onChange={(e) => setNewUsername(e.target.value)}
              placeholder="Username (letters, numbers, - or _)"
              className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
            />
            <input
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Password (min 3 chars)"
              className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
            />
            <button
              onClick={createAccount}
              disabled={creating || !newUsername || !newPassword}
              className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-colors disabled:opacity-50"
            >
              {creating ? 'Creating...' : 'Create Account'}
            </button>
          </div>
        </div>

        {/* Account Selection */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            👤 Select VPN Account
          </h2>
          <select
            value={selectedAccount || ''}
            onChange={(e) => setSelectedAccount(Number(e.target.value))}
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
          >
            {accounts.length === 0 ? (
              <option>No accounts available - create one above</option>
            ) : (
              accounts.map((account) => (
                <option key={account.id} value={account.id}>
                  {account.username} (ID: {account.id}) - {account.status}
                </option>
              ))
            )}
          </select>
        </div>

        {/* Server Selection */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            🌍 Select VPN Server
          </h2>
          <select
            value={selectedServer || ''}
            onChange={(e) => setSelectedServer(Number(e.target.value))}
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
          >
            {servers.map((server) => (
              <option key={server.id} value={server.id}>
                {server.city}, {server.country_code} - {server.name} ({server.ip})
              </option>
            ))}
          </select>
        </div>

        {/* Download Configs */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
          {/* WireGuard */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">🔐</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                WireGuard
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                Modern, fast VPN protocol
              </p>
              <button
                onClick={() => generateConfig('wireguard')}
                disabled={generating || !selectedAccount || !selectedServer}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download WireGuard Config
              </button>
            </div>
          </div>

          {/* iOS */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">📱</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                iOS / iPhone
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                Auto-install profile
              </p>
              <button
                onClick={() => generateConfig('ios')}
                disabled={generating || !selectedAccount || !selectedServer}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download iOS Config
              </button>
            </div>
          </div>

          {/* OpenVPN */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">🌐</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                OpenVPN
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                Traditional VPN protocol
              </p>
              <button
                onClick={() => generateConfig('openvpn')}
                disabled={generating || !selectedAccount || !selectedServer}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download OpenVPN Config
              </button>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-3">
            📖 How to Use
          </h3>
          <ol className="space-y-2 text-blue-800 dark:text-blue-200">
            <li><strong>1.</strong> Create a VPN account above (or use existing)</li>
            <li><strong>2.</strong> Select your account and server location</li>
            <li><strong>3.</strong> Download the config for your device</li>
            <li><strong>4.</strong> Import to WireGuard/OpenVPN app</li>
            <li><strong>5.</strong> Connect and enjoy secure internet! 🎉</li>
          </ol>
        </div>

      </main>
    </div>
  );
}

