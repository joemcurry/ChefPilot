const request = require('supertest');
const app = require('../server');
const db = require('../db');

afterAll(() => {
  db.close();
});

describe('Tasks API', () => {
  let tenantId = null;
  let token = null;

  beforeAll(async () => {
    const login = await request(app).post('/api/auth/login').send({ username: 'admin', password: 'password123' });
    token = login.body.token;
    const r = await request(app).post('/api/tenants').set('Authorization', `Bearer ${token}`).send({ name: 'Task Tenant' });
    tenantId = r.body.id;
  });

  test('POST /api/tasks creates a task (auth required)', async () => {
    const res = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({ tenant_id: tenantId, title: 'Clean Fridge' });

    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Clean Fridge');
    expect(res.body).toHaveProperty('id');
  });

  test('GET /api/tasks returns tasks (public)', async () => {
    const res = await request(app).get('/api/tasks');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
