# 🍔 Tasty Delights - Flutter Food Delivery App

A complete food delivery e-commerce application built with Flutter & Dart, following the Tasty Delights wireframe design.

## 📁 Project Structure

```
lib/
├── bloc/
│   └── app_bloc.dart          # Central state management (ChangeNotifier)
├── models/
│   ├── food_item.dart         # Food item model
│   ├── cart_item.dart         # Cart item model
│   ├── order.dart             # Order model with status enum
│   └── user_model.dart        # User profile model
├── presenters/
│   └── main_shell.dart        # Bottom nav shell / page controller
├── services/
│   ├── auth_service.dart      # Login / logout / session
│   ├── local_db_service.dart  # SharedPreferences persistence
│   ├── mock_data_service.dart # Static food data
│   └── order_service.dart     # Place & retrieve orders
├── theme/
│   └── app_theme.dart         # Colors, typography, component styles
├── views/
│   ├── auth/
│   │   └── login_view.dart    # Login page
│   ├── home/
│   │   ├── home_view.dart     # Home with search, categories, grid
│   │   └── food_detail_view.dart # Food detail page
│   ├── cart/
│   │   └── cart_view.dart     # Cart with checkout
│   ├── orders/
│   │   └── orders_view.dart   # Order history
│   └── profile/
│       └── profile_view.dart  # User profile & settings
├── widgets/
│   ├── food_card.dart         # Reusable food card widget
│   └── custom_bottom_nav.dart # Custom bottom navigation bar
├── app.dart                   # App root + auth gate routing
└── main.dart                  # Entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation

1. **Clone / extract** the project folder

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Create assets folder** (required by pubspec):
   ```bash
   mkdir -p assets/images
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🔐 Demo Login Credentials

| Email | Password |
|-------|----------|
| user@tastydelights.com | password123 |
| demo@demo.com | demo123 |

## ✨ Features

### Login Page
- Email & password authentication
- "Forgot Password" placeholder
- Demo credentials shown for easy testing

### Home
- Personalized greeting
- Search bar with live filtering
- Horizontal special offers carousel
- Category filter chips (13 categories)
- Responsive 2-column food grid
- Favorites toggle (heart icon)

### Food Detail
- Full-screen image hero
- Rating, review count, category badge
- Add to Cart button with snackbar confirmation
- Delivery info chips (time, calories, delivery fee)

### Cart
- Add/remove items, adjust quantities
- Per-item and total price calculation
- Order summary with delivery fee
- Checkout bottom sheet with address input
- Clear all cart button

### Orders
- Full order history
- Expandable order cards showing items + address
- Order status badges (Pending, Confirmed, Preparing, On The Way, Delivered)
- Date & time formatting

### Profile
- User avatar with initial letter
- Editable name, phone, address
- Address, Notification, Payment, Help Center, Invite Friends, Logout menu
- Logout confirmation dialog

## 📦 Dependencies

```yaml
shared_preferences: ^2.2.2   # Local persistence
uuid: ^4.2.1                  # Unique order IDs
intl: ^0.18.1                 # Date formatting
cached_network_image: ^3.3.0  # Image caching
provider: ^6.1.1              # State management
```

## 🎨 Design

- **Primary Color:** #FF6B35 (warm orange)
- **Background:** #FAF9F7 (warm off-white)  
- **Typography:** Poppins (via Google Fonts fallback)
- **Currency:** Philippine Peso (₱)
