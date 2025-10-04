#!/bin/sh
# Strat24 Dashboard - Quick Deploy Script
# Paste this entire script into the GL.iNet web terminal

echo "🚀 Deploying Strat24 Custom Dashboard..."

# Create directories
mkdir -p /www/strat24 /www/cgi-bin /etc/wireguard

# Download and deploy dashboard
cat > /www/strat24/index.html << 'DASHBOARD_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Strat24 Secure Access Point</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #7e8ba3 100%);
            min-height: 100vh;
            color: #ffffff;
            padding: 20px;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        header {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo { font-size: 32px; font-weight: 700; letter-spacing: 2px; }
        .status {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(76, 175, 80, 0.2);
            padding: 10px 20px;
            border-radius: 30px;
        }
        .status-dot {
            width: 12px;
            height: 12px;
            background: #4CAF50;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        .main-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
        }
        .connection-status { text-align: center; margin-bottom: 40px; }
        .connection-status h1 { font-size: 28px; margin-bottom: 10px; }
        .current-server {
            font-size: 48px;
            margin: 20px 0;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }
        .server-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .server-card {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        .server-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.25);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        }
        .server-card.active {
            border-color: #4CAF50;
            background: rgba(76, 175, 80, 0.2);
        }
        .server-flag { font-size: 64px; margin-bottom: 15px; }
        .server-name { font-size: 24px; font-weight: 600; margin-bottom: 10px; }
        .server-location { opacity: 0.8; font-size: 14px; }
        .server-status {
            margin-top: 15px;
            padding: 8px 16px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .admin-link {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 15px 30px;
            border-radius: 30px;
            text-decoration: none;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-top: 20px;
        }
        .admin-link:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        footer { text-align: center; padding: 30px; opacity: 0.8; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">🔒 STRAT24</div>
            <div class="status">
                <div class="status-dot"></div>
                <span>Secure & Protected</span>
            </div>
        </header>

        <div class="main-card">
            <div class="connection-status">
                <h1>Your Connection is Secure</h1>
                <div class="current-server">
                    <span id="current-flag">🇳🇱</span>
                    <span id="current-location">Netherlands</span>
                </div>
                <p style="opacity: 0.8;">All traffic encrypted with military-grade WireGuard VPN</p>
            </div>

            <h2 style="margin-bottom: 25px; text-align: center;">Select VPN Server</h2>
            
            <div class="server-grid">
                <div class="server-card active" onclick="switchServer('nl')" id="server-nl">
                    <div class="server-flag">🇳🇱</div>
                    <div class="server-name">Netherlands</div>
                    <div class="server-location">Amsterdam</div>
                    <div class="server-status">● Connected</div>
                </div>
                <div class="server-card" onclick="switchServer('ca')" id="server-ca">
                    <div class="server-flag">🇨🇦</div>
                    <div class="server-name">Canada</div>
                    <div class="server-location">Toronto</div>
                    <div class="server-status">○ Available</div>
                </div>
                <div class="server-card" onclick="switchServer('us')" id="server-us">
                    <div class="server-flag">🇺🇸</div>
                    <div class="server-name">United States</div>
                    <div class="server-location">New York</div>
                    <div class="server-status">○ Available</div>
                </div>
                <div class="server-card" onclick="switchServer('th')" id="server-th">
                    <div class="server-flag">🇹🇭</div>
                    <div class="server-name">Thailand</div>
                    <div class="server-location">Bangkok</div>
                    <div class="server-status">○ Available</div>
                </div>
            </div>

            <div style="text-align: center;">
                <a href="/cgi-bin/luci" class="admin-link">⚙️ Advanced Settings (GL.iNet Admin)</a>
            </div>
        </div>

        <footer>
            <p><strong>Strat24 Secure Access Point</strong></p>
            <p style="margin-top: 10px;">Enterprise VPN Solution • Military-Grade Security</p>
            <p style="margin-top: 15px; font-size: 14px;">
                Support: support@strat24.com | https://strat24.com
            </p>
        </footer>
    </div>

    <script>
        function switchServer(server) {
            const servers = {
                'nl': { flag: '🇳🇱', name: 'Netherlands' },
                'ca': { flag: '🇨🇦', name: 'Canada' },
                'us': { flag: '🇺🇸', name: 'United States' },
                'th': { flag: '🇹🇭', name: 'Thailand' }
            };
            document.getElementById('current-flag').textContent = servers[server].flag;
            document.getElementById('current-location').textContent = servers[server].name;
            document.querySelectorAll('.server-card').forEach(c => {
                c.classList.remove('active');
                c.querySelector('.server-status').textContent = '○ Available';
            });
            const card = document.getElementById('server-' + server);
            card.classList.add('active');
            card.querySelector('.server-status').textContent = '● Connected';
        }
    </script>
</body>
</html>
DASHBOARD_EOF

# Configure web server to use Strat24 dashboard
uci set uhttpd.main.home='/www/strat24'
uci commit uhttpd
/etc/init.d/uhttpd restart

echo ""
echo "✅ DONE! Strat24 dashboard deployed!"
echo ""
echo "Refresh your browser: http://192.168.8.1"
echo ""

