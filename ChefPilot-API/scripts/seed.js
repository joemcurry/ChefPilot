const sqlite3 = require('sqlite3');
const path = require('path');
const bcrypt = require('bcryptjs');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'data', 'chefpilot.sqlite3');
const db = new sqlite3.Database(dbPath);

const users = [
  { id: 'owner-1', username: 'admin', password: 'password123', user_type: 'Application Owner' },
  { id: 'test-1', username: 'testuser', password: 'testpass', user_type: 'Tenant User' },
  { id: 'owner-2', username: 'owner', password: 'ownerpass', user_type: 'Application Owner' },
];

(async () => {
  try {
    for (const u of users) {
      const hash = await bcrypt.hash(u.password, 10);
      // Upsert: ensure password is updated even if a plaintext value exists
      await new Promise((resolve, reject) => {
        const sql = `INSERT INTO users (id, username, password, user_type)
                     VALUES (?, ?, ?, ?)
                     ON CONFLICT(username) DO UPDATE SET
                       password=excluded.password,
                       user_type=excluded.user_type;`;
        db.run(sql, [u.id, u.username, hash, u.user_type], (err) => (err ? reject(err) : resolve()));
      });
      console.log('Seeded user', u.username);
    }

    // Seed a small set of realistic tenants
    const tenants = [
      { id: 't-acme', name: 'Acme Corporation', type: 'Standalone' },
      { id: 't-beta', name: 'Beta Logistics', type: 'Standalone' },
      { id: 't-gamma', name: 'Gamma Retail', type: 'Standalone' },
      { id: 't-delta', name: 'Delta Foods', type: 'Standalone' },
      { id: 't-horizon', name: 'Horizon Eats', type: 'Standalone' },
    ];

    for (const t of tenants) {
      await new Promise((resolve, reject) => {
        const sql = `INSERT INTO tenants (id, name, type) VALUES (?, ?, ?)
                     ON CONFLICT(id) DO UPDATE SET name=excluded.name, type=excluded.type;`;
        db.run(sql, [t.id, t.name, t.type], (err) => (err ? reject(err) : resolve()));
      });
    }

    // Create a parent tenant with a known PIN for tests
    await new Promise((resolve, reject) => {
      const parentId = 'parent-tenant-1';
      const pin = 'PARENT-PIN-1234';
      const sql = `INSERT INTO tenants (id, name, type, pin) VALUES (?, ?, ?, ?)
                   ON CONFLICT(id) DO UPDATE SET name=excluded.name, pin=excluded.pin;`;
      db.run(sql, [parentId, 'Seeded Parent Tenant', 'Parent', pin], (err) => (err ? reject(err) : resolve()));
    });

    // Map test-1 to a realistic tenant (Acme)
    await new Promise((resolve, reject) => {
      const sql = `INSERT OR REPLACE INTO user_tenants (user_id, tenant_id, role) VALUES (?, ?, ?);`;
      db.run(sql, ['test-1', 't-acme', 'member'], (err) => (err ? reject(err) : resolve()));
    });

    // Create realistic users for each seeded tenant: Owner, Manager, 2 staff
    const tenantUsers = [
      // Acme
      { id: 't-acme-owner', username: 'owner_acme', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 't-acme', role: 'owner' },
      { id: 't-acme-manager', username: 'mgr_acme', password: 'ManagerPass1!', user_type: 'Manager', tenant: 't-acme', role: 'manager' },
      { id: 't-acme-staff1', username: 'alice.acme', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-acme', role: 'staff' },
      { id: 't-acme-staff2', username: 'bob.acme', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-acme', role: 'staff' },
      // Beta
      { id: 't-beta-owner', username: 'owner_beta', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 't-beta', role: 'owner' },
      { id: 't-beta-manager', username: 'mgr_beta', password: 'ManagerPass1!', user_type: 'Manager', tenant: 't-beta', role: 'manager' },
      { id: 't-beta-staff1', username: 'carlos.beta', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-beta', role: 'staff' },
      { id: 't-beta-staff2', username: 'dana.beta', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-beta', role: 'staff' },
      // Gamma
      { id: 't-gamma-owner', username: 'owner_gamma', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 't-gamma', role: 'owner' },
      { id: 't-gamma-manager', username: 'mgr_gamma', password: 'ManagerPass1!', user_type: 'Manager', tenant: 't-gamma', role: 'manager' },
      { id: 't-gamma-staff1', username: 'eve.gamma', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-gamma', role: 'staff' },
      { id: 't-gamma-staff2', username: 'frank.gamma', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-gamma', role: 'staff' },
      // Delta
      { id: 't-delta-owner', username: 'owner_delta', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 't-delta', role: 'owner' },
      { id: 't-delta-manager', username: 'mgr_delta', password: 'ManagerPass1!', user_type: 'Manager', tenant: 't-delta', role: 'manager' },
      { id: 't-delta-staff1', username: 'grace.delta', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-delta', role: 'staff' },
      { id: 't-delta-staff2', username: 'henry.delta', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-delta', role: 'staff' },
      // Horizon
      { id: 't-horizon-owner', username: 'owner_horizon', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 't-horizon', role: 'owner' },
      { id: 't-horizon-manager', username: 'mgr_horizon', password: 'ManagerPass1!', user_type: 'Manager', tenant: 't-horizon', role: 'manager' },
      { id: 't-horizon-staff1', username: 'ivy.horizon', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-horizon', role: 'staff' },
      { id: 't-horizon-staff2', username: 'jacob.horizon', password: 'StaffPass1!', user_type: 'Staff', tenant: 't-horizon', role: 'staff' },
      // Parent tenant
      { id: 'parent-owner', username: 'owner_parent', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 'parent-tenant-1', role: 'owner' },
      { id: 'parent-manager', username: 'mgr_parent', password: 'ManagerPass1!', user_type: 'Manager', tenant: 'parent-tenant-1', role: 'manager' },
      { id: 'parent-staff1', username: 'sam.parent', password: 'StaffPass1!', user_type: 'Staff', tenant: 'parent-tenant-1', role: 'staff' },
      { id: 'parent-staff2', username: 'taylor.parent', password: 'StaffPass1!', user_type: 'Staff', tenant: 'parent-tenant-1', role: 'staff' },
      // Child ParentClients
      { id: 'pc-acme-owner', username: 'owner_pc_acme', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 'pc-acme-1', role: 'owner' },
      { id: 'pc-acme-manager', username: 'mgr_pc_acme', password: 'ManagerPass1!', user_type: 'Manager', tenant: 'pc-acme-1', role: 'manager' },
      { id: 'pc-acme-staff1', username: 'linda.pc.acme', password: 'StaffPass1!', user_type: 'Staff', tenant: 'pc-acme-1', role: 'staff' },
      { id: 'pc-beta-owner', username: 'owner_pc_beta', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 'pc-beta-1', role: 'owner' },
      { id: 'pc-beta-manager', username: 'mgr_pc_beta', password: 'ManagerPass1!', user_type: 'Manager', tenant: 'pc-beta-1', role: 'manager' },
      { id: 'pc-beta-staff1', username: 'omar.pc.beta', password: 'StaffPass1!', user_type: 'Staff', tenant: 'pc-beta-1', role: 'staff' },
      { id: 'pc-gamma-owner', username: 'owner_pc_gamma', password: 'OwnerPass1!', user_type: 'Tenant Owner', tenant: 'pc-gamma-1', role: 'owner' },
      { id: 'pc-gamma-manager', username: 'mgr_pc_gamma', password: 'ManagerPass1!', user_type: 'Manager', tenant: 'pc-gamma-1', role: 'manager' },
      { id: 'pc-gamma-staff1', username: 'nora.pc.gamma', password: 'StaffPass1!', user_type: 'Staff', tenant: 'pc-gamma-1', role: 'staff' },
    ];

    for (const u of tenantUsers) {
      const hash = await bcrypt.hash(u.password, 10);
      await new Promise((resolve, reject) => {
        const sql = `INSERT INTO users (id, username, password, user_type) VALUES (?, ?, ?, ?) ON CONFLICT(username) DO UPDATE SET password=excluded.password, user_type=excluded.user_type;`;
        db.run(sql, [u.id, u.username, hash, u.user_type], (err) => (err ? reject(err) : resolve()));
      });
      // map to tenant
      await new Promise((resolve, reject) => {
        const sql = `INSERT OR REPLACE INTO user_tenants (user_id, tenant_id, role) VALUES (?, ?, ?);`;
        db.run(sql, [u.id, u.tenant, u.role], (err) => (err ? reject(err) : resolve()));
      });
      console.log('Seeded user', u.username, '->', u.tenant);
    }
  } catch (err) {
    console.error('Seeding failed:', err);
    process.exit(1);
  } finally {
    db.close();
  }
})();
