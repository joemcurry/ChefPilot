const request = require('supertest');
const app = require('../server');
const jwt = require('jsonwebtoken');

describe('Auth & health endpoints', () => {
  test('GET /api/health returns ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  test('POST /api/auth/login accepts valid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'password123' });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.username).toBe('admin');
  });

  test('Issued JWT is decodable and valid', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'password123' });
    const token = res.body.token;
    const secret = process.env.JWT_SECRET || 'dev-secret';
    const decoded = jwt.verify(token, secret);
    expect(decoded).toHaveProperty('username', 'admin');
    expect(decoded).toHaveProperty('id');
  });

  test('Refresh token returns new access token and logout revokes it', async () => {
    const res = await request(app).post('/api/auth/login').send({ username: 'admin', password: 'password123' });
    const refresh = res.body.refresh_token;
    expect(refresh).toBeDefined();

    const r2 = await request(app).post('/api/auth/refresh').send({ refresh_token: refresh });
    expect(r2.statusCode).toBe(200);
    expect(r2.body).toHaveProperty('token');

    // logout should revoke
    const r3 = await request(app).post('/api/auth/logout').send({ refresh_token: refresh });
    expect(r3.statusCode).toBe(200);

    // subsequent refresh should fail
    const r4 = await request(app).post('/api/auth/refresh').send({ refresh_token: refresh });
    expect(r4.statusCode).toBe(401);
  });

  test('POST /api/auth/login rejects invalid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'bad' });

    expect(res.statusCode).toBe(401);
  });
});
