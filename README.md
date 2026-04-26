# ElevenStore: Event-Driven Microservices E-Commerce Platform

Highly scalable, multi-vendor e-commerce platform using an event-driven microservices architecture (Nx Monorepo, Kafka, TensorFlow.js). Features distinct portals for Users, Sellers, and Admins.

---

## 🏗️ High-Level Design (HLD)

```mermaid
graph TD
    %% Frontends
    U_UI[User Next.js App] --> AG
    S_UI[Seller Next.js App] --> AG
    A_UI[Admin Next.js App] --> AG
    
    %% API Gateway
    AG[API Gateway Express/Proxy]
    
    %% Microservices
    AG --> Auth[Auth Service]
    AG --> Prod[Product Service]
    AG --> Order[Order Service]
    AG --> Sell[Seller Service]
    AG --> Adm[Admin Service]
    AG --> Chat[Chatting Service Socket.io]
    AG --> Rec[Recommendation Service]
    
    %% Async & DB Layer
    Auth -.-> Mongo[(MongoDB Primary)]
    Prod -.-> Mongo
    Sell -.-> Mongo
    Adm -.-> Mongo
    Order -.-> Mongo
    Order -.-> Stripe[Stripe Payment]
    
    Auth -.-> Redis[(Redis Cache)]
    Prod -.-> Redis
    
    %% Event Driven Analytics
    U_UI -- User Actions --> AG
    AG --> KafkaBroker{{Kafka Message Broker}}
    KafkaBroker -.-> KafkaConsumer[Kafka Consumer Service]
    KafkaConsumer -. Batch Update .-> Mongo
    
    %% External Services
    Prod -.-> IK[ImageKit CDN]
    Auth -.-> NodeMail[Nodemailer / OTP]
    Chat -.-> Firebase[Firebase Push Notifs]
```

---

## 🔄 Core System Flows

### Event-Driven Recommendation Flow
```mermaid
sequenceDiagram
    participant User as User (Next.js)
    participant API as API Gateway
    participant Kafka as Kafka Broker (Topic: user-events)
    participant Consumer as Kafka Consumer Service
    participant DB as MongoDB
    participant TF as TF.js Rec Engine
    
    User->>API: Click Product / Add to Cart
    API->>Kafka: Publish Event { action: "add_to_cart", ... }
    Kafka-->>Consumer: Poll Events
    Consumer->>Consumer: Wait 3 seconds (Batching)
    Consumer->>DB: Bulk Write Analytics
    TF->>DB: Read Aggregated Analytics
    TF->>TF: Train / Update Model
    TF-->>User: Return Personalized Recommendations
```

### Order & Commission Flow
```mermaid
sequenceDiagram
    participant User
    participant Order as Order Service
    participant Stripe as Stripe Gateway
    participant DB as MongoDB
    participant Admin
    
    User->>Order: Place Order + Discount Code
    Order->>Stripe: Create Payment Intent
    Stripe-->>User: Payment processing
    User->>Stripe: Confirm Payment
    Stripe-->>Order: Webhook (Payment Success)
    Order->>DB: Update Order Status (Split: 90% Seller, 10% Admin)
    Order->>User: Confirmation Email
```

---

## 🗄️ Database Schema

![Database Schema](./db_schema.svg)

---

## 🚀 Development & Startup Guide

*A simple guide to run the e-commerce platform locally on your machine.*

### 📋 Prerequisites

- **Node.js** (v20.19.3)
- **Docker Desktop** (for Kafka)
- **pnpm** (recommended)

### 1. Download & Setup Project

```bash
# Navigate to the project root directory
cd elevenstore

# Install dependencies
pnpm install
```

### 2. Environment Configuration

Create `.env` files in the following locations:

#### Root Directory (`.env`)
```bash
# Copy from .env.example if available, or create new
touch .env
```

#### User UI (`.env`)
```bash
cd apps/user-ui
touch .env
```

#### Seller UI (`.env`)
```bash
cd apps/seller-ui
touch .env
```

#### Admin UI (`.env`)
```bash
cd apps/admin-ui
touch .env
```

### 3. Required Environment Variables

Fill in your `.env` files with the following variables:

#### Root `.env` (Backend Services)
```env
# Database
DATABASE_URL="mongodb+srv://username:password@cluster.mongodb.net/elevenstore-db"

# Redis
REDIS_DATABASE_URI="rediss://your-redis-url.upstash.io"

# JWT Secrets
ACCESS_TOKEN_SECRET="your-access-token-secret"
REFRESH_TOKEN_SECRET="your-refresh-token-secret"

# SMTP (Email)
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_PORT=465
SMTP_SERVICE=gmail
SMTP_HOST=smtp.gmail.com

# Stripe (Payments)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
NEXT_PUBLIC_STRIPE_PUBLIC_KEY="pk_test_..."

# ImageKit (Image CDN)
IMAGEKIT_PUBLIC_KEY="public_..."
IMAGEKIT_SECRET_KEY="private_..."
# KAFKA_BROKERS=kafka:29092 only for production
# Use local Kafka for development
KAFKA_BROKERS=localhost:9092
```

#### UI `.env` files (Frontend Apps)
```env
# API Gateway URL
NEXT_PUBLIC_API_URL="http://localhost:8080"
```

### 4. Database Setup

```bash
# Push the database schema
npx prisma db push
```

### 5. Start Kafka Infrastructure

```bash
# Make sure Docker Desktop is running
# Start Kafka services
npm run kafka:dev:up

# Wait for Kafka to fully start (check Docker Desktop)
```

### 6. Start All Services

```bash
# Start all backend services
npm run dev

# In separate terminals, start the frontend apps:
npm run user-ui    # Runs on http://localhost:3000
npm run seller-ui  # Runs on http://localhost:3001  
npm run admin-ui   # Runs on http://localhost:3002
```

## 🌐 Access Your Applications

Once everything is running:

| Application | URL | Description |
|-------------|-----|-------------|
| **User Frontend** | http://localhost:3000 | Main customer-facing app |
| **Seller Dashboard** | http://localhost:3001 | Seller management interface |
| **Admin Panel** | http://localhost:3002 | Admin control center |
| **API Gateway** | http://localhost:8080 | Backend API endpoint |

## 🔧 Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Check what's using the port
lsof -i :3000
# Kill the process or use different ports
```

**Kafka not starting:**
```bash
# Check Docker Desktop is running
# Restart Kafka
npm run kafka:dev:down
npm run kafka:dev:up
```

**Environment variables not loading:**
- Ensure `.env` files are in the correct locations
- Restart services after changing `.env` files
- Check for typos in variable names

**Database connection issues:**
```bash
# Test database connection
npx prisma db push
# Check your DATABASE_URL in .env
```

### Useful Commands

```bash
# Stop all services
npm run kafka:dev:down

# Clear NX cache
npx nx reset

# Reinstall dependencies
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Check service status
docker ps
```

## 🎯 Next Steps

1. **Create test accounts** in the user interface
2. **Explore the seller dashboard** to manage products
3. **Test the admin panel** for system management
