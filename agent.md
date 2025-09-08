# Agent Documentation

## Project Goal

ChefPilot is a multi-platform restaurant operations assistant (the Flutter app is named "ChefPilot") backed by an API service. The purpose of the project is to provide restaurant owners and staff with tools to run day-to-day operations — employees, temperature logs, health-department preparation, document management, contacts, and task management — but it is explicitly not a point-of-sale (POS) system. The system consists of a Flutter frontend and a backend API (Node.js/Express in this repo) that together enable multi-tenant, role-driven workflows and secure data isolation. The Flutter frontend must support and run on iOS, macOS, Android, and Web (mobile, desktop, and web targets are required).

Key concepts:

- AppOwner: the administrator/operator of the overall hosted service (global configuration, default feature and role definitions, billing defaults).
- Tenant: a restaurant/location using ChefPilot. A Tenant can be standalone or a child of a Parent Tenant.
- Parent Tenant: an organization that can manage child tenants and their feature configuration on behalf of children.

Multi-tenant behavior and feature management:

- Standalone Tenants manage their own tenant-level configuration and choose which AppOwner-provided features they enable for their users.
- Parent Tenants manage features and role-to-feature mappings for their child tenants when the parent relationship exists.
- "Manage Features" means configuring feature availability and mapping which roles (per-tenant) may view or use a given feature — i.e., it is a permissions-to-feature mapping.
- Parent/Child association is established via a unique, shareable PIN for parent tenants (see "Tenant Setup" and `/api/tenants/associate`).

Core features (examples already present in this document): Employees (accounts & role management), Tasks (create, document, assign, pickup, approval flow), Temperature Logs, Health Dept Prep Checklists, Document Management (secure, tenant-scoped), Contacts, Rewards, and Reporting.

The backend must enforce tenant isolation, role-based access control (RBAC), and all API contracts required by the Flutter frontend.

## Project Paths & Run Commands

### Directory Structure

```bash
/Users/josephcurry/MyCode/zCode/ChefAssistant/
├── ChefPilot/                    # Flutter App (Main Application)
│   ├── lib/
│   ├── ios/
│   ├── android/
│   ├── macos/
│   ├── web/
│   └── pubspec.yaml
└── ChefPilot-API/               # Node.js/Express Backend
  ├── server.js
  ├── package.json
  ├── routes/
  ├── models/
  ├── sql/                     # Database scripts directory
  └── init.sql
```

### API Server Commands

**Working Directory:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API`

```bash
# Start the API server
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && node server.js

# Install dependencies
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && npm install

# Run with nodemon (if installed)
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && nodemon server.js

# Test API endpoints
curl -X POST http://127.0.0.1:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}'
```

### Development Workflow

1. **Start API Server First:**

  ```bash
  cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && node server.js
  ```

1. **Start Flutter App:**

  ```bash
  cd /Users/josephcurry/MyCode/zCode/ChefPilot && flutter run -d macos
  ```

1. **Test User Credentials:**

- Username: `admin`, Password: `password123`
- Username: `testuser`, Password: `testpass`
- Username: `owner`, Password: `ownerpass`

### Key Files & Locations

- **Flutter Main Entry:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot/lib/main.dart`
- **API Server Entry:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API/server.js`
- **Database Scripts:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API/sql/`
- **Flutter Pubspec:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot/pubspec.yaml`
- **API Package.json:** `/Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API/package.json`

### Network Configuration

- **API Base URL:** `http://127.0.0.1:3000` (configured in AuthService)
- **Local Development:** Use `127.0.0.1` instead of `localhost` for better macOS compatibility
- **Port:** 3000 (configured in server.js)

## Task List

Track progress on the ChefPilot project development.

### Documentation

- [ ] Define project overview and features
- [ ] Establish coding guidelines and file organization
- [ ] Add technology stack and development notes
- [ ] Include platform-specific gotchas
- [ ] Define usage scenarios for tenants and staff
- [ ] Research and integrate best practices for Security & Privacy
- [ ] Research and integrate best practices for Performance & Scalability
- [ ] Research and integrate best practices for Testing & Quality
- [ ] Research and integrate best practices for Deployment & DevOps
- [ ] Research and integrate best practices for User Experience (including Clean UI/UX)
- [ ] Research and integrate best practices for Error Handling

### Project Setup

- [ ] Set up Node.js/Express backend with SSL/HTTPS
- [ ] Implement multi-tenancy data isolation
- [ ] Build authentication API for Application Owner (frontend implementation)
- [ ] Create login screen for Application Owner
- [ ] Create dashboard for Application Owner

### Backend Development

- [ ] Build API endpoints for CRUD operations (Tasks, Temperature Logs, etc.)
- [ ] Add authentication (JWT, role-based access)
- [ ] Implement data encryption and security measures
- [ ] Set up background processing for reports and notifications
- [ ] Implement account management APIs (forgot password, username update, demographics update)
- [ ] Implement parent/child tenant hierarchy APIs (association, management, billing)
- [ ] Implement owner-specific APIs: tenant management, user-based billing, feature control, analytics

### Frontend Development

- [ ] Design and implement clean UI following Material Design and Apple HIG
- [ ] Build shared components (e.g., Numberpad Widget)
- [ ] Create dashboards for Application Owner and Tenants
- [ ] Implement responsive layouts for all platforms (iOS, Android, macOS, Web)
- [ ] Add offline support and sync functionality
- [ ] Develop account management screens (forgot password, username update, demographics)
- [ ] Develop parent/child tenant screens (setup wizard, management dashboard)
- [ ] Develop owner-specific screens: tenant management, user-based billing, feature control, analytics dashboard

### Feature Implementation

- [ ] Tasks feature (create, assign, track)
- [ ] Temperature log feature
- [ ] Health department prep checklists
- [ ] Inventory tracking and alerts
- [ ] Staff scheduling and communication
- [ ] Order preparation guidance
- [ ] Customer feedback collection
- [ ] Contacts management
- [ ] Account management (forgot password, username update, demographics update)
- [ ] Role management and authorization system
- [ ] Application Owner features: tenant management, user-based billing, feature control, role management, analytics, parent tenant reporting dashboards, parent tenant reporting dashboards, parent tenant reporting dashboards

### Testing & Quality Assurance

- [ ] Write unit tests (minimum 80% coverage)
- [ ] Implement widget tests for shared components
- [ ] Conduct E2E testing for critical user flows
- [ ] Perform performance testing and profiling with DevTools
- [ ] Ensure code follows Effective Dart guidelines

### Deployment Tasks

- [ ] Set up CI/CD pipeline
- [ ] Configure environment management (dev/staging/prod)
- [ ] Implement monitoring and error tracking
- [ ] Prepare for app store submissions (iOS, Android, macOS)
- [ ] Handle web deployment and CORS

### Final Checks

- [ ] Review multi-tenancy implementation
- [ ] Test platform-specific gotchas
- [ ] Validate accessibility and internationalization
- [ ] Conduct security audit
- [ ] Final user testing and feedback integration

## 🚦 Application Startup Instructions (Strict Requirement)

**Strict Requirement:**
When starting the application on any simulator or device, always ensure the ChefPilot-API server is running.

### Coding Guidelines

These are **strict guidelines** that must be followed without exception to ensure code quality and maintainability.

- **Modularity**: Each dashboard, popup dialog, or major UI component **must** have its own dedicated file. **Strictly avoid** large, monolithic files that exceed reasonable size limits.
- **Step-by-Step Development**: **Mandatory** to focus on incremental progress with clear milestones. **Always** prioritize UI implementation followed by API integrations and wireups. **Do not** start coding features prematurely; **ensure** each step is completed and tested before moving to the next.
- **File Organization**: **Strictly** structure the codebase with logical separation of concerns, such as separate directories for screens, dialogs, widgets, models, and services. **No exceptions** to this organization. **Mandatory** user-type-based structure:
  - **/ApplicationOwner/**: **Must contain** subdirectories for Application Owner-specific code.
    - **/Providers**: **Strictly** for state management providers related to owner functions.
    - **/Screens**: **Must include** subdirectories.
      - **/Dashboards**: **Mandatory** for owner dashboard screens.
      - **/Widgets**: **Strictly** for owner-specific UI components.
  - **/Tenants/**: **Must contain** subdirectories for Tenant-specific code, mirroring ApplicationOwner structure where applicable.
    - **/Providers**: **Strictly** for tenant state management.
    - **/Screens**: **Must include** subdirectories.
      - **/Dashboards**: **Mandatory** for tenant dashboard screens.
      - **/Widgets**: **Strictly** for tenant-specific UI components.
  - **/Shared/**: **Mandatory** directory for shared widgets and components across user types. **No duplication** of code allowed; **strictly enforce** reuse from this directory.
    - **/Components**: **Must categorize** ALL control widgets here. **Strict requirement** - Any widget that functions as a control (e.g., buttons, inputs, selectors) **must be placed** in this directory. **No exceptions**; **zero tolerance** for control widgets outside /Shared/Components/.
      - **Numberpad Widget**: **Mandatory** shared component for numeric input. **Must support** type parameter (integer vs decimal) to conditionally include ".". **Strictly requires** Cancel and OK buttons. **No variations** outside this component; **enforce** reuse across all user types.
- **API CRUD Requirement**: **Must requirement** - When adding or updating any feature or feature-related screen, **ensure** the API has proper CRUD (Create, Read, Update, Delete) operations to support the feature. **No feature implementation** without corresponding API endpoints. **Strictly enforce** this before UI development begins.
- **Development Principle**: The agent **must never** go off and write code based on opinion. It **shall strictly follow** the request and **ask questions** to clarify any gaps. **No assumptions** or speculative implementations allowed.
- **Focused Development**: When developing specific user-type areas (e.g., Application Owner screens), **strictly focus** on that group only. **Do not modify** other areas of the code unless explicitly asked to do so.
- **Date Handling**: **Strict requirement** - All dates must be stored and transmitted in UTC to ensure consistency across timezones. Use ISO 8601 format (e.g., "2023-09-05T14:30:00Z") for all date strings. **Mandatory** conversions: Convert user-input dates to UTC before storage; convert UTC dates to local timezone for display. **No exceptions** to UTC storage. Use established libraries (e.g., `intl` package in Dart for Flutter, `moment.js` or native `Date` with timezone handling in Node.js) for date parsing, formatting, and arithmetic. **Strictly avoid** manual date calculations; **always validate** date inputs to prevent invalid dates. For multi-tenant apps, ensure date displays respect user locale but store in UTC.

## Features

- Tasks feature
- Temperature log
- Health department prep
- Inventory tracking and alerts
- Staff scheduling and communication
- Order preparation guidance
- Customer feedback collection
- Contacts
- Account management (forgot password, username update, demographics update)
- Parent/Child tenant hierarchy (setup, management, billing)
- **Application Owner Features**:
  - Tenant management (add, view details: users, billing based on user count)
  - Billing management (per-user pricing, revenue tracking, parent/child billing options, default and override pricing)
  - Feature management (descriptions, default/required status, availability dates, enable/disable with cascading)
  - Role management (maintain default roles for tenants)
  - Analytics (user-based billing sales, usage metrics)
  - Parent tenant dashboard (child details, cost per location)
  - Parent tenant reporting dashboards (reports by feature for child tenants, e.g., temperature logs, tasks)

## Usage

### For Tenants (Restaurant Owners/Managers)

1. **Setup Process**:
   - **Mandatory Wizard Setup**: Upon first login, tenants **must complete** a setup wizard that **strictly includes**:
     - **Company Type Selection**: Choose between standalone or parent company.
     - **Parent Tenant Association**: If selecting parent company, a unique PIN is **strictly generated and assigned** upon signup. This PIN **must be** shared with child tenants for association. If not a parent, **mandatory** option to enter a Parent Tenant PIN number to associate with a parent company. **No association** without valid PIN verification. **Strict requirement** - Child tenants **cannot proceed** without successful parent association via PIN.
     - **Default Features Assignment**: Certain features **must be** included by default (e.g., Tasks, Temperature Logs). **No exceptions** to default inclusions.
     - **User Limit Configuration**: Tenants **must specify** their expected number of users for billing purposes.
     - **Owner Information/Demographics**: **Strictly required** collection of tenant owner details (e.g., name, contact info, location) and tenant details (e.g., restaurant type). **No setup completion** without this information.
   - **Completion Requirement**: Setup **must be fully completed** before accessing the main application. **Incomplete setup prohibits** full app usage.
   - **Parent/Child Hierarchy**: If associated with a parent, feature management is handled by the parent company. Child tenants cannot manage features independently.

2. **Post-Setup Usage**:
   - **Dashboard Access**: Upon login, view the main dashboard displaying key metrics like tasks, temperature logs, and inventory alerts.
   - **Managing Staff**: Add, edit, or remove staff members and assign roles (e.g., Chef, Server, Manager) with appropriate permissions. Standalone tenants can create custom roles; parent tenants manage roles for child tenants.
   - **Role Management**: Select from default roles (maintained by Application Owner) or create custom roles. Assign roles to employees and control feature access per role. Roles can be activated or deactivated as needed.
   - **Account Management**:
     - **Forgot Password**: Request password reset via email or secure link.
     - **Update Username**: Change username with verification.
     - **Update Demographics**: Modify personal information (name, contact info, restaurant details) with proper validation.
   - **Feature Utilization**:
     - **Tasks**: Create, assign, and track daily or single tasks with optional schedules. Employees can pick up unassigned tasks. **Strict Requirement**: All task completions require approval by Team Leader, Manager, or Owner before rewards are awarded. Some tasks require image upload for verification; images stored on API server with task ID as filename; auto-cleaned after 2 weeks. (Authorization: Strictly configurable by tenant roles)
     - **Temperature Logs**: Record and monitor fridge/freezer temperatures for health compliance. Each Standalone and Child Tenant maintains a daily temperature log. Users can enter current temperature and view history. Indicators show safe and out-of-safe zones. If out of safe zone, alerts are sent to user and owner via notifications, prompting review of Contacts for service calls. (Authorization: Strictly configurable by tenant roles)
     - **Health Department Prep**: Access checklists and reminders for inspections. (Authorization: Strictly configurable by tenant roles)
     - **Inventory Tracking**: Update stock levels and receive alerts for low inventory. (Authorization: Strictly configurable by tenant roles)
     - **Staff Scheduling**: Manage shifts and communication. (Authorization: Strictly configurable by tenant roles)
     - **Order Preparation**: Get guidance on order workflows. (Authorization: Strictly configurable by tenant roles)
     - **Customer Feedback**: Collect and review feedback. (Authorization: Strictly configurable by tenant roles)
     - **Contacts**: Maintain a directory of suppliers, service providers, and emergency contacts for quick access during alerts (e.g., temperature danger zones). (Authorization: Strictly configurable by tenant roles)

     - **Rewards**: Employees earn points for completing tasks, updating temperature logs, and showing up for work. View reward history and redeem points. (Authorization: Strictly configurable by tenant roles)
     - **Documents**: Upload and manage employee documents like ID, licenses, and certifications for compliance and records. Also store and manage tenant-wide documents, with ability to send documents to employees. (Authorization: Strictly configurable by tenant roles)
     - **Account Management**: Handle password resets, username updates, and demographics. (Authorization: Strictly configurable by tenant roles)
     - **Parent/Child Tenant Hierarchy**: Manage child tenants, billing, and features. (Authorization: Strictly configurable by tenant roles)
   - **Notifications**: Receive updates from the application owner regarding new features or changes.

### For Staff

1. **Login**: Use role-specific credentials provided by the tenant.
2. **Daily Tasks**: View assigned tasks, mark as complete, and communicate with other staff.
3. **Access Permissions**: Depending on role, access relevant features like temperature logging or inventory updates.
4. **Reporting**: Submit feedback or reports as needed.

### For Application Owner

1. **Login and Access**: Owners log in to access the system for managing tenants and billing.
2. **Tenant Management**:
   - Add new tenants and configure their user limits.
   - View tenant details: number of users, active features, billing amount based on user count.
   - **Client List View**: Display only standalone and parent companies; child tenants are managed under their parent.
   - Send notifications to tenants regarding updates or changes.
3. **Billing Management**:
   - Set pricing per user (monthly and yearly rates).
   - **Default Pricing**: Establish default costs per user for trial, monthly, and yearly basis.
   - **Override Pricing**: Set individual pricing for parent tenants and standalone tenants; if no override exists, use default pricing.
   - Monitor billing based on the number of users per tenant.
   - **Parent/Child Billing**: For parent tenants, choose if parent or child is responsible for billing. If parent responsible, billing based on total users across all child tenants.
   - View overall revenue from user-based subscriptions.
4. **Feature Management**:
   - Manage feature descriptions and availability dates.
   - Set features as default (included by default) or required (mandatory for all tenants).
   - Enable or disable features globally; disabling cascades to tenants, removing access if they have that feature.
5. **Role Management**:
   - Maintain a list of default roles (e.g., Restaurant Owner, Manager, Chef, Server) for tenants to select from.
   - Roles are database-driven and can be customized by standalone tenants or managed by parent tenants for child tenants.
   - Activate or deactivate roles as required.
6. **Analytics and Monitoring**:
   - View sales analytics from user-based billing (revenue tracking, growth metrics).
   - Monitor overall application usage and performance metrics.
   - Access admin panel for comprehensive oversight.
   - **Parent Tenant Dashboard**: For parent companies, view details about child tenants and cost per location based on user counts.
   - **Parent Tenant Reporting Dashboards**: Access detailed reports by feature for child tenants (e.g., temperature logs, tasks, inventory). Filter by date range, child tenant, and export options.

### General Usage Notes

- All interactions must be performed through the API for security and data integrity.
- Ensure the app is updated to the latest version for new features.
- Contact support for any issues via the app's help section.

## API Specifications

### Overview

All API endpoints follow RESTful conventions and require JWT authentication via the `Authorization: Bearer <token>` header. Multi-tenancy is enforced by including `tenant_id` in the request headers or path parameters where applicable.

### Data Models

#### Tenant

```json
{
  "id": "string (UUID)",
  "name": "string",
  "type": "string (Application Owner | Parent Tenant | Standalone Tenant)",
  "parent_id": "string (UUID, optional for child tenants)",
  "pin": "string (generated for parent tenants, used by child tenants for association)",
  "user_limit": "number",
  "restaurant_type": "string",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Role

```json
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string",
  "tenant_id": "string (UUID)",
  "is_default": "boolean",
  "status": "string (Active | Inactive)",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Feature

```json
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string",
  "is_default": "boolean",
  "is_required": "boolean",
  "enabled": "boolean",
  "availability_date": "string (ISO date, optional)",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### TenantFeature

```json
{
  "tenant_id": "string (UUID)",
  "feature_id": "string (UUID)",
  "enabled": "boolean",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### User

```json
{
  "id": "string (UUID)",
  "username": "string",
  "email": "string",
  "password_hash": "string",
  "tenant_id": "string (UUID)",
  "user_type": "string (Application Owner | Parent Tenant | Standalone Tenant | Staff)",
  "is_active": "boolean",
  "total_points": "number",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Demographics

```json
{
  "user_id": "string (UUID)",
  "first_name": "string",
  "last_name": "string",
  "phone": "string",
  "address": "string",
  "city": "string",
  "state": "string",
  "zip_code": "string",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### UserRole

```json
{
  "user_id": "string (UUID)",
  "role_id": "string (UUID)",
  "assigned_at": "string (ISO date)"
}
```

#### Authorization

```json
{
  "role_id": "string (UUID)",
  "feature_id": "string (UUID)",
  "granted": "boolean",
  "tenant_id": "string (UUID)"
}
```

#### TemperatureLog

```json
{
  "id": "string (UUID)",
  "tenant_id": "string (UUID)",
  "temperature": "number",
  "unit": "string (F|C)",
  "location": "string",
  "safe_min": "number",
  "safe_max": "number",
  "is_safe": "boolean",
  "notes": "string",
  "logged_at": "string (ISO date)",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Notification

```json
{
  "id": "string (UUID)",
  "tenant_id": "string (UUID)",
  "user_id": "string (UUID)",
  "type": "string (alert | info)",
  "message": "string",
  "is_read": "boolean",
  "created_at": "string (ISO date)"
}
```

#### Contact

```json
{
  "id": "string (UUID)",
  "tenant_id": "string (UUID)",
  "name": "string",
  "type": "string (supplier | service | emergency)",
  "phone": "string",
  "email": "string",
  "address": "string",
  "notes": "string",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Task

```json
{
  "id": "string (UUID)",
  "tenant_id": "string (UUID)",
  "title": "string",
  "description": "string",
  "type": "string (daily | single)",
  "schedule": "string (optional, e.g., specific time/day)",
  "assigned_to": "string (UUID, optional)",
  "assigned_by": "string (UUID)",
  "status": "string (pending | in_progress | completed | awaiting_approval)",
  "due_date": "string (ISO date, optional)",
  "requires_approval": "boolean (default: true)",
  "approved_by": "string (UUID, optional)",
  "approved_at": "string (ISO date, optional)",
  "image_required": "boolean",
  "image_url": "string (optional)",
  "created_at": "string (ISO date)",
  "updated_at": "string (ISO date)"
}
```

#### Reward

```json
{
  "id": "string (UUID)",
  "user_id": "string (UUID)",
  "points": "number",
  "reason": "string (task_completed | temp_log_updated | attendance)",
  "earned_at": "string (ISO date)"
}
```

#### Document

```json
{
  "id": "string (UUID)",
  "tenant_id": "string (UUID)",
  "user_id": "string (UUID, optional for tenant documents)",
  "type": "string (employee: id | license | certification | other; tenant: policy | manual | announcement | other)",
  "file_url": "string",
  "uploaded_by": "string (UUID)",
  "uploaded_at": "string (ISO date)",
  "sent_to": "array of string (UUID, optional for sent documents)",
  "sent_at": "string (ISO date, optional)"
}
```

**Strict Instructions for Document Management**:

- **Multi-Tenant Isolation**: All documents must be strictly isolated by tenant_id. No cross-tenant access allowed.
- **File Storage**: Store files on server with secure naming (e.g., {tenant_id}_{id}_{type}.jpg/png/pdf). Auto-cleanup after 30 days for sent documents.
- **Access Control**: Only Owners/Managers can upload/send tenant documents. Staff can only view received documents.
- **File Validation**: Strictly validate file types (jpg, png, pdf), size (<5MB), and scan for malware.
- **Audit Logging**: Log all document uploads, sends, and accesses for compliance.
- **Notifications**: Automatically notify staff when documents are sent to them.
- **Retention**: Retain documents for 2 years minimum for compliance, with secure deletion after.

### Authentication Endpoints

- **POST /api/auth/login**  
  Request: { "username": string, "password": string }  
  Response: { "token": string, "user": User, "tenant_id": string }

- **POST /api/auth/refresh**  
  Request: { "refresh_token": string }  
  Response: { "token": string }

### Tenant Management (Application Owner)

- **GET /api/tenants**  
  Response: Tenant[]

- **POST /api/tenants**  
  Request: Tenant  
  Response: Tenant

- **GET /api/tenants/{id}**  
  Response: Tenant

- **PUT /api/tenants/{id}**  
  Request: Tenant  
  Response: Tenant

- **DELETE /api/tenants/{id}**  
  Response: { "message": "Deleted" }

### Billing Management (Application Owner)

- **GET /api/billing/defaults**  
  Response: BillingDefaults

- **PUT /api/billing/defaults**  
  Request: BillingDefaults  
  Response: BillingDefaults

- **GET /api/billing/overrides/{tenant_id}**  
  Response: BillingOverride

- **PUT /api/billing/overrides/{tenant_id}**  
  Request: BillingOverride  
  Response: BillingOverride

### Tasks (Tenants/Staff)

- **GET /api/tasks**  
  Response: Task[]  
  Query params: status, assigned_to

- **POST /api/tasks**  
  Request: Task  
  Response: Task  
  **Note**: Created by Tenant Owner or Manager; can be daily/single with optional schedule.

- **GET /api/tasks/{id}**  
  Response: Task

- **PUT /api/tasks/{id}**  
  Request: Task  
  Response: Task

- **PUT /api/tasks/{id}/assign**  
  Request: { "assigned_to": string }  
  Response: Task

- **PUT /api/tasks/{id}/pickup**  
  Request: {}  
  Response: Task  
  **Note**: Allows employees to pick up unassigned tasks.

- **PUT /api/tasks/{id}/complete**  
  Request: { "image": file (optional) }  
  Response: Task  
  **Note**: Marks task as completed; if image_required, upload image named {task_id}.jpg/png. **Strict Enforcement**: Status becomes awaiting_approval; rewards only awarded after approval.

- **PUT /api/tasks/{id}/approve**  
  Request: {}  
  Response: Task  
  **Note**: **Strict Requirement**: Approves task completion by Team Leader/Manager/Owner only; awards points if applicable. Unauthorized approval attempts are rejected.

- **DELETE /api/tasks/{id}**  
  Response: { "message": "Deleted" }

### Temperature Logs (Tenants/Staff)

- **GET /api/temperature-logs**  
  Response: TemperatureLog[]  
  Query params: start_date, end_date (for history)

- **POST /api/temperature-logs**  
  Request: TemperatureLog  
  Response: TemperatureLog  
  **Note**: Automatically checks if temperature is within safe_min/safe_max; if not, triggers notification to user and owner.

- **GET /api/temperature-logs/{id}**  
  Response: TemperatureLog

- **PUT /api/temperature-logs/{id}**  
  Request: TemperatureLog  
  Response: TemperatureLog

- **DELETE /api/temperature-logs/{id}**  
  Response: { "message": "Deleted" }

### Notifications (Tenants/Staff)

- **GET /api/notifications**  
  Response: Notification[]  
  Query params: is_read (false for unread)

- **PUT /api/notifications/{id}/read**  
  Request: {}  
  Response: Notification

### Contacts (Tenants/Staff)

- **GET /api/contacts**  
  Response: Contact[]

- **POST /api/contacts**  
  Request: Contact  
  Response: Contact

- **GET /api/contacts/{id}**  
  Response: Contact

- **PUT /api/contacts/{id}**  
  Request: Contact  
  Response: Contact

- **DELETE /api/contacts/{id}**  
  Response: { "message": "Deleted" }

### Rewards (Tenants/Staff)

- **GET /api/rewards**  
  Response: Reward[]  
  Query params: user_id

- **POST /api/rewards**  
  Request: Reward  
  Response: Reward  
  **Note**: Automatically awarded for tasks, temp logs, attendance.

- **GET /api/rewards/{id}**  
  Response: Reward

### Documents (Tenants)

- **GET /api/documents**  
  Response: Document[]  
  Query params: user_id (for employee docs), tenant_id (for tenant docs)

- **POST /api/documents**  
  Request: { "user_id": string (optional), "type": string, "file": file }  
  Response: Document  
  **Strict Note**: Upload employee documents (pictures/files) by Owner/Manager; or tenant documents for general management. Store with tenant_id_type.jpg/png or user_id_type.jpg/png. **Strict Enforcement**: Validate file type, size, and tenant isolation. Unauthorized uploads rejected.

- **GET /api/documents/{id}**  
  Response: Document

- **PUT /api/documents/{id}/send**  
  Request: { "sent_to": array of string (user_ids) }  
  Response: Document  
  **Strict Note**: Send document to selected employees; updates sent_to and sent_at. **Strict Enforcement**: Only Owners/Managers can send. Triggers notifications to staff. Invalid user_ids rejected.

- **DELETE /api/documents/{id}**  
  Response: { "message": "Deleted" }

### Account Management

- **POST /api/account/forgot-password**  
  Request: { "email": string }  
  Response: { "message": "Reset email sent" }

- **PUT /api/account/update-username**  
  Request: { "new_username": string }  
  Response: User

- **PUT /api/account/update-demographics**  
  Request: Demographics  
  Response: User

### Parent/Child Hierarchy

- **POST /api/tenants/associate**  
  Request: { "parent_pin": string }  
  Response: Tenant  
  **Strict Requirement**: Child tenants must provide a valid parent PIN to associate. Association fails without correct PIN verification.

- **GET /api/tenants/children**  
  Response: Tenant[] (for parent tenants)

### Feature Management (Application Owner)

- **GET /api/features**  
  Response: Feature[]

- **PUT /api/features/{id}/toggle**  
  Request: { "enabled": boolean }  
  Response: Feature

### Role Management (Application Owner/Tenants)

- **GET /api/roles/default**  
  Response: Role[] (default roles maintained by Application Owner)

- **GET /api/roles**  
  Response: Role[] (tenant-specific roles)

- **POST /api/roles**  
  Request: Role  
  Response: Role (standalone tenants and parent tenants can create)

- **PUT /api/roles/{id}**  
  Request: Role  
  Response: Role

- **PUT /api/roles/{id}/status**  
  Request: { "status": "Active" | "Inactive" }  
  Response: Role

- **DELETE /api/roles/{id}**  
  Response: { "message": "Deleted" }

### Authorization Management (Tenants)

- **GET /api/authorizations**  
  Response: Authorization[] (feature access per role)

- **PUT /api/authorizations/{feature_id}/{role_id}**  
  Request: { "granted": boolean }  
  Response: Authorization

### Analytics (Application Owner)

- **GET /api/analytics/billing**  
  Response: Analytics

- **GET /api/reports/{feature}/{child_tenant_id}**  
  Query params: start_date, end_date  
  Response: Report (e.g., temperature logs data for child tenant)

- **GET /api/reports/summary/{child_tenant_id}**  
  Response: ReportSummary (aggregated data by features)

## UI/UX Specifications

The UX style used is Material Design 3 with a clean, professional
  aesthetic specifically designed for restaurant management. Here are the
  key design elements:

🎨 Design System

- Material 3: Modern Flutter design system (useMaterial3: true)
- Color Palette: Blue theme (#1976D2) - professional and trustworthy for
  restaurant business
- Typography: Clean, readable fonts with proper hierarchy

🏗️ Layout & Structure

- Cards: Elevated cards with 12px rounded corners and subtle shadows
- Form Design: Outlined input fields with proper spacing and icons
- Responsive: Constrained max-width (400px) for optimal desktop/tablet
  viewing
- Safe Areas: Proper padding and margins throughout

✨ Key UX Features

- Loading States: Elegant spinners and progress indicators
- Error Handling: Clean error messages with icons and color-coded
  backgrounds
- Visual Hierarchy: Restaurant icon, clear branding, and logical
  information flow
- Accessibility: Form validation, password visibility toggle, proper focus
  management

🍴 Restaurant-Specific Touches

- Branding: Restaurant menu icon and "ChefPilot" branding
- Professional Colors: Blue color scheme for trust and reliability
- Developer-Friendly: Test credentials prominently displayed in a helpful
  info box
- Context-Aware: Subtitle "Restaurant Management System" for clear purpose

📱 Modern Interactions

- Smooth Animations: Material 3 transitions and state changes
- Touch-Friendly: 48px button heights, proper touch targets
- Keyboard Support: Enter key submits form, tab navigation
- Loading Feedback: Button states change during API calls

This creates a clean, professional, and modern interface that feels both
sophisticated and approachable for restaurant staff and management.

### Navigation Flow

- **Global Navigation**: Bottom navigation bar for Tenants/Staff; Drawer menu for Application Owner.
- **Authentication**: Login screen → User type-based dashboard (Application Owner, Parent Tenant, Standalone Tenant). The dashboard displays options and features accessible based on the user's account type and configured authorizations.
- **Tenant Setup**: Mandatory wizard on first login (company type, parent association, features, user limits, demographics).

### Screen Details

#### Application Owner Screens

- **Dashboard**:
  - Widgets: Tenant list (standalone/parent), billing summary (user counts, revenue), feature toggles, analytics charts.
  - Actions: Add tenant, view details, set billing overrides.

- **Tenant Management**:
  - List view: Standalone and parent tenants only (child tenants hidden under parents).
  - Detail view: User count, active features, billing amount.
  - Actions: Edit tenant, send notifications.

- **Billing Management**:
  - Default pricing: Trial rates per user (period to expire)/monthly rates per user/yearly rates per user.
  - Override pricing: Per tenant (parent/standalone), fallback to defaults.
  - View: Revenue tracking, parent/child billing options.

- **Feature Management**:
  - List: Features with descriptions, default/required status, dates.
  - Actions: Toggle enable/disable (cascades to tenants).

- **Role Management**:
  - List: Default and custom roles.
  - Actions: Add/edit/delete roles, assign to employees. Toggle role status (Active/Inactive).

- **Analytics Dashboard**:
  - Charts: User-based sales, usage metrics, growth trends.
  - Filters: By tenant, date range.

- **Reporting Dashboard**:
  - Widgets: Feature-specific reports (e.g., temperature logs for child tenants), charts/tables.
  - Filters: By child tenant, feature, date range.
  - Actions: Export reports (PDF/CSV).

#### Tenant Screens

- **Dashboard**:
  - Widgets: Tasks summary, temperature logs, inventory alerts, staff schedule, notification alerts (e.g., temperature danger zones), rewards summary, document alerts (new documents sent).
  - Actions: Create task, log temperature, update inventory, view notifications, view rewards, manage documents.

- **Setup Wizard**:
  - Steps: Company type (standalone/parent), parent PIN (if child), feature selection, user limit, owner demographics and tenant details.
  - Validation: Required fields, PIN verification. **Strict enforcement** - Child tenants cannot complete setup without valid parent PIN association.

- **Tasks**:
  - List: Tasks with type (daily/single), schedule, status, assigned to, approval status.
  - Actions: Create (owner/manager), assign, pickup (employees), mark complete (upload image if required, status awaiting_approval), approve (managers/owners only).

- **Temperature Logs**:
  - Form: Fridge/freezer temps, notes. Enter current temperature with safe zone indicators (green for safe, red for danger).
  - List: Historical logs with date, temperature, safe status, and alerts.
  - Actions: View history, mark alerts as reviewed, access Contacts for service.

- **Inventory**:
  - List: Items with stock levels.
  - Actions: Update stock, set alerts.

- **Staff Management**:
  - List: Staff with roles.
  - Actions: Add/edit/remove, assign tasks, assign roles, upload/take pictures of employee documents (ID, license, certifications).

- **Document Management**:
  - List: Tenant documents and employee documents, filtered by access permissions.
  - Actions: Upload new documents (file picker with validation), view/download (secure access), send to employees (multi-select with confirmation), delete (with audit log).
  - **Strict UX**: Role-based visibility; progress indicators for uploads; error messages for invalid files; confirmation dialogs for sends/deletes.

- **Role Management**:
  - List: Available roles (default + custom).
  - Actions: Create custom roles, edit authorizations per feature. Toggle role status (Active/Inactive).

- **Account Management**:
  - Forgot Password: Email input.
  - Update Username: Current/new username.
  - Update Demographics: Name, contact, location.

- **Contacts**:
  - List: Suppliers, services, emergencies with contact info.
  - Actions: Add/edit/delete contacts, call/email directly.

- **Rewards**:
  - List: Reward history with points, reason, date.
  - Summary: Total points earned.
  - Actions: View details, redeem points (if applicable).

#### Staff Screens

- **Dashboard**: Assigned tasks, quick log temperature, notification alerts, rewards summary.
- **Tasks**: View and complete assigned tasks, pickup unassigned tasks, upload images for completion if required.
- **Temperature Logs**: Quick entry form with safe zone indicators.
- **Rewards**: View earned points and history.
- **Documents**: View received documents from tenant, download/view. **Strict UX**: Only sent documents visible; mark as read; offline access for critical docs.

#### Shared Components

- **Numberpad Widget**: For numeric inputs (e.g., temps, inventory), supports integer/decimal, Cancel/OK buttons.
- **Dialogs**: Confirmation, error messages.
- **Loading States**: Skeleton screens for lists.

### Platform Adaptations

- **iOS/macOS**: Use Cupertino widgets for native feel.
- **Web**: Ensure PWA support, responsive for mobile web.
- **Offline**: Sync indicators, cached data for critical features.

## Configuration

Configuration options for the agent.

## Governance & Exceptions

This project uses several "strict" requirements to ensure consistency across teams. In practice, some requirements may need pragmatic exceptions during development or to enable automation. Use the policy below to request, approve, and document any exception.

- Exception request: Open a short PR or issue titled `Exception: <area>` describing the deviation, the reason, the risk, and the proposed mitigation.
- Approval: At least one maintainer or project owner must approve the exception in the PR. If no maintainer is available, a temporary exception may be approved by the engineering lead with a follow-up review required within 7 days.
- Documentation: Approved exceptions must include a short entry in this file under "Exceptions Log" (date, approver, summary, expiration if any).
- Expiration: Exceptions should have an expiration or re-evaluation plan where applicable.

Common exception categories and recommended minimum controls:

- Secrets & env: Permit storing dev-only secrets in local `.env` files for development, but require `.env.example` in the repo and prohibit committing real secrets. Use a secrets manager (GitHub Secrets, HashiCorp Vault) for CI and production. Document rotation strategy in the PR.
- Strict UX or API lock-in: Allow temporary feature toggle changes when blocked by platform constraints; include e2e checks and a follow-up task to re-align with the strict rule.
- Long-running background jobs: If a hosted cron/worker is not yet available, a developer script with a clear owner and cadence is acceptable as a temporary measure; schedule implementation of a reliable queue within a sprint.

Exceptions Log:

- 2025-09-07 — Initial governance section added. No exceptions granted yet.

## Security & Privacy

Must follow best practices:

- **Data Encryption**: Encrypt sensitive data (customer info, financial data) at rest and in transit using industry-standard algorithms like AES-256.
- **Authentication**: Implement JWT tokens with refresh mechanism, role-based access control (RBAC), and secure password hashing (e.g., bcrypt). Roles are database-driven with feature-level authorizations strictly configurable per tenant.
- **API Security**: Apply rate limiting, input validation, SQL injection prevention, and use HTTPS with TLS 1.3. Follow Node.js best practices for HTTP transactions: handle errors on request/response streams, validate headers and body data, and use middleware for security (e.g., helmet.js for headers). **Strict Enforcement**: Validate approval permissions to prevent unauthorized task approvals.
- **PCI Compliance**: If handling payments, follow PCI DSS standards with tokenization and secure key management.
- **GDPR/Privacy**: Implement data retention policies, user consent mechanisms, and audit logs for data access.
- **Multi-Tenant Isolation**: Ensure strict data isolation between tenants using tenant-specific schemas or row-level security in SQLite3. Support parent/child tenant hierarchy with proper access controls.
- **Input Sanitization**: Sanitize all user inputs to prevent XSS and injection attacks, especially in web platform. Validate image uploads for type, size, and malware.

## Performance & Scalability

Must follow best practices:

- **Image Optimization**: Compress images, implement lazy loading for galleries, and use appropriate formats (WebP for web). Auto-clean task images older than 2 weeks to manage storage. **Document Optimization**: Compress PDFs, limit file sizes, auto-clean sent documents after 30 days.
- **Database Indexing**: Index frequently queried fields (tenant_id, timestamps) in SQLite3 for faster queries.
- **Caching Strategy**: Implement API response caching, offline-first architecture for critical data using Flutter's caching plugins.
- **Background Processing**: Use queue systems for heavy operations (reports, notifications) via Node.js background jobs.
- **Memory Management**: Properly dispose controllers, streams, and listeners in Flutter; avoid memory leaks by following Dart's Effective Guidelines (e.g., use final for variables, avoid late without checks).
- **Profiling**: Use Flutter DevTools for CPU profiling, memory analysis, and UI performance diagnostics to identify bottlenecks.
- **State Management**: Choose appropriate state management (e.g., Provider, Riverpod) based on app complexity; follow Flutter's declarative state management principles to minimize rebuilds.
- **Async Handling**: Prefer async/await over raw futures, handle errors gracefully, and use streams for real-time data.

## Testing & Quality

Must follow best practices:

- **Test Coverage**: Aim for minimum 80% unit test coverage, include integration tests for API endpoints, and use Flutter's testing framework.
- **Widget Testing**: Test all custom components in /Shared/Components/ using Flutter's widget tests.
- **E2E Testing**: Implement critical user flows (login, task creation, temperature logging) with tools like Flutter Driver or integration_test.
- **Code Analysis**: Enforce Dart analyzer rules and lint rules; follow Effective Dart guidelines for style, documentation, usage, and design (e.g., use UpperCamelCase for types, prefer async/await, avoid dynamic types).
- **Performance Testing**: Conduct load testing for multi-tenant scenarios, monitor memory usage, and use DevTools for profiling.
- **Code Reviews**: Mandatory peer reviews for all changes, ensure adherence to coding guidelines and best practices.
- **Continuous Integration**: Set up CI pipelines to run tests automatically on commits.

### Specific Test Strategies

- **Unit Tests**:
  - Test individual functions and classes (e.g., billing calculation logic, task assignment, reward calculation, document validation).
  - Use mock data for API calls; cover edge cases like invalid inputs or multi-tenant isolation.
  - Tools: Flutter's test package, Mockito for mocking.

- **Integration Tests**:
  - Test API endpoints with real database interactions (e.g., create tenant, verify data isolation, document upload/send).
  - Cover authentication flows, CRUD operations for tasks/temperature logs, reward awarding, document management.
  - Tools: Supertest for Node.js API, Flutter integration_test for UI-API interactions.

- **E2E Test Cases**:
  - **Tenant Setup**: Login as new tenant → Complete wizard → Verify dashboard access.
  - **Task Management**: Create task (daily/single) → Assign or pickup → Mark complete (upload image if required, status awaiting_approval) → Approve by manager only → Verify rewards awarded only after approval.
  - **Temperature Logging**: Log temperature → Verify safe zone indicators → If out of range, check notifications to user and owner → Review Contacts.
  - **Contact Management**: Add contact → Verify in list → Call/email from app.
  - **Rewards System**: Complete task/temp log → Check points earned → View history.
  - **Billing Override**: Application Owner sets override → Verify fallback to defaults.
  - **Document Management**: Upload tenant document → Send to employees → Verify employees receive notification and can view/download. **Strict Testing**: Test file validation (type, size), access control (unauthorized send rejected), multi-tenant isolation, audit logs.
  - Tools: Flutter Driver for full app flows.

- **Performance Benchmarks**:
  - Load test with 100+ concurrent users; measure API response times (<500ms).
  - Memory usage: <100MB for typical sessions.
  - Offline sync: Test data persistence and conflict resolution.

- **Accessibility Testing**:
  - Screen reader compatibility, keyboard navigation, high contrast modes.
  - Tools: Flutter's accessibility tools, manual testing with assistive devices.

- **Security Testing**:
  - Penetration testing for API vulnerabilities (e.g., SQL injection, XSS, file upload exploits).
  - Validate JWT expiration, role-based access, document access control.
  - Tools: OWASP ZAP, manual audits.

- **Cross-Platform Testing**:
  - Test on iOS/Android/Web simulators/emulators; verify platform-specific features (e.g., PWA on Web).
  - Tools: Firebase Test Lab for device matrix.

### Quality Assurance Process

- Run tests on every commit via CI/CD.
- Maintain test documentation in /tests/ directory.
- Conduct quarterly security audits and performance reviews.
- Use code coverage reports to identify untested areas.

## Deployment & DevOps

Must follow best practices:

- **Environment Management**: Maintain separate dev/staging/prod configurations with environment variables.
- **CI/CD Pipeline**: Implement automated testing, building, and deployment; use tools like GitHub Actions or Jenkins for Flutter and Node.js.
- **Database Migrations**: Use versioned schema changes with rollback capability; store SQL scripts in the adjacent sql directory as per guidelines.
- **Monitoring**: Integrate error tracking (e.g., Sentry), performance monitoring, and uptime monitoring for both Flutter app and Node.js API.
- **Backup Strategy**: Automate database backups with restoration testing; ensure multi-tenant data isolation in backups. Include image storage backups if using local server; prepare for future migration to cloud storage.
- **Security in Deployment**: Use HTTPS everywhere, secure API keys, and follow platform-specific deployment guidelines (e.g., App Store, Google Play).
- **Version Control**: Strict versioning for app releases and database schemas; tag releases in Git.

## User Experience

Must follow best practices:

- **Offline Support**: Ensure critical features (temperature logs, tasks) work without internet using local storage and sync when online.
- **Accessibility**: Implement screen reader support, high contrast mode, and follow WCAG guidelines for inclusive design.
- **Internationalization**: Support multi-language for restaurant chains using Flutter's intl package.
- **Responsive Design**: Use adaptive layouts for tablets and different screen sizes; test on various devices.
- **Loading States**: Provide skeleton screens and progress indicators for all async operations to improve perceived performance.
- **Error Feedback**: Show user-friendly error messages without technical details; offer actionable steps for resolution.
- **Navigation**: Intuitive navigation with clear hierarchies; use Flutter's Material Design components for consistency.
- **Feedback Loops**: Collect user feedback within the app and iterate based on it.
- **Clean UI/UX Design**: Follow Nielsen Norman Group's 10 Usability Heuristics: Visibility of System Status, Match Between System and Real World, User Control and Freedom, Consistency and Standards, Error Prevention, Recognition Rather Than Recall, Flexibility and Efficiency of Use, Aesthetic and Minimalist Design, Help Users Recognize, Diagnose, and Recover from Errors, Help and Documentation.
- **Material Design Principles**: Adhere to Material 3 guidelines for expressive components, vibrant colors, intuitive motion, and adaptive layouts to create harmony and hierarchy.
- **Apple HIG Principles**: For iOS/macOS, establish clear visual hierarchy, maintain consistency across platforms, and align with concentric design for harmony.
- **Flutter Layout Best Practices**: Use widgets like Row, Column, Container for layouts; ensure proper alignment with MainAxisAlignment and CrossAxisAlignment; avoid overflow with Expanded and Flexible; follow Effective Dart for clean code.

## Error Handling

Must follow best practices:

- **Graceful Degradation**: Ensure the app continues working when non-critical features fail; isolate failures to prevent app crashes.
- **User-Friendly Messages**: Display non-technical error messages to end users; log detailed errors for developers.
- **Retry Mechanisms**: Implement auto-retry for failed API calls with exponential backoff; allow manual retries for users.
- **Crash Reporting**: Use tools like Firebase Crashlytics for detailed crash logs without exposing sensitive data.
- **Validation**: Validate inputs on both client and server sides; handle API errors (e.g., 4xx, 5xx) appropriately in Flutter.
- **Logging**: Implement structured logging in Node.js API and Flutter app for debugging; follow Effective Dart for error handling (e.g., throw Error only for programmatic errors, use rethrow). Use libraries like `winston` for Node.js and `logging` package for Flutter. Log levels: ERROR for failures, WARN for warnings, INFO for key events, DEBUG for development. Include context like user ID, tenant ID, and timestamps. Never log sensitive data (e.g., passwords, tokens).
- **Fallbacks**: Provide fallbacks for failed operations, such as cached data or offline modes.
- **Try/Catch/Finally Enforcement**: Always wrap asynchronous operations in try/catch blocks for robustness. Use finally for cleanup (e.g., closing streams, releasing resources). In Flutter, prefer async/await with try/catch; in Node.js, use try/catch for synchronous code and promises for async.

## Legal & Compliance

Must follow best practices for app store approvals and user trust:

- **Terms of Service**: Outline user rights, responsibilities, and app usage rules. Include sections on multi-tenancy (data isolation), billing (user-based pricing), and feature access. Specify dispute resolution and governing law.
- **Privacy Policy**: Detail data collection (e.g., tenant info, task logs, reward points), storage (encrypted SQLite3), and sharing (none without consent). Cover GDPR compliance, user consent for features, and data retention (e.g., logs for 2 years). Include opt-out options and contact for data requests.
- **App Store Compliance**: Ensure policies align with Apple App Store, Google Play, and Microsoft Store guidelines. Include mandatory links in the app and backend splash screen.
- **Data Protection**: Implement user consent mechanisms for data processing; provide audit logs for compliance audits.
- **International Compliance**: Support regional laws (e.g., CCPA for California); use Flutter's intl for localized policies.
- **Liability and Disclaimers**: Limit liability for data loss; disclaim warranties for third-party integrations.
- **Updates and Notifications**: Require user acceptance of updated terms; notify via in-app alerts.

### Implementation Notes

- Host policies on the backend public area and link from the app.
- Use templates from legal services (e.g., adapt standard SaaS terms for multi-tenant apps).
- Review annually or with major updates.

## Technology Stack

- **Framework**: Flutter (<https://docs.flutter.dev>)
- **Language**: Dart (<https://dart.dev/docs>)
- **Platforms**: iOS, Android, macOS, Web
- **Backend API**: Node.js with Express (<https://nodejs.org>, <https://expressjs.com>) - **Must use** SSL/HTTPS for secure communication. **Must include** a public area with a **grand splash screen** promoting application features, **mandatory** links to app stores, terms of service, and privacy policy.
- **Database**: SQLite3

## Development Notes

As an expert in Flutter and Dart development, this project leverages the latest features of both technologies to create a robust, user-friendly application. Key considerations include:

- State management using Provider or Riverpod
- Local data storage with SQLite or Hive
- API integration for cloud services
- Image upload and storage handling (task completion images)
- Responsive UI design following Material Design principles

### Database Management

- **SQLite3 Usage**: SQLite3 serves as the backend database. The Flutter app will never connect directly to the database; all CRUD operations must be performed through the Node.js/Express API.
- **API-Only Access**: Ensure all data operations (Create, Read, Update, Delete) are handled via secure HTTPS API endpoints. No direct database connections from the client-side Flutter app.
- **SQL Directory Requirement**: On the backend, wherever the database file exists, there must be an adjacent `sql` directory that stores all executed SQL scripts. This directory must include:
  - Migration scripts for schema changes.
  - Insert/update/delete scripts for data operations.
  - Version control for all SQL changes to maintain traceability and rollback capabilities.
- **Versioning**: Implement database versioning on the backend to handle schema updates across app versions. Include scheduled jobs for image cleanup (e.g., delete files >2 weeks old).

### Platform-Specific Gotchas

When developing ChefPilot for multiple platforms, be aware of these common pitfalls and requirements. These are based on Flutter's official documentation, community experiences (e.g., from flutter.dev, dart.dev, Stack Overflow, and forums like Reddit's r/FlutterDev), and best practices as of September 2025. Always test on physical devices/emulators and review platform-specific guidelines.

- **Web**:
  - **CORS (Cross-Origin Resource Sharing)**: Web apps can't directly access APIs from different domains without proper headers. Use `flutter run --web-hostname=0.0.0.0` for local testing, and configure server-side CORS policies (e.g., via middleware in Node.js or cloud services). For production, ensure APIs support CORS or use proxies.
  - **Localhost Access**: Accessing localhost APIs from a browser may fail due to security restrictions. Use `flutter run --web-hostname=0.0.0.0` or tools like ngrok for tunneling. Avoid hardcoding localhost URLs; use environment variables.
  - **Browser Compatibility**: Test on Chrome, Firefox, Safari, and Edge. Features like WebGL or PWA may have quirks—use Flutter's web renderer (HTML or CanvasKit) appropriately. Service workers for offline support require careful handling to avoid caching issues.
  - **WebAssembly and Performance**: Flutter Web uses WebAssembly (Wasm) for better performance, but older browsers may not support it fully—fallback to CanvasKit. IndexedDB for local storage has size limits (typically 50MB)—monitor usage to avoid quota errors. PWA installation can fail on mobile browsers if the manifest is misconfigured.
  - **Other**: File uploads/downloads may be limited; use `dart:html` for web-specific APIs. Performance can vary—optimize for mobile web with responsive design.

- **iOS**:
  - **Permissions**: Request camera, location, or storage access via `NSPhotoLibraryUsageDescription` in Info.plist. Failing to do so causes app rejections. Use Flutter plugins like `permission_handler` for runtime requests.
  - **App Store Guidelines**: Ensure compliance with Apple's policies (e.g., no in-app purchases if not using StoreKit). Test on real devices for features like Face ID or ARKit. Watch for UI glitches on iPad (use adaptive layouts).
  - **Privacy and iOS 14+ Changes**: iOS 14+ requires explicit consent for tracking (App Tracking Transparency). Handle IDFA requests carefully to avoid rejections. Background tasks may be limited—use `workmanager` plugin for scheduling.
  - **Other**: Swift/Objective-C interop via platform channels can introduce build errors—keep native code minimal. Handle device orientation changes carefully to avoid layout breaks.

- **Android**:
  - **Permissions**: Declare in AndroidManifest.xml (e.g., `INTERNET`, `CAMERA`). Use `permission_handler` for dynamic requests. Android 11+ restricts scoped storage—adapt for file access.
  - **Device Fragmentation**: Test on various API levels (21+ recommended). Emulators may not reflect real hardware—use Firebase Test Lab for broad testing. Handle back button navigation with `WillPopScope`.
  - **Localhost Access**: On Android emulators, "localhost" refers to the emulator itself, not the host machine. Use `10.0.2.2` as the IP to access services running on the host (e.g., `http://10.0.2.2:3000/api`). For physical devices, use the host machine's actual IP address (e.g., `192.168.1.100`). Ensure the host firewall allows connections and use HTTPS in production to avoid security issues.
  - **Build and Optimization**: Gradle builds can fail due to dependency conflicts—use `flutter clean` and update plugins. ProGuard/R8 obfuscation may break reflection-based code (e.g., in JSON serialization)—add rules to `proguard-rules.pro`. Battery optimization can kill background services—request exemptions via `ignore_battery_optimizations`.
  - **Other**: Google Play policies require privacy disclosures for data collection. Native code integration (via Kotlin/Java) can cause ABI issues—use Flutter's method channels sparingly.

- **macOS**:
  - **Sandboxing**: macOS apps run in a sandbox, limiting file system access. Request entitlements in the app's plist for features like camera or network. Use `path_provider` for safe directory access.
  - **Desktop-Specific Features**: Handle window resizing, multiple monitors, and keyboard shortcuts with `desktop_window`. File dialogs may behave differently—test drag-and-drop functionality.
  - **Notarization and Distribution**: For App Store or outside distribution, notarize the app to avoid security warnings. Use `flutter build macos` and Apple's notarytool. Handle multiple windows or fullscreen modes carefully, as they can cause rendering issues.
  - **Other**: Similar to iOS, ensure App Store compliance if distributing via Mac App Store. Performance on older Macs can lag—optimize animations and avoid heavy computations on the main thread.

For all platforms, use Flutter's `platform` package to detect the runtime environment and conditionally apply logic. Regularly update Flutter/Dart to the latest stable versions to benefit from bug fixes. If issues arise, consult the Flutter issue tracker or community forums for platform-specific workarounds.

## Code Examples

This section provides suggested code snippets for common operations in the ChefPilot app, using Flutter/Dart for the frontend and assuming the `http` package for API calls.

### API Calls

Use the `http` package to interact with the Node.js/Express backend. Always include the JWT token in the Authorization header for authenticated requests.

#### Example: Fetching Tasks

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Task>> fetchTasks(String token, String tenantId) async {
  try {
    final response = await http.get(
      Uri.parse('https://api.chefpilot.com/api/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'tenant_id': tenantId,
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  } catch (e) {
    // Log error for debugging
    print('Error fetching tasks: $e');
    rethrow; // Re-throw for caller to handle
  } finally {
    // Cleanup if needed (e.g., close any streams)
  }
}
```

#### Example: Creating a Document

```dart
Future<Document> createDocument(String token, String tenantId, String type, File file) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.chefpilot.com/api/documents'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['tenant_id'] = tenantId;
    request.fields['type'] = type;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return Document.fromJson(json.decode(responseData));
    } else {
      throw Exception('Failed to create document: ${response.statusCode}');
    }
  } catch (e) {
    print('Error creating document: $e');
    rethrow;
  } finally {
    // Ensure file stream is closed if needed
    file.close();
  }
}
```

### Backend API Header Reading

For the Node.js/Express backend, use middleware to read headers for authentication and multi-tenancy. Assume `jsonwebtoken` for JWT verification and a database for tenant validation.

#### Example: Reading JWT and Tenant ID Headers

```javascript
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

// Middleware to read and verify JWT
const authenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ error: 'No token provided' });

  const token = authHeader.split(' ')[1]; // Extract token from "Bearer <token>"
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = decoded; // Attach user info to request
    next();
  });
};

// Middleware to read tenant_id
const checkTenant = (req, res, next) => {
  const tenantId = req.headers['tenant_id'];
  if (!tenantId) return res.status(400).json({ error: 'Tenant ID required' });

  // Validate tenant exists in database
  // Assuming db.query is your database function
  db.query('SELECT * FROM tenants WHERE id = ?', [tenantId], (err, results) => {
    if (err || results.length === 0) return res.status(404).json({ error: 'Invalid tenant' });
    req.tenant = results[0];
    next();
  });
};

// Use in a route
app.get('/api/tasks', authenticate, checkTenant, (req, res) => {
  try {
    // Access req.user and req.tenant here
    res.json({ message: 'Tasks for tenant', tenantId: req.tenant.id });
  } catch (error) {
    console.error('Error in /api/tasks:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

#### Example: Reading Custom Headers for File Upload

```javascript
const multer = require('multer');

// Configure multer for file uploads
const upload = multer({ dest: 'uploads/' });

app.post('/api/documents', authenticate, checkTenant, upload.single('file'), (req, res) => {
  try {
    const type = req.body.type; // Read from form data
    const file = req.file; // File from multer

    // Process file and save to database
    // Include tenant isolation
    res.json({ message: 'Document uploaded', fileUrl: file.path });
  } catch (error) {
    console.error('Error uploading document:', error);
    res.status(500).json({ error: 'Upload failed' });
  }
});
```

These examples use standard Express middleware. Ensure to handle errors and validate headers strictly for security.

### Model Usage

Models are defined as classes with fromJson and toJson methods for serialization.

#### Example: Using the Document Model

```dart
// Instantiate from JSON
try {
  Map<String, dynamic> jsonData = {
    'id': 'uuid-123',
    'tenant_id': 'tenant-456',
    'type': 'policy',
    'file_url': 'https://example.com/file.pdf',
    'uploaded_by': 'user-789',
    'uploaded_at': '2025-09-05T10:00:00Z',
  };

  Document doc = Document.fromJson(jsonData);

  // Access properties
  print(doc.type); // Output: policy

  // Convert back to JSON
  Map<String, dynamic> jsonOutput = doc.toJson();
} catch (e) {
  print('Error handling document: $e');
}
```

#### Example: Handling Lists of Models

```dart
List<Document> documents = [];

// Add a new document
Document newDoc = Document(
  id: 'uuid-new',
  tenantId: 'tenant-456',
  type: 'manual',
  fileUrl: 'https://example.com/manual.pdf',
  uploadedBy: 'user-789',
  uploadedAt: DateTime.now(),
);
documents.add(newDoc);

// Serialize list
List<Map<String, dynamic>> jsonList = documents.map((doc) => doc.toJson()).toList();
```

These examples assume you have the models defined as shown in the Data Models section. Adjust imports and error handling as needed for your implementation.

## 🔌 NETWORK CONNECTION ISSUES

**Problem**: Flutter app fails to connect to local API server with "Operation not permitted" error.

**Root Cause**: macOS network permissions not granted for the Flutter app.

**Solution**:

1. Add network client entitlement to `macos/Runner/DebugProfile.entitlements`:

   ```xml
   <key>com.apple.security.network.client</key>
   <true/>
   ```

2. Add ATS configuration to `ios/Runner/Info.plist`:

   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsLocalNetworking</key>
       <true/>
   </dict>
   ```

3. Use `127.0.0.1` instead of `localhost` in API URLs for better macOS compatibility.

**Prevention**: Always configure network permissions during initial Flutter project setup for macOS/iOS targets.

---

## 🔐 AUTHENTICATION MISMATCHES

**Problem**: Login fails with "Invalid credentials" despite correct username/password.

**Root Cause**: Frontend test users have different passwords than what the backend expects.

**Solution**:

1. Update backend authentication logic to match frontend test credentials:

   ```javascript
   // Check password based on username for test users
   let isValidPassword = false;
   if (username === 'admin' && password === 'password123') {
     isValidPassword = true;
   } else if (username === 'testuser' && password === 'testpass') {
     isValidPassword = true;
   } else if (username === 'owner' && password === 'ownerpass') {
     isValidPassword = true;
   }
   ```

2. Ensure database initialization includes all test users.

**Prevention**: Keep test credentials synchronized between frontend and backend during development.

---

## 🚀 API SERVER STARTUP ISSUES

**Problem**: `npm start` fails with "package.json not found" error.

**Root Cause**: Running npm commands from wrong directory.

**Solution**:

```bash
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && npm start
```

**Prevention**: Use absolute paths or ensure you're in the project root with proper directory structure.

---

## 📁 DIRECTORY NAVIGATION ERRORS

**Problem**: Commands fail because working directory is incorrect.

**Solution**:

```bash
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot && flutter run -d macos
cd /Users/josephcurry/MyCode/zCode/ChefAssistant/ChefPilot-API && node server.js
```

**Prevention**: Document and use absolute paths in run commands to avoid confusion.

---

## 🗄️ DATABASE INITIALIZATION PROBLEMS

**Problem**: Test users not available in database after server restart.

**Root Cause**: Database initialization script missing some test users.

**Solution**: Ensure all test users are included in database setup:

```javascript
db.run(`INSERT OR IGNORE INTO users (id, username, email, password_hash, user_type, created_at)
  VALUES ('owner-1', 'admin', 'admin@chefpilot.com', '\$2a\$10\$examplehash', 'Application Owner', datetime('now'))`);

db.run(`INSERT OR IGNORE INTO users (id, username, email, password_hash, user_type, created_at)
  VALUES ('test-1', 'testuser', 'test@chefpilot.com', '\$2a\$10\$examplehash', 'Regular User', datetime('now'))`);

db.run(`INSERT OR IGNORE INTO users (id, username, email, password_hash, user_type, created_at)
  VALUES ('owner-2', 'owner', 'owner@chefpilot.com', '\$2a\$10\$examplehash', 'Application Owner', datetime('now'))`);
```

**Prevention**: Keep database initialization scripts comprehensive and up-to-date.

---

## ⚠️ ERROR HANDLING IMPLEMENTATION

**Problem**: Users need better error feedback and ability to copy error details.

**Solution**: Implement comprehensive error display widget:

- Show user-friendly error messages
- Include copy-to-clipboard functionality
- Provide actionable troubleshooting steps
- Clear error state on dismiss

**Prevention**: Always include error handling with user-friendly messages and debugging capabilities.

---

## 💡 DEVELOPMENT WORKFLOW BEST PRACTICES

**Learned Lessons**:

1. **Start API server first**: Always ensure backend is running before testing frontend
2. **Test incrementally**: Verify each component works before moving to the next
3. **Use proper error handling**: Implement try/catch blocks and user-friendly error messages
4. **Document platform differences**: macOS, iOS, Android, and Web have different requirements
5. **Keep credentials synchronized**: Ensure test users match between frontend and backend
6. **Use absolute paths**: Prevents directory navigation errors
7. **Test on target platforms**: Don't assume emulator behavior matches real devices

**Quick Debug Checklist**:

- [ ] API server running on port 3000
- [ ] Network permissions configured for target platform
- [ ] Correct working directory for commands
- [ ] Test credentials match between frontend/backend
- [ ] Database initialized with test users
- [ ] Error handling provides actionable feedback

---

## 📁 DIRECTORY STRUCTURE LESSONS LEARNED

**Key Learnings from Recent Code Organization**:

### ✅ Proper Feature-Based Directory Structure

**Before (Incorrect)**:

```bash
lib/
  application_owner/
    screens/
      billing_overview_screen.dart
      dashboard_screen.dart
      login_screen.dart
  shared/
    dialogs/
      edit_pricing_dialog.dart
```

**After (Correct)**:

```bash
lib/
  application_owner/
    screens/
      billing_overview/
        billing_overview_screen.dart
        dialogs/
          edit_pricing_dialog.dart
      dashboards/
        dashboard_screen.dart
      login_screen.dart
  shared/
    widgets/
    models/
```

### ✅ Organization Principles

1. **Feature-First Organization**: Each major feature gets its own directory
   - `billing_overview/` contains screen + related dialogs
   - `dashboards/` contains dashboard-specific screens
   - Related files are co-located

2. **Dialog Separation**: Dialogs belong with their parent features
   - Edit pricing dialog → `billing_overview/dialogs/`
   - NOT in shared unless truly reusable across multiple features

3. **Screen vs Dashboard Distinction**:
   - `screens/` for general screens (login, billing, etc.)
   - `dashboards/` for dashboard-specific screens
   - Both under `screens/` directory for consistency

4. **Shared Components**: Only truly shared components go in `shared/`
   - Widgets used across multiple features
   - Models used by multiple screens
   - NOT feature-specific dialogs

### ✅ Implementation Guidelines

- **File Co-location**: Keep related files together (screen + its dialogs)
- **Import Updates**: Update all import paths when reorganizing
- **No Shared Dialogs**: Unless a dialog is used by 3+ different features
- **Feature Boundaries**: Each feature should be self-contained
- **Consistent Naming**: Use descriptive directory names

### ✅ Benefits Achieved

- **Better Maintainability**: Related files are grouped together
- **Clear Separation**: Easy to find feature-specific code
- **Scalability**: Easy to add new features with their own directories
- **Developer Experience**: Intuitive file navigation
- **Code Organization**: Follows Flutter best practices
