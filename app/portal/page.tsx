'use client';

import { useState } from 'react';

export default function Strat24Portal() {
  const [selectedServer, setSelectedServer] = useState<string | null>(null);

  const servers = [
    { id: 'nl', name: '🇳🇱 Netherlands', speed: 'Fast', location: 'Amsterdam', network: 'Strat24-NL' },
    { id: 'ca', name: '🇨🇦 Canada', speed: 'Fast', location: 'Toronto', network: 'Strat24-CA' },
    { id: 'us', name: '🇺🇸 USA', speed: 'Fast', location: 'New York', network: 'Strat24-US' },
    { id: 'th', name: '🇹🇭 Thailand', speed: 'Fast', location: 'Bangkok', network: 'Strat24-TH' },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 flex items-center justify-center p-4">
      <div className="max-w-4xl w-full">
        
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-24 h-24 bg-white rounded-3xl shadow-2xl mb-6">
            <svg className="w-14 h-14 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <h1 className="text-5xl font-bold text-white mb-4">
            Welcome to Strat24
          </h1>
          <p className="text-xl text-blue-200">
            Secure VPN Access Point • Choose Your Server Location
          </p>
        </div>

        {/* Server Selection Grid */}
        <div className="bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20 mb-6">
          <h2 className="text-2xl font-bold text-white mb-6 flex items-center">
            <span className="text-3xl mr-3">🌍</span>
            Select Your VPN Server
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
            {servers.map((server) => (
              <button
                key={server.id}
                onClick={() => setSelectedServer(server.id)}
                className={`p-6 rounded-2xl transition-all transform hover:scale-105 ${
                  selectedServer === server.id
                    ? 'bg-gradient-to-r from-blue-500 to-blue-600 shadow-xl ring-4 ring-white/50'
                    : 'bg-white/20 hover:bg-white/30'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="text-left">
                    <div className="text-2xl font-bold text-white mb-1">
                      {server.name}
                    </div>
                    <div className="text-blue-100 text-sm mb-2">
                      📍 {server.location}
                    </div>
                    <div className="inline-flex items-center px-3 py-1 bg-green-500/30 rounded-full text-green-100 text-xs font-semibold">
                      ⚡ {server.speed}
                    </div>
                  </div>
                  {selectedServer === server.id && (
                    <div className="text-white">
                      <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                      </svg>
                    </div>
                  )}
                </div>
              </button>
            ))}
          </div>

          {selectedServer && (
            <div className="bg-gradient-to-r from-green-500/20 to-emerald-500/20 border-2 border-green-400/50 rounded-2xl p-6 animate-fadeIn">
              <div className="flex items-start">
                <div className="text-4xl mr-4">✅</div>
                <div className="flex-1">
                  <h3 className="text-xl font-bold text-white mb-3">
                    Connect to VPN WiFi Network
                  </h3>
                  <div className="bg-black/30 rounded-xl p-4 mb-4">
                    <div className="text-sm text-blue-200 mb-2">📶 Network Name:</div>
                    <div className="text-2xl font-bold text-white mb-3">
                      {servers.find(s => s.id === selectedServer)?.network}
                    </div>
                    <div className="text-sm text-blue-200 mb-2">🔒 Password:</div>
                    <div className="text-xl font-mono text-white">
                      Strat24Secure
                    </div>
                  </div>
                  <div className="text-blue-100 text-sm space-y-1">
                    <p>1. Open WiFi settings on your device</p>
                    <p>2. Disconnect from current network</p>
                    <p>3. Connect to <strong>{servers.find(s => s.id === selectedServer)?.network}</strong></p>
                    <p>4. Enter password: <strong>Strat24Secure</strong></p>
                    <p>5. All your traffic is now secure! 🎉</p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Features */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
            <div className="text-3xl mb-3">🔒</div>
            <h3 className="text-lg font-bold text-white mb-2">Encrypted</h3>
            <p className="text-blue-200 text-sm">Military-grade WireGuard encryption</p>
          </div>
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
            <div className="text-3xl mb-3">⚡</div>
            <h3 className="text-lg font-bold text-white mb-2">Fast</h3>
            <p className="text-blue-200 text-sm">High-speed servers worldwide</p>
          </div>
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
            <div className="text-3xl mb-3">🛡️</div>
            <h3 className="text-lg font-bold text-white mb-2">Kill Switch</h3>
            <p className="text-blue-200 text-sm">No leaks if VPN disconnects</p>
          </div>
        </div>

      </div>
    </div>
  );
}

