# Deployment Guide for Production Migration to cocodr.xyz

## Project Overview

**Stack and Architecture:**
- **Frontend:** Vue.js 3 with Vite build system, TypeScript
- **Backend:** Node.js with Hono framework, Bun runtime
- **Database:** PostgreSQL with Drizzle ORM
- **Real-time Sync:** Zero (replicache) for data synchronization
- **WebSockets:** Custom WebSocket service for real-time features
- **Deployment:** Docker containerized, Fly.io hosting
- **External Services:** Red Tiger game integration, R2 storage, Gemini AI

**Architecture:**
- Monolithic application with separate API and frontend builds
- WebSocket connections for user sessions and game interactions
- CORS-enabled cross-origin requests between app.cocodr.xyz and api.cocodr.xyz
- Environment-aware configuration via Vite env variables

## Pre-deployment Checklist

### Infrastructure Setup
- [ ] DNS records configured for *.cocodr.xyz domains
  - app.cocodr.xyz → Frontend application
  - api.cocodr.xyz → Backend API
  - apidev.cocodr.xyz → Development API (if needed)
  - slots.cocodr.xyz → Slot server (if applicable)
- [ ] SSL certificates provisioned for all subdomains
- [ ] PostgreSQL database instance ready with production credentials
- [ ] R2 storage bucket configured with production access keys
- [ ] Fly.io application created and configured

### Environment Configuration
- [ ] `.env` file created from `.env.example` with production values
- [ ] Database migrations run on production database
- [ ] External API keys configured (Gemini, R2, etc.)
- [ ] WebSocket endpoints verified for new domain

### Security & Compliance
- [ ] CORS origins updated to production domains
- [ ] Cookie domains configured for .cocodr.xyz
- [ ] HTTPS enforced on all endpoints
- [ ] Secrets rotated from development values

## Domain Migration Steps

### Completed Changes
All hardcoded references to `*.cashflowcasino.com` have been replaced with `*.cocodr.xyz`:

1. **Frontend Configuration:**
   - `vite.config.ts`: allowedHosts updated to `app.cocodr.xyz`
   - `src/request/client.ts`: Default API base URL updated
   - `src/request/index.ts`: API prefix and fallback URLs updated
   - WebSocket services updated in `websocket.service.ts`, `ws.user.ts`, `ws.notifications.ts`

2. **Backend Configuration:**
   - `api/app.ts`: CORS allowed origins updated
   - `api/modules/auth/auth.controller.ts`: Cookie domain logic and issuer updated

3. **Environment Files:**
   - `.env`: VITE_WS_URL updated
   - `.env.example`: Created with production-ready placeholders

### Manual Verification Required
- [ ] Update any external service configurations (payment processors, game providers)
- [ ] Verify Red Tiger integration endpoints in `public/redtiger/launcher.html`
- [ ] Update OAuth callback URLs if applicable
- [ ] Confirm all API consumers use environment variables for endpoints

## Slot Server Verification

### Environment Awareness
The application supports environment-aware configuration:
- API base URL configurable via `VITE_API_BASE_URL`
- WebSocket URL configurable via `VITE_WS_URL`
- Database connections via environment variables

### Slot-Specific Configuration
For slot server deployments:
1. Set `VITE_API_BASE_URL` to the slot's API endpoint
2. Ensure relative paths are used where possible
3. Verify WebSocket connections use dynamic host resolution

### Testing Steps
1. Deploy to staging slot with test domain
2. Verify API connectivity and WebSocket connections
3. Test cross-origin requests with CORS
4. Confirm cookie setting and authentication flow
5. Validate game integrations and external APIs

## Production Deployment Steps

1. **Build Optimization:**
   ```bash
   npm run build
   ```

2. **Environment Setup:**
   - Copy `.env.example` to `.env`
   - Update all production values
   - Set `NODE_ENV=production`

3. **Database Migration:**
   ```bash
   npm run db:migrate
   ```

4. **Docker Build:**
   ```bash
   docker build -t casino-app .
   ```

5. **Deploy to Fly.io:**
   ```bash
   fly deploy
   ```

6. **Health Check:**
   - Verify frontend loads at app.cocodr.xyz
   - Test API endpoints at api.cocodr.xyz
   - Confirm WebSocket connections establish
   - Validate authentication and game functionality

## Rollback Plan

1. Keep previous deployment active during transition
2. Use DNS TTL settings to control cutover timing
3. Monitor error rates and user feedback post-migration
4. Have database backup ready for restoration if needed

## Monitoring & Maintenance

- Set up application monitoring (response times, error rates)
- Configure log aggregation for API and frontend
- Monitor database performance and connection pools
- Track WebSocket connection health
- Set up alerts for SSL certificate expiration

## Security Considerations

- Ensure all secrets are properly managed (no hardcoded values)
- Verify HTTPS is enforced on all production endpoints
- Confirm CORS policies restrict to authorized origins only
- Audit cookie settings for secure, httpOnly flags
- Review authentication token expiration and refresh logic