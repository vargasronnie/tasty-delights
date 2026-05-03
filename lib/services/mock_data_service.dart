import '../models/food_item.dart';

class MockDataService {
  static List<FoodItem> getFoodItems() {
    return [
      FoodItem(
        id: '1',
        name: 'Jollibee Chicken Joy',
        description: 'Golden crispy chicken with secret spice blend',
        price: 249.00,
        imageUrl:
            'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',
        category: 'Chicken',
        rating: 4.8,
        reviewCount: 234,
      ),
      FoodItem(
        id: '2',
        name: 'Beef Burger Deluxe',
        description: 'Juicy beef patty with fresh veggies and special sauce',
        price: 199.00,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        category: 'Burgers',
        rating: 4.7,
        reviewCount: 189,
      ),
      FoodItem(
        id: '3',
        name: 'Margherita Pizza',
        description: 'Classic pizza with fresh mozzarella and basil',
        price: 329.00,
        imageUrl:
            'https://images.unsplash.com/photo-1598023696416-0193a0bcd302?w=400',
        category: 'Pizza',
        rating: 4.6,
        reviewCount: 312,
      ),
      FoodItem(
        id: '4',
        name: 'Pad Thai Noodles',
        description: 'Authentic Thai noodles with shrimp and peanuts',
        price: 189.00,
        imageUrl:
            'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
        category: 'Noodles',
        rating: 4.5,
        reviewCount: 156,
      ),
      FoodItem(
        id: '5',
        name: 'Salmon Sushi Roll',
        description: 'Fresh salmon with avocado in crispy seaweed',
        price: 389.00,
        imageUrl:
            'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
        category: 'Sushi',
        rating: 4.9,
        reviewCount: 421,
      ),
      FoodItem(
        id: '6',
        name: 'Creamy Pasta Carbonara',
        description: 'Rich and creamy pasta with bacon and parmesan',
        price: 279.00,
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
        category: 'Pasta',
        rating: 4.7,
        reviewCount: 198,
      ),
      FoodItem(
        id: '7',
        name: 'Chicken Shawarma Wrap',
        description: 'Spiced chicken with garlic sauce and vegetables',
        price: 159.00,
        imageUrl:
            'https://images.unsplash.com/photo-1561651823-34feb02250e4?w=400',
        category: 'Wraps',
        rating: 4.6,
        reviewCount: 267,
      ),
      FoodItem(
        id: '8',
        name: 'BBQ Pork Ribs',
        description: 'Slow-cooked tender ribs with smoky BBQ glaze',
        price: 499.00,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        category: 'BBQ',
        rating: 4.8,
        reviewCount: 345,
      ),
      FoodItem(
        id: '9',
        name: 'Greek Salad Bowl',
        description: 'Fresh greens with feta, olives, and Greek dressing',
        price: 149.00,
        imageUrl:
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
        category: 'Salads',
        rating: 4.4,
        reviewCount: 89,
      ),
      FoodItem(
        id: '10',
        name: 'Mango Cheesecake',
        description: 'Creamy cheesecake with fresh mango topping',
        price: 179.00,
        imageUrl:
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
        category: 'Desserts',
        rating: 4.9,
        reviewCount: 512,
      ),
      FoodItem(
        id: '11',
        name: 'Tom Yum Soup',
        description: 'Spicy Thai soup with shrimp and mushrooms',
        price: 169.00,
        imageUrl:
            'https://images.unsplash.com/photo-1562802378-063ec186a863?w=400',
        category: 'Soups',
        rating: 4.5,
        reviewCount: 143,
      ),
      FoodItem(
        id: '12',
        name: 'Truffle Fries',
        description: 'Crispy fries drizzled with truffle oil and parmesan',
        price: 129.00,
        imageUrl:
            'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
        category: 'Snacks',
        rating: 4.6,
        reviewCount: 278,
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'All',
      'Chicken',
      'Burgers',
      'Pizza',
      'Noodles',
      'Sushi',
      'Pasta',
      'Wraps',
      'BBQ',
      'Salads',
      'Desserts',
      'Soups',
      'Snacks',
    ];
  }

  static List<FoodItem> getSpecialOffers() {
    final items = getFoodItems();
    return [items[0], items[2], items[4], items[7]];
  }
}
