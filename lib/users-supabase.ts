/**
 * User management with Supabase database
 * Replaces in-memory storage from lib/users.ts
 */

import crypto from 'crypto';
import { supabaseAdmin } from './supabase';

export interface User {
  id: string;
  email: string;
  passwordHash: string;
  licenseKey: string;
  vpnAccountId?: string;
  vpnUsername?: string;
  vpnPassword?: string;
  wgPrivateKey?: string;
  wgPublicKey?: string;
  wgIpAddress?: string;
  status: 'active' | 'suspended' | 'expired';
  createdAt: string;
}

/**
 * Hash password
 */
function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

/**
 * Generate license key
 */
export function generateLicenseKey(email: string): string {
  const timestamp = Date.now();
  const random = crypto.randomBytes(4).toString('hex');
  return `S24-${timestamp}-${random}`.toUpperCase();
}

/**
 * Generate secure password
 */
export function generateSecurePassword(): string {
  return crypto.randomBytes(16).toString('base64').replace(/[^a-zA-Z0-9]/g, '');
}

/**
 * Convert DB row to User object
 */
function dbToUser(data: any): User {
  return {
    id: data.id,
    email: data.email,
    passwordHash: data.password_hash,
    licenseKey: data.license_key,
    vpnAccountId: data.vpn_account_id,
    vpnUsername: data.vpn_username,
    vpnPassword: data.vpn_password,
    wgPrivateKey: data.wg_private_key,
    wgPublicKey: data.wg_public_key,
    wgIpAddress: data.wg_ip_address,
    status: data.status,
    createdAt: data.created_at,
  };
}

/**
 * Create a new user
 */
export async function createUser(email: string, password: string): Promise<User> {
  // Check if user already exists
  const { data: existingUser } = await supabaseAdmin
    .from('users')
    .select('id')
    .eq('email', email)
    .single();

  if (existingUser) {
    throw new Error('User already exists');
  }

  const user = {
    email,
    password_hash: hashPassword(password),
    license_key: generateLicenseKey(email),
    status: 'active',
  };

  const { data, error } = await supabaseAdmin
    .from('users')
    .insert(user)
    .select()
    .single();

  if (error) {
    console.error('[Users] Failed to create user:', error);
    throw new Error('Failed to create user');
  }

  console.log('[Users] ✅ User created:', data.email);
  return dbToUser(data);
}

/**
 * Authenticate user
 */
export async function authenticateUser(email: string, password: string): Promise<User | null> {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('email', email)
    .single();

  if (error || !data) {
    return null;
  }

  const passwordHash = hashPassword(password);
  if (data.password_hash !== passwordHash) {
    return null;
  }

  return dbToUser(data);
}

/**
 * Get user by ID
 */
export async function getUserById(id: string): Promise<User | null> {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('id', id)
    .single();

  if (error || !data) {
    return null;
  }

  return dbToUser(data);
}

/**
 * Get user by email
 */
export async function getUserByEmail(email: string): Promise<User | null> {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('email', email)
    .single();

  if (error || !data) {
    return null;
  }

  return dbToUser(data);
}

/**
 * Get user by license key
 */
export async function getUserByLicense(licenseKey: string): Promise<User | null> {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('license_key', licenseKey)
    .single();

  if (error || !data) {
    return null;
  }

  return dbToUser(data);
}

/**
 * Update user VPN credentials
 */
export async function updateUserVpnCredentials(
  userId: string,
  vpnData: {
    vpnAccountId: string;
    vpnUsername: string;
    vpnPassword: string;
    wgPrivateKey: string;
    wgPublicKey: string;
    wgIpAddress: string;
  }
): Promise<void> {
  const { error } = await supabaseAdmin
    .from('users')
    .update({
      vpn_account_id: vpnData.vpnAccountId,
      vpn_username: vpnData.vpnUsername,
      vpn_password: vpnData.vpnPassword,
      wg_private_key: vpnData.wgPrivateKey,
      wg_public_key: vpnData.wgPublicKey,
      wg_ip_address: vpnData.wgIpAddress,
    })
    .eq('id', userId);

  if (error) {
    console.error('[Users] Failed to update VPN credentials:', error);
    throw new Error('Failed to update VPN credentials');
  }

  console.log('[Users] ✅ VPN credentials updated for user:', userId);
}

/**
 * List all users (admin)
 */
export async function listUsers(): Promise<User[]> {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) {
    console.error('[Users] Failed to list users:', error);
    return [];
  }

  return data.map(dbToUser);
}