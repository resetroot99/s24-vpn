'use client';

import { useState, useEffect } from 'react';

interface Server {
  id: string;
  name: string;
  city: string;
  country: string;
}

export default function Dashboard() {
  const [servers, setServers] = useState<Server[]>([]);
  const [selectedServer, setSelectedServer] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [downloading, setDownloading] = useState(false);

  useEffect(() => {
    fetchServers();
  }, []);

  const fetchServers = async () => {
    try {
      const response = await fetch('/api/vpn/servers');
      const data = await response.json();
      
      if (data.success) {
        setServers(data.servers);
        if (data.servers.length > 0) {
          setSelectedServer(data.servers[0].id);
        }
      }
    } catch (error) {
      console.error('Failed to fetch servers:', error);
    } finally {
      setLoading(false);
    }
  };

  const downloadConfig = async (platform: string, protocol: string) => {
    setDownloading(true);
    
    try {
      // Get license key from cookie or localStorage
      const licenseKey = 'demo-license'; // TODO: Get from auth
      
      const url = `/api/vpn/config?license=${licenseKey}&server=${selectedServer}&protocol=${protocol}&platform=${platform}`;
      
      // Trigger download
      window.location.href = url;
      
      setTimeout(() => setDownloading(false), 2000);
    } catch (error) {
      console.error('Download failed:', error);
      setDownloading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-300">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center mr-3">
                <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
                S24 VPN Dashboard
              </h1>
            </div>
            <button
              onClick={() => window.location.href = '/'}
              className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
            >
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Server Selection */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Select VPN Server
          </h2>
          <select
            value={selectedServer}
            onChange={(e) => setSelectedServer(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-700 dark:text-white"
          >
            {servers.map((server) => (
              <option key={server.id} value={server.id}>
                {server.city}, {server.country} - {server.name}
              </option>
            ))}
          </select>
        </div>

        {/* Download Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* iOS */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">📱</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                iOS / iPhone
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                Auto-install profile for iOS devices
              </p>
              <button
                onClick={() => downloadConfig('ios', 'wireguard')}
                disabled={downloading}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download for iOS
              </button>
              <p className="text-xs text-gray-500 dark:text-gray-400 mt-3">
                Tap to install • WireGuard
              </p>
            </div>
          </div>

          {/* macOS */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">💻</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                macOS / Mac
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                WireGuard config for Mac computers
              </p>
              <button
                onClick={() => downloadConfig('desktop', 'wireguard')}
                disabled={downloading}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download for Mac
              </button>
              <p className="text-xs text-gray-500 dark:text-gray-400 mt-3">
                Import to WireGuard app
              </p>
            </div>
          </div>

          {/* Windows */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="text-center">
              <div className="text-5xl mb-4">🖥️</div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                Windows PC
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm mb-6">
                WireGuard config for Windows
              </p>
              <button
                onClick={() => downloadConfig('desktop', 'wireguard')}
                disabled={downloading}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                Download for Windows
              </button>
              <p className="text-xs text-gray-500 dark:text-gray-400 mt-3">
                Import to WireGuard app
              </p>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-6 mt-6">
          <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-3">
            📖 Quick Setup Guide
          </h3>
          <ol className="space-y-2 text-blue-800 dark:text-blue-200">
            <li><strong>1.</strong> Download the config file for your device above</li>
            <li><strong>2.</strong> Install WireGuard app (iOS App Store / Mac App Store / wireguard.com for Windows)</li>
            <li><strong>3.</strong> Import the downloaded config file</li>
            <li><strong>4.</strong> Tap/Click "Activate" to connect</li>
            <li><strong>5.</strong> Enjoy secure, private internet! 🎉</li>
          </ol>
        </div>

        {/* Status */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mt-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                Account Status
              </h3>
              <p className="text-gray-600 dark:text-gray-300 text-sm">
                Your VPN account is active and ready to use
              </p>
            </div>
            <div className="flex items-center">
              <div className="w-3 h-3 bg-green-500 rounded-full mr-2 animate-pulse"></div>
              <span className="text-green-600 dark:text-green-400 font-medium">Active</span>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
