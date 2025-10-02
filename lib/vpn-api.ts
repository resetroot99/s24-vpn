/**
 * VPN Resellers API Client
 * Handles all interactions with the VPN provider API
 */

const API_BASE = process.env.VPN_RESELLERS_API_BASE || 'https://api.vpnresellers.com/v3_2';
const API_TOKEN = process.env.VPN_RESELLERS_API_TOKEN;

if (!API_TOKEN) {
  console.warn('[VPN API] Warning: VPN_RESELLERS_API_TOKEN not configured');
}

interface VpnServer {
  id: string;
  name: string;
  hostname: string;
  ip: string;
  country_code: string;
  city: string;
  capacity: number;
}

interface VpnAccount {
  id: string;
  username: string;
  status: string;
  wg_ip: string;
  wg_private_key: string;
  wg_public_key: string;
  expired_at: string | null;
  created: string;
  updated: string;
}

interface WireGuardConfig {
  download_url: string;
  file_body: string;
  file_name: string;
}

/**
 * Make API request to VPN Resellers
 */
async function apiRequest(endpoint: string, options: RequestInit = {}) {
  const url = `${API_BASE}${endpoint}`;
  
  const response = await fetch(url, {
    ...options,
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`VPN API Error (${response.status}): ${errorText}`);
  }

  return response.json();
}

/**
 * List all available VPN servers
 */
export async function listServers(): Promise<VpnServer[]> {
  try {
    console.log('[VPN API] Fetching server list...');
    const data = await apiRequest('/servers');
    
    const servers = (data.data || []).map((server: any) => ({
      id: String(server.id),
      name: server.name || server.hostname,
      hostname: server.hostname || server.name,
      ip: server.ip,
      country_code: server.country_code,
      city: server.city,
      capacity: server.capacity || 0,
    }));
    
    console.log(`[VPN API] ✅ Found ${servers.length} servers`);
    return servers;
  } catch (error) {
    console.error('[VPN API] Failed to list servers:', error);
    throw error;
  }
}

/**
 * Create a new VPN account
 */
export async function createAccount(username: string, password: string): Promise<VpnAccount> {
  try {
    console.log('[VPN API] Creating account:', username);
    
    const data = await apiRequest('/accounts', {
      method: 'POST',
      body: JSON.stringify({
        username,
        password,
      }),
    });

    const account = data.data;
    console.log('[VPN API] ✅ Account created:', account.id);
    
    return {
      id: String(account.id),
      username: account.username,
      status: account.status,
      wg_ip: account.wg_ip,
      wg_private_key: account.wg_private_key,
      wg_public_key: account.wg_public_key,
      expired_at: account.expired_at,
      created: account.created,
      updated: account.updated,
    };
  } catch (error) {
    console.error('[VPN API] Failed to create account:', error);
    throw error;
  }
}

/**
 * Get WireGuard configuration for an account
 */
export async function getWireGuardConfig(
  accountId: string,
  serverId: string
): Promise<WireGuardConfig> {
  try {
    console.log('[VPN API] Fetching WireGuard config:', { accountId, serverId });
    
    const data = await apiRequest(
      `/accounts/${accountId}/wireguard-configuration?server_id=${serverId}`
    );

    console.log('[VPN API] ✅ Config generated');
    
    return {
      download_url: data.data.download_url,
      file_body: data.data.file_body,
      file_name: data.data.file_name,
    };
  } catch (error) {
    console.error('[VPN API] Failed to get WireGuard config:', error);
    throw error;
  }
}

/**
 * Get OpenVPN configuration for a server
 */
export async function getOpenVPNConfig(serverId: string): Promise<WireGuardConfig> {
  try {
    console.log('[VPN API] Fetching OpenVPN config:', serverId);
    
    const data = await apiRequest(`/configuration?server_id=${serverId}`);

    console.log('[VPN API] ✅ OpenVPN config generated');
    
    return {
      download_url: data.data.download_url,
      file_body: data.data.file_body,
      file_name: data.data.file_name,
    };
  } catch (error) {
    console.error('[VPN API] Failed to get OpenVPN config:', error);
    throw error;
  }
}

/**
 * Check if a username is available
 */
export async function checkUsername(username: string): Promise<boolean> {
  try {
    const data = await apiRequest(`/accounts/check_username?username=${username}`);
    return data.data?.message === 'The username is not taken.';
  } catch (error) {
    console.error('[VPN API] Failed to check username:', error);
    return false;
  }
}

/**
 * Disable/suspend an account
 */
export async function disableAccount(accountId: string): Promise<void> {
  try {
    console.log('[VPN API] Disabling account:', accountId);
    await apiRequest(`/accounts/${accountId}/disable`, { method: 'PUT' });
    console.log('[VPN API] ✅ Account disabled');
  } catch (error) {
    console.error('[VPN API] Failed to disable account:', error);
    throw error;
  }
}

/**
 * Enable/reactivate an account
 */
export async function enableAccount(accountId: string): Promise<void> {
  try {
    console.log('[VPN API] Enabling account:', accountId);
    await apiRequest(`/accounts/${accountId}/enable`, { method: 'PUT' });
    console.log('[VPN API] ✅ Account enabled');
  } catch (error) {
    console.error('[VPN API] Failed to enable account:', error);
    throw error;
  }
}
