

import '../../../models/product_model.dart';

class InstantCategoryModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String image;
  final String bannerText;
  final List<ProductModel> products;

  const InstantCategoryModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.image,
    required this.bannerText,
    required this.products,
  });
}

// ----------------- 1. VEGETABLES (HD IMAGES) -----------------
final List<ProductModel> vegetableProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Farm Hybrid Tomatoes (1 kg)",
    price: 2.20,
    priceAfetDiscount: 1.80,
    dicountpercent: 18,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Farm Golden Potatoes (1 kg)",
    price: 1.50,
    priceAfetDiscount: 1.20,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Organic Fresh Red Onions (1 kg)",
    price: 1.80,
    priceAfetDiscount: 1.50,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Crisp Green Capsicum (500 g)",
    price: 2.60,
    priceAfetDiscount: 2.10,
    dicountpercent: 19,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Leafy Farm Spinach (250 g)",
    price: 1.25,
    priceAfetDiscount: 0.99,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Crisp Sweet Baby Carrots (500 g)",
    price: 1.75,
    priceAfetDiscount: 1.40,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Sweet Green Peas (500 g)",
    price: 3.00,
    priceAfetDiscount: 2.40,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Farm White Cauliflower (1 pc)",
    price: 2.00,
    priceAfetDiscount: 1.60,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Crunchy Green Cucumber (500 g)",
    price: 1.40,
    priceAfetDiscount: 1.10,
    dicountpercent: 21,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Green Broccoli Florets (1 pc)",
    price: 3.50,
    priceAfetDiscount: 2.80,
    dicountpercent: 20,
  ),
];

// ----------------- 2. FRUITS (HD IMAGES) -----------------
final List<ProductModel> fruitProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Sweet Robusta Bananas (Pack of 6)",
    price: 1.50,
    priceAfetDiscount: 1.20,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Crisp Royal Gala Apples (1 kg)",
    price: 4.20,
    priceAfetDiscount: 3.50,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1582979512210-99b6a53386f9?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Juicy Sweet Nagpur Oranges (1 kg)",
    price: 3.40,
    priceAfetDiscount: 2.80,
    dicountpercent: 17,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Sweet Seedless Green Grapes (500 g)",
    price: 3.00,
    priceAfetDiscount: 2.50,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Ruby Red Sweet Pomegranate (2 pcs)",
    price: 3.80,
    priceAfetDiscount: 3.20,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Ripe Sweet Papaya (1 pc)",
    price: 2.50,
    priceAfetDiscount: 2.00,
    dicountpercent: 20,
  ),
];

// ----------------- 3. DAIRY & BREAD (HD IMAGES) -----------------
final List<ProductModel> dairyProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Farm Pure Whole Milk (1 L)",
    price: 2.20,
    priceAfetDiscount: 1.99,
    dicountpercent: 10,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "100% Whole Wheat Toast Bread (400 g)",
    price: 1.75,
    priceAfetDiscount: 1.49,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Brown Farm Eggs (Pack of 6)",
    price: 2.50,
    priceAfetDiscount: 2.10,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1628088062854-d1870b4553da?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Creamy Salted Table Butter (100 g)",
    price: 2.00,
    priceAfetDiscount: 1.80,
    dicountpercent: 10,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1631451095765-2c91616fc9e6?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Malai Cottage Cheese (200 g)",
    price: 2.99,
    priceAfetDiscount: 2.50,
    dicountpercent: 16,
  ),
];

// ----------------- 4. SNACKS & MUNCHIES (HD IMAGES) -----------------
final List<ProductModel> snackProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Classic Crispy Salted Chips (50 g)",
    price: 1.50,
    priceAfetDiscount: 1.20,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1621939514649-280e2ee25f60?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Sour Cream & Green Onion Crisps (50 g)",
    price: 1.50,
    priceAfetDiscount: 1.20,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Gourmet Choco Chip Cookies (120 g)",
    price: 2.40,
    priceAfetDiscount: 2.00,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1578849278619-e73505e9610f?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Golden Butter Crunch Popcorn (80 g)",
    price: 1.80,
    priceAfetDiscount: 1.50,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1508746829417-e6f548d8d6ed?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Roasted & Salted Jumbo Cashews (200 g)",
    price: 5.50,
    priceAfetDiscount: 4.50,
    dicountpercent: 18,
  ),
];

// ----------------- 5. DRINKS & BEVERAGES (HD IMAGES) -----------------
final List<ProductModel> drinkProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "100% Cold Pressed Orange Juice (1 L)",
    price: 3.60,
    priceAfetDiscount: 3.00,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1550258987-190a2d41a8ba?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Fresh Pure Tender Coconut Water (200 ml)",
    price: 2.20,
    priceAfetDiscount: 1.80,
    dicountpercent: 18,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Chilled Sparkling Cola Can (330 ml)",
    price: 1.50,
    priceAfetDiscount: 1.25,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Iced Zesty Lemonade Cooler (500 ml)",
    price: 2.40,
    priceAfetDiscount: 1.99,
    dicountpercent: 17,
  ),
];

// ----------------- 6. INSTANT FOOD (HD IMAGES) -----------------
final List<ProductModel> instantFoodProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Instant Masala Noodles (Pack of 4)",
    price: 2.60,
    priceAfetDiscount: 2.20,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1551462147-ff29053bfc14?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Italian Durum Wheat Penne Pasta (500 g)",
    price: 2.50,
    priceAfetDiscount: 2.10,
    dicountpercent: 16,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Classic Rich Tomato Ketchup (500 g)",
    price: 2.90,
    priceAfetDiscount: 2.50,
    dicountpercent: 14,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1586444248902-2f64eddc13df?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Whole Grain Rolled Breakfast Oats (1 kg)",
    price: 4.40,
    priceAfetDiscount: 3.80,
    dicountpercent: 13,
  ),
];

// ----------------- 7. CLEANING & HOUSEHOLD (HD IMAGES) -----------------
final List<ProductModel> cleaningProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Lemon Sparkle Dishwash Gel (500 ml)",
    price: 2.80,
    priceAfetDiscount: 2.40,
    dicountpercent: 14,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Antibacterial Surface Floor Cleaner (1 L)",
    price: 3.50,
    priceAfetDiscount: 2.99,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1584362917165-526a968579e8?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Ultra Soft 2-Ply Facial Tissues (Pack of 2)",
    price: 2.20,
    priceAfetDiscount: 1.80,
    dicountpercent: 18,
  ),
];

// ----------------- 8. PERSONAL CARE (HD IMAGES) -----------------
final List<ProductModel> personalCareProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1608248597359-2169b9175a00?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Gentle Moisture Liquid Handwash (250 ml)",
    price: 2.60,
    priceAfetDiscount: 2.20,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Natural Moisture Bathing Soap Bar (Pack of 3)",
    price: 3.40,
    priceAfetDiscount: 2.90,
    dicountpercent: 15,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=600&q=85",
    brandName: "⚡ 10 MINS",
    title: "Herbal Nourishing Hair Shampoo (200 ml)",
    price: 4.20,
    priceAfetDiscount: 3.50,
    dicountpercent: 16,
  ),
];

// ----------------- ALL CATEGORIES LIST (HD THUMBNAILS) -----------------
final List<InstantCategoryModel> instantDeliveryCategories = [
  InstantCategoryModel(
    id: "vegetables",
    name: "Vegetables",
    iconEmoji: "🥦",
    image: "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=85",
    bannerText: "Fresh Farm Vegetables • Harvested Daily",
    products: vegetableProducts,
  ),
  InstantCategoryModel(
    id: "fruits",
    name: "Fresh Fruits",
    iconEmoji: "🍎",
    image: "https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=600&q=85",
    bannerText: "Sweet & Juicy Fresh Fruits • 100% Quality",
    products: fruitProducts,
  ),
  InstantCategoryModel(
    id: "dairy",
    name: "Dairy & Bread",
    iconEmoji: "🥛",
    image: "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=85",
    bannerText: "Morning Essentials • Milk, Bread, Eggs & Butter",
    products: dairyProducts,
  ),
  InstantCategoryModel(
    id: "snacks",
    name: "Snacks & Munchies",
    iconEmoji: "🍟",
    image: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=600&q=85",
    bannerText: "Cravings Sorted in 10 Mins • Chips & Cookies",
    products: snackProducts,
  ),
  InstantCategoryModel(
    id: "drinks",
    name: "Cold Drinks & Juices",
    iconEmoji: "🥤",
    image: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&w=600&q=85",
    bannerText: "Chilled Drinks & 100% Real Fruit Juices",
    products: drinkProducts,
  ),
  InstantCategoryModel(
    id: "instant_food",
    name: "Instant Food",
    iconEmoji: "🍜",
    image: "https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=85",
    bannerText: "Ready in Minutes • Noodles, Pasta & Cereals",
    products: instantFoodProducts,
  ),
  InstantCategoryModel(
    id: "cleaning",
    name: "Cleaning & Household",
    iconEmoji: "🧼",
    image: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=600&q=85",
    bannerText: "Keep Your Home Sparkling & Fresh",
    products: cleaningProducts,
  ),
  InstantCategoryModel(
    id: "personal_care",
    name: "Personal Care",
    iconEmoji: "🧴",
    image: "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=85",
    bannerText: "Daily Hygiene, Skin Care & Essentials",
    products: personalCareProducts,
  ),
];
