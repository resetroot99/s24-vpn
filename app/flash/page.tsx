'use client';

import { useState } from 'react';

export default function FlashRouter() {
  const [routerIP, setRouterIP] = useState('192.168.8.1');

  const downloadScript = () => {
    fetch('/hardware/provisioning/multi-server-setup.sh')
      .then(response => response.text())
      .then(script => {
        const blob = new Blob([script], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'strat24-flash.sh';
        a.click();
        URL.revokeObjectURL(url);
      });
  };

  const copySSHCommand = () => {
    const command = `ssh root@${routerIP} 'sh -s' < strat24-flash.sh`;
    navigator.clipboard.writeText(command);
    alert('✅ Command copied!');
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      
      {/* Header */}
      <header className="bg-gradient-to-r from-blue-600 to-blue-700 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center">
            <div className="w-14 h-14 bg-white rounded-xl flex items-center justify-center mr-4 shadow-md">
              <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white">
                Flash GL.iNet Opal
              </h1>
              <p className="text-blue-100 mt-1">Out-of-Box Strat24 VPN Configuration • 4 Global Servers</p>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {/* What You Get */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl p-6 mb-8 border-l-4 border-blue-500">
          <h2 className="text-2xl font-bold text-blue-900 dark:text-blue-100 mb-4 flex items-center">
            <span className="text-3xl mr-2">🎁</span>
            What This Creates
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-blue-800 dark:text-blue-200">
            <div className="flex items-start">
              <span className="text-2xl mr-2">📡</span>
              <div>
                <strong>Portal WiFi:</strong> strat24secureWIFI<br/>
                <span className="text-sm">Users connect here first</span>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-2">🌍</span>
              <div>
                <strong>4 VPN Networks:</strong><br/>
                <span className="text-sm">Strat24-NL, -CA, -US, -TH</span>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-2">🎨</span>
              <div>
                <strong>Beautiful Portal:</strong><br/>
                <span className="text-sm">Select server location</span>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-2">🔒</span>
              <div>
                <strong>Kill Switches:</strong><br/>
                <span className="text-sm">All VPN networks protected</span>
              </div>
            </div>
          </div>
        </div>

        {/* User Experience Flow */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center">
            <span className="text-3xl mr-2">👥</span>
            User Experience Flow
          </h2>
          <div className="space-y-4">
            {[
              { step: 1, icon: '📱', title: 'Connect to Portal WiFi', desc: 'Users see "strat24secureWIFI" and connect' },
              { step: 2, icon: '🌐', title: 'Auto-Launch Portal', desc: 'Beautiful Strat24 portal opens automatically' },
              { step: 3, icon: '🗺️', title: 'Choose Server', desc: 'Pick Netherlands, Canada, USA, or Thailand' },
              { step: 4, icon: '🔐', title: 'Connect to VPN WiFi', desc: 'Join selected network (e.g., Strat24-US)' },
              { step: 5, icon: '✅', title: 'Done!', desc: 'Secure, encrypted internet via VPN' },
            ].map((item) => (
              <div key={item.step} className="flex items-start p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <div className="flex-shrink-0 w-10 h-10 bg-blue-500 text-white rounded-full flex items-center justify-center font-bold mr-4">
                  {item.step}
                </div>
                <div className="flex-1">
                  <div className="text-2xl mb-1">{item.icon}</div>
                  <h3 className="font-bold text-gray-900 dark:text-white mb-1">{item.title}</h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Flash Instructions */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center">
            <span className="text-3xl mr-2">⚡</span>
            Flash Your Router
          </h2>
          
          <div className="space-y-4 mb-6">
            <div>
              <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                Router IP Address
              </label>
              <input
                type="text"
                value={routerIP}
                onChange={(e) => setRouterIP(e.target.value)}
                className="w-full px-4 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
              />
              <p className="text-xs text-gray-500 mt-1">Default is 192.168.8.1 for GL.iNet</p>
            </div>
          </div>

          <button
            onClick={downloadScript}
            className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-4 px-6 rounded-lg transition-all shadow-lg hover:shadow-xl mb-4 text-lg"
          >
            📥 Download Flash Script
          </button>

          <div className="bg-gray-900 rounded-lg p-5 border border-gray-700">
            <p className="text-sm font-semibold text-gray-300 mb-3">
              Then run this command:
            </p>
            <div className="flex gap-2">
              <code className="flex-1 bg-black text-green-400 px-4 py-3 rounded-lg font-mono text-sm overflow-x-auto border border-gray-700">
                ssh root@{routerIP} 'sh -s' &lt; strat24-flash.sh
              </code>
              <button
                onClick={copySSHCommand}
                className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-3 rounded-lg font-medium transition-colors whitespace-nowrap"
              >
                📋 Copy
              </button>
            </div>
            <p className="text-xs text-gray-400 mt-3">
              💡 Takes ~2 minutes. Router will restart automatically.
            </p>
          </div>
        </div>

        {/* After Flashing */}
        <div className="bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-xl p-6 border-l-4 border-green-500">
          <h3 className="text-xl font-bold text-green-900 dark:text-green-100 mb-3 flex items-center">
            <span className="text-3xl mr-2">🎉</span>
            After Flashing
          </h3>
          <div className="text-green-800 dark:text-green-200 space-y-2">
            <p><strong>WiFi Networks Available:</strong></p>
            <ul className="list-disc list-inside ml-4 space-y-1">
              <li><strong>strat24secureWIFI</strong> (password: welcome2024) - Portal access</li>
              <li><strong>Strat24-NL</strong> (password: Strat24Secure) - Netherlands VPN</li>
              <li><strong>Strat24-CA</strong> (password: Strat24Secure) - Canada VPN</li>
              <li><strong>Strat24-US</strong> (password: Strat24Secure) - USA VPN</li>
              <li><strong>Strat24-TH</strong> (password: Strat24Secure) - Thailand VPN</li>
            </ul>
            <p className="mt-4"><strong>✅ Your router is ready to deploy!</strong></p>
          </div>
        </div>

      </main>
    </div>
  );
}

