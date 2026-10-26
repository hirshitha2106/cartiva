# CARTIVA — Luxury Next-Gen Commerce

CARTIVA is a state-of-the-art Flutter e-commerce application crafted with luxury aesthetics, smooth micro-interactions, reactive state management, and an interactive 3D product viewer.

---

## 🏛️ Project Architecture

```
CARTIVA
│
├── Flutter Frontend
│   ├── Home (Animated Hero Section, Category Strip, Flash Drops with Live Countdown, Trending, Curated Grid)
│   ├── Categories (Visual photography cards with direct collection navigation)
│   ├── Products (Responsive Grid/List view, Real-time search, Filter bottom sheet)
│   ├── Product Details (Interactive 3D model viewer & Studio Gallery, Specs table, Color/Size pickers)
│   ├── Cart (Free Express Shipping progress bar, Promo codes, Stepper, Checkout receipt simulation)
│   ├── Wishlist (Favorites collection, Quick Move to Cart, Item badge counters)
│   └── Profile (VIP membership tier badge, Wallet & Reward Points, Order tracking timeline, Dark/Light mode switch)
│
├── UI / Animation
│   ├── Animated Hero Section (Auto-orbiting banner carousel with gradient depth aura)
│   ├── Floating Product Cards (Subtle hover elevation, glassmorphism badges, heart bounce animation)
│   ├── Page Transitions (SlideUpPageRoute, FadeScalePageRoute)
│   └── Interactive 3D Viewer (Matrix4 360° yaw/pitch drag gestures, auto-spin orbit, dynamic lighting reflection, hotspot pins)
│
├── State Management (Provider)
│   ├── Product State (`ProductProvider` — catalog, filters, search, sorting)
│   ├── Cart State (`CartProvider` — items, promo codes, shipping threshold calculation)
│   ├── Wishlist State (`WishlistProvider` — favorites toggle & move-to-cart)
│   ├── Auth State (`AuthProvider` — session simulation & user profile updates)
│   └── Theme State (`ThemeProvider` — dynamic dark/light luxury theme switching)
│
├── Data
│   ├── Product Models (`Product`, `CategoryModel`, `CartItem`, `OrderModel`, `UserModel`)
│   ├── Sample Products (`SampleData` — 8 flagship products with specs, variants, multi-angle imagery)
│   └── Repositories (`ProductRepository`, `CartRepository`, `OrderRepository`, `AuthRepository`)
│
└── Backend — Future Phase
    ├── Authentication (Firebase / Supabase / OAuth ready interfaces)
    ├── Product Database (REST / GraphQL repository plug-ins)
    ├── User Database (Profile & address management)
    └── Order Management (Live webhook tracking & payment gateway integration)
```

---

## 🚀 Running the App

### 1. Web Preview (Already Built and Running)
A local production web server is currently running at:
```bash
http://localhost:5000
```
Open [http://localhost:5000](http://localhost:5000) in Chrome, Edge, or your browser of choice.

### 2. Flutter Run
To run the app with hot reload in debug mode:
```bash
# In Chrome
flutter run -d chrome

# On Windows Desktop
flutter run -d windows
```

### 3. Build for Production
```bash
flutter build web --no-tree-shake-icons
```

---

## 💎 Features Highlights

- **Interactive 3D Viewer**:
  - Drag horizontally and vertically to rotate the product in full 3D perspective (`Matrix4`).
  - Auto 360° Orbit mode with dynamic light specular reflections that track the rotation angle.
  - Interactive hotspot pins on the product highlighting engineering specs.
- **Promo Code System**:
  - `CARTIVA20`: 20% VIP Cartiva discount
  - `CARTIVA50`: $50 instant discount
  - `FREESHIP`: Free express shipping
- **Free Express Shipping Progress**:
  - Live progress bar dynamically calculates how much more to add to unlock free shipping ($300 threshold).
- **Themes**:
  - **Luxury Obsidian Dark Theme** (Default)
  - **Clean Canvas Light Theme** (Toggleable in Profile or Home AppBar).
