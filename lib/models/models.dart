class AuthUser {
  AuthUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.roleName,
    required this.token,
  });

  final int userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String roleName;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        roleName: json['roleName'],
        token: json['token'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'roleName': roleName,
        'token': token,
      };
}

class Category {
  Category({required this.categoryId, required this.name, this.description});

  final int categoryId;
  final String name;
  final String? description;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json['categoryId'],
        name: json['name'],
        description: json['description'],
      );
}

class Product {
  Product({
    required this.productId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.unitInStock,
    this.picture,
    required this.categoryId,
    required this.categoryName,
    required this.isAvailable,
  });

  final int productId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final int unitInStock;
  final String? picture;
  final int categoryId;
  final String categoryName;
  final bool isAvailable;

  double get displayPrice => discountPrice ?? price;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json['productId'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        discountPrice: (json['discountPrice'] as num?)?.toDouble(),
        unitInStock: json['unitInStock'],
        picture: json['picture'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        isAvailable: json['isAvailable'],
      );
}

class Cat {
  Cat({
    required this.catId,
    required this.name,
    this.age,
    this.genderName,
    this.breed,
    this.picture,
    this.description,
    this.friendlinessRating,
    this.cutenessRating,
    this.playfulnessRating,
    required this.statusName,
  });

  final int catId;
  final String name;
  final int? age;
  final String? genderName;
  final String? breed;
  final String? picture;
  final String? description;
  final int? friendlinessRating;
  final int? cutenessRating;
  final int? playfulnessRating;
  final String statusName;

  factory Cat.fromJson(Map<String, dynamic> json) => Cat(
        catId: json['catId'],
        name: json['name'],
        age: json['age'],
        genderName: json['genderName'],
        breed: json['breed'],
        picture: json['picture'],
        description: json['description'],
        friendlinessRating: json['friendlinessRating'],
        cutenessRating: json['cutenessRating'],
        playfulnessRating: json['playfulnessRating'],
        statusName: json['statusName'],
      );
}

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;
  double get subtotal => product.displayPrice * quantity;
}

class CafeTable {
  CafeTable({
    required this.tableId,
    required this.tableName,
    required this.capacity,
    this.area,
    this.description,
    required this.statusName,
  });

  final int tableId;
  final String tableName;
  final int capacity;
  final String? area;
  final String? description;
  final String statusName;

  factory CafeTable.fromJson(Map<String, dynamic> json) => CafeTable(
        tableId: json['tableId'],
        tableName: json['tableName'],
        capacity: json['capacity'],
        area: json['area'],
        description: json['description'],
        statusName: json['statusName'],
      );
}

class Reservation {
  Reservation({
    required this.reservationId,
    this.userId,
    required this.date,
    required this.time,
    required this.guestName,
    required this.guestPhoneNumber,
    required this.numberOfGuests,
    this.note,
    required this.statusName,
    required this.tableId,
    required this.tableName,
  });

  final int reservationId;
  final int? userId;
  final String date;
  final String time;
  final String guestName;
  final String guestPhoneNumber;
  final int numberOfGuests;
  final String? note;
  final String statusName;
  final int tableId;
  final String tableName;

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        reservationId: json['reservationId'],
        userId: json['userId'],
        date: json['date'],
        time: json['time'],
        guestName: json['guestName'],
        guestPhoneNumber: json['guestPhoneNumber'],
        numberOfGuests: json['numberOfGuests'],
        note: json['note'],
        statusName: json['statusName'],
        tableId: json['tableId'],
        tableName: json['tableName'],
      );
}

class AppNotification {
  AppNotification({
    required this.notificationId,
    this.userId,
    required this.title,
    required this.content,
    this.type,
    required this.isRead,
    required this.createdAt,
  });

  final int notificationId;
  final int? userId;
  final String title;
  final String content;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        notificationId: json['notificationId'],
        userId: json['userId'],
        title: json['title'],
        content: json['content'],
        type: json['type'],
        isRead: json['isRead'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class StoreLocation {
  StoreLocation({
    required this.storeName,
    required this.address,
    this.phoneNumber,
    this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  final String storeName;
  final String address;
  final String? phoneNumber;
  final String? openingHours;
  final double latitude;
  final double longitude;

  factory StoreLocation.fromJson(Map<String, dynamic> json) => StoreLocation(
        storeName: json['storeName'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        openingHours: json['openingHours'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

class Conversation {
  Conversation({required this.conversationId, required this.userId});

  final int conversationId;
  final int userId;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        conversationId: json['conversationId'],
        userId: json['userId'],
      );
}

class ChatMessage {
  ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderUserId,
    required this.sender,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  final int messageId;
  final int conversationId;
  final int senderUserId;
  final String sender;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageId: json['messageId'],
        conversationId: json['conversationId'],
        senderUserId: json['senderUserId'],
        sender: json['sender'],
        content: json['content'],
        isRead: json['isRead'],
        sentAt: DateTime.parse(json['sentAt']),
      );
}
