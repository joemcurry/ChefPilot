const request = require('supertest');
const app = require('../server');
const db = require('../db');

afterAll(() => {
  db.close();
});

describe('Tenant scope middleware', () => {
  let memberToken = null;
  let ownerToken = null;
  beforeAll(async () => {
    const r1 = await request(app).post('/api/auth/login').send({ username: 'testuser', password: 'testpass' });
    memberToken = r1.body.token;
    const r2 = await request(app).post('/api/auth/login').send({ username: 'admin', password: 'password123' });
    ownerToken = r2.body.token;
  });

  test('Non-member cannot access tenant resources', async () => {
    // testuser is mapped to test-tenant-1 in seed; create a different tenant and try accessing it
    const t = await request(app)
      .post('/api/tenants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ name: 'Other Tenant', type: 'Standalone' });
    const otherTenantId = t.body.id;

    const res = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ tenant_id: otherTenantId, title: 'Should Fail' });

    expect(res.statusCode).toBe(403);
    expect(res.body.error).toBe('not_a_member');
  });

  test('Mapped user can create task for their tenant', async () => {
    const res = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ tenant_id: 'test-tenant-1', title: 'Member Task' });

    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Member Task');
  });

  test('Application Owner bypasses membership check', async () => {
    // create another tenant and ensure owner can post to it
    const t = await request(app)
      .post('/api/tenants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ name: 'Owner Tenant', type: 'Standalone' });
    const ownerTenantId = t.body.id;

    const res = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ tenant_id: ownerTenantId, title: 'Owner Task' });

    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Owner Task');
  });
});
