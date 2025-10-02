/**
 * Simple in-memory user store (MVP)
 * Replace with proper database (Supabase/PostgreSQL) for production
 */

import crypto from 'crypto';

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

// In-memory storage (replace with database)
const users: Map<string, User> = new Map();
const usersByEmail: Map<string, User> = new Map();
const usersByLicense: Map<string, User> = new Map();

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
 * Create a new user
 */
export async function createUser(email: string, password: string): Promise<User> {
  // Check if user already exists
  if (usersByEmail.has(email)) {
    throw new Error('User already exists');
  }

  const user: User = {
    id: crypto.randomUUID(),
    email,
    passwordHash: hashPassword(password),
    licenseKey: generateLicenseKey(email),
    status: 'active',
    createdAt: new Date().toISOString(),
  };

  users.set(user.id, user);
  usersByEmail.set(email, user);
  usersByLicense.set(user.licenseKey, user);

  console.log('[Users] ✅ User created:', user.email);
  return user;
}

/**
 * Authenticate user
 */
export async function authenticateUser(email: string, password: string): Promise<User | null> {
  const user = usersByEmail.get(email);
  
  if (!user) {
    return null;
  }

  const passwordHash = hashPassword(password);
  if (user.passwordHash !== passwordHash) {
    return null;
  }

  return user;
}

/**
 * Get user by ID
 */
export async function getUserById(id: string): Promise<User | null> {
  return users.get(id) || null;
}

/**
 * Get user by email
 */
export async function getUserByEmail(email: string): Promise<User | null> {
  return usersByEmail.get(email) || null;
}

/**
 * Get user by license key
 */
export async function getUserByLicense(licenseKey: string): Promise<User | null> {
  return usersByLicense.get(licenseKey) || null;
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
  const user = users.get(userId);
  if (!user) {
    throw new Error('User not found');
  }

  Object.assign(user, vpnData);
  console.log('[Users] ✅ VPN credentials updated for:', user.email);
}

/**
 * List all users (admin)
 */
export async function listUsers(): Promise<User[]> {
  return Array.from(users.values());
}
