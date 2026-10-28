import 'package:flutter/material.dart';

class SubCategoryItem {
  final String title;
  final String image;
  final String? route;

  const SubCategoryItem({
    required this.title,
    required this.image,
    this.route,
  });
}

class SubCategorySection {
  final String sectionTitle;
  final String? superCategoryTitle;
  final List<SubCategoryItem> items;

  const SubCategorySection({
    required this.sectionTitle,
    this.superCategoryTitle,
    required this.items,
  });
}

class QuickCategoryItem {
  final String title;
  final String image;
  final String? route;

  const QuickCategoryItem({
    required this.title,
    required this.image,
    this.route,
  });
}

class MainCategory {
  final String id;
  final String title;
  final String image;
  final IconData? fallbackIcon;
  final List<QuickCategoryItem> quickItems;
  final List<SubCategorySection> sections;

  const MainCategory({
    required this.id,
    required this.title,
    required this.image,
    this.fallbackIcon,
    this.quickItems = const [],
    required this.sections,
  });
}

final List<MainCategory> demoDiscoverCategories = [
  // 1. Popular
  const MainCategory(
    id: "popular",
    title: "Popular",
    image: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.star_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Top Deals",
        image: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "New In",
        image: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Trending Categories",
        items: [
          SubCategoryItem(
            title: "Western Dresses",
            image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Designer Sarees",
            image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Casual T-Shirts",
            image: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Sports Sneakers",
            image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Smartwatches",
            image: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Handbags & Totes",
            image: "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "SPECIAL PICKS",
        sectionTitle: "Best Sellers",
        items: [
          SubCategoryItem(
            title: "Gold Plated Sets",
            image: "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Perfumes & Mist",
            image: "https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Wireless Audio",
            image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 2. Kurti, Saree & Lehenga
  const MainCategory(
    id: "ethnic",
    title: "Kurti, Saree &\nLehenga",
    image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.checkroom_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "All Sarees",
        image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "All Kurtis",
        image: "https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Women Ethnic Wear",
        items: [
          SubCategoryItem(
            title: "All Kurtis",
            image: "https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Silk Sarees",
            image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Lehenga Choli",
            image: "https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Anarkali Suits",
            image: "https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Dupattas & Shawls",
            image: "https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Ethnic Palazzos",
            image: "https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "WEDDING & FESTIVE",
        sectionTitle: "Festive Collection",
        items: [
          SubCategoryItem(
            title: "Bridal Lehengas",
            image: "https://images.unsplash.com/photo-1594824813579-450fdfca0b78?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Embroidered Gowns",
            image: "https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Chanderi Sets",
            image: "https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 3. Women Western
  const MainCategory(
    id: "western",
    title: "Women\nWestern",
    image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.dry_cleaning_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Dresses",
        image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Tops & Tees",
        image: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Western Wear",
        items: [
          SubCategoryItem(
            title: "Tops & Shirts",
            image: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Maxi & Mini Dresses",
            image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Jeans & Jeggings",
            image: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Jackets & Shrugs",
            image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Co-ord Sets",
            image: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Trousers & Skirts",
            image: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "CASUAL & LOUNGE",
        sectionTitle: "Activewear & Loungewear",
        items: [
          SubCategoryItem(
            title: "Gym Tights",
            image: "https://images.unsplash.com/photo-1506152983158-b4a74a01c721?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Sports Bras",
            image: "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Hoodies & Sweats",
            image: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 4. Lingerie
  const MainCategory(
    id: "lingerie",
    title: "Lingerie",
    image: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.favorite_border_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Bras",
        image: "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Nightwear",
        image: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Innerwear & Sleepwear",
        items: [
          SubCategoryItem(
            title: "Padded Bras",
            image: "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Panties & Briefs",
            image: "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Nightdresses",
            image: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Satin Pyjamas",
            image: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Shapewear",
            image: "https://images.unsplash.com/photo-1506152983158-b4a74a01c721?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Camisoles",
            image: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 5. Men
  const MainCategory(
    id: "men",
    title: "Men",
    image: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.person_outline_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "T-Shirts",
        image: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Shirts",
        image: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Men's Topwear",
        items: [
          SubCategoryItem(
            title: "T-Shirts & Polos",
            image: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Casual Shirts",
            image: "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Formal Shirts",
            image: "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Jackets & Hoodies",
            image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Ethnic Kurtas",
            image: "https://images.unsplash.com/photo-1597983073493-88cd35cf93b0?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Sweaters & Cardigans",
            image: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "BOTTOMWEAR & ACCESSORIES",
        sectionTitle: "Bottomwear & Shoes",
        items: [
          SubCategoryItem(
            title: "Slim Jeans",
            image: "https://images.unsplash.com/photo-1542272604-780c96856592?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Casual Trousers",
            image: "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Men Sneakers",
            image: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 6. Kids & Toys
  const MainCategory(
    id: "kids",
    title: "Kids & Toys",
    image: "https://images.unsplash.com/photo-1559454403-b8fb88521f11?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.child_care_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Boys Clothing",
        image: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Girls Clothing",
        image: "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Kids Fashion",
        items: [
          SubCategoryItem(
            title: "Boys T-Shirts",
            image: "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Girls Frocks & Dresses",
            image: "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Infant Baby Suits",
            image: "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Kids Footwear",
            image: "https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Soft Plush Toys",
            image: "https://images.unsplash.com/photo-1559454403-b8fb88521f11?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Games & Puzzles",
            image: "https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 7. Home & Kitchen
  const MainCategory(
    id: "home",
    title: "Home &\nKitchen",
    image: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.home_outlined,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1584990347449-39906660f723?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Cookware",
        image: "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Home Decor",
        image: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Kitchen & Dining",
        items: [
          SubCategoryItem(
            title: "Non-Stick Cookware",
            image: "https://images.unsplash.com/photo-1584990347449-39906660f723?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Kitchen Appliances",
            image: "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Storage Containers",
            image: "https://images.unsplash.com/photo-1584990347449-39906660f723?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Bedsheets & Covers",
            image: "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Wall Clocks & Art",
            image: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Curtains & Blinds",
            image: "https://images.unsplash.com/photo-1507652313519-d4e9174996dd?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 8. Beauty & Health (EXACT MATCH WITH REFERENCE IMAGE 1)
  const MainCategory(
    id: "beauty",
    title: "Beauty &\nHealth",
    image: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.spa_outlined,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Baby Care\nEssentials",
        image: "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Mom Care",
        image: "https://images.unsplash.com/photo-1544816155-12df9643f363?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Men's Care",
        items: [
          SubCategoryItem(
            title: "Trimmers",
            image: "https://images.unsplash.com/photo-1621607512214-68297480165e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Beard Oil",
            image: "https://images.unsplash.com/photo-1626285861696-9f0bf5a49c6d?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Men Perfumes &\nDeodorant",
            image: "https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Hair Gels, Wax\n& Spray",
            image: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Men's Face &\nBody Care",
            image: "https://images.unsplash.com/photo-1556228722-d0b5d038318e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Budget Grooming\nKits",
            image: "https://images.unsplash.com/photo-1503249023995-51b0f3778ccf?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "JEWELLERY & ACCESSORIES",
        sectionTitle: "Jewellery",
        items: [
          SubCategoryItem(
            title: "All Jewellery",
            image: "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Jewellery Sets",
            image: "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Earrings",
            image: "https://images.unsplash.com/photo-1630019852942-f89202989a59?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Mangalsutras",
            image: "https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Necklaces &\nChains",
            image: "https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Bangles &\nBracelets",
            image: "https://images.unsplash.com/photo-1611591475852-c3f25d9c2288?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Anklets &\nNosepins",
            image: "https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Kamarbandh &\nBelts",
            image: "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
      SubCategorySection(
        superCategoryTitle: "SKIN & MAKEUP",
        sectionTitle: "Women's Skincare",
        items: [
          SubCategoryItem(
            title: "Lipsticks & Lip Gloss",
            image: "https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Face Serums",
            image: "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Sunscreen & Lotions",
            image: "https://images.unsplash.com/photo-1556228722-d0b5d038318e?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 9. Bags & Footwear
  const MainCategory(
    id: "footwear",
    title: "Footwear &\nBags",
    image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.shopping_bag_outlined,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Sneakers",
        image: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Handbags",
        image: "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Footwear Collection",
        items: [
          SubCategoryItem(
            title: "Running Shoes",
            image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Women's Heels",
            image: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Flats & Sandals",
            image: "https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Casual Backpacks",
            image: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Leather Wallets",
            image: "https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Travel Luggage",
            image: "https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),

  // 10. Electronics & Gadgets
  const MainCategory(
    id: "electronics",
    title: "Electronics &\nGadgets",
    image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80",
    fallbackIcon: Icons.headphones_rounded,
    quickItems: [
      QuickCategoryItem(
        title: "View All",
        image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Smartwatches",
        image: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80",
      ),
      QuickCategoryItem(
        title: "Earbuds",
        image: "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&auto=format&fit=crop&q=80",
      ),
    ],
    sections: [
      SubCategorySection(
        sectionTitle: "Audio & Smart Devices",
        items: [
          SubCategoryItem(
            title: "Bluetooth Earbuds",
            image: "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Over-Ear Headphones",
            image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Smart Fitness Bands",
            image: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Portable Speakers",
            image: "https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Power Banks & Cables",
            image: "https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&auto=format&fit=crop&q=80",
          ),
          SubCategoryItem(
            title: "Designer Cases",
            image: "https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400&auto=format&fit=crop&q=80",
          ),
        ],
      ),
    ],
  ),
];
