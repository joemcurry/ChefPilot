const request = require('supertest');
const app = require('../server');
const db = require('../db');

afterAll(() => {
  db.close();
});

describe('Tenants API', () => {
  let token = null;
  beforeAll(async () => {
    const r = await request(app).post('/api/auth/login').send({ username: 'admin', password: 'password123' });
    token = r.body.token;
  });

  test('POST /api/tenants creates a tenant (auth required)', async () => {
    const res = await request(app)
      .post('/api/tenants')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Test Tenant', type: 'Standalone' });

    expect(res.statusCode).toBe(201);
    expect(res.body.name).toBe('Test Tenant');
    expect(res.body).toHaveProperty('id');
  });

  test('GET /api/tenants returns list (public)', async () => {
    const res = await request(app).get('/api/tenants');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  test('POST /api/tenants/associate associates tenant with parent via PIN', async () => {
    // Create parent tenant with a PIN via API
    const parent = await request(app)
      .post('/api/tenants')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'API Parent Tenant', type: 'Parent', pin: 'PARENT-PIN-1234' });
    expect(parent.statusCode).toBe(201);
    const parentId = parent.body.id;

    // Create a new tenant as admin (no parent yet)
    const create = await request(app)
      .post('/api/tenants')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Child Tenant', type: 'Standalone' });
    expect(create.statusCode).toBe(201);
    const childId = create.body.id;

    // Associate child with parent using PIN
    const assoc = await request(app)
      .post('/api/tenants/associate')
      .set('Authorization', `Bearer ${token}`)
      .send({ tenant_id: childId, parent_pin: 'PARENT-PIN-1234' });

    expect(assoc.statusCode).toBe(200);
    expect(assoc.body.parent_id).toBe(parentId);
  });
});
