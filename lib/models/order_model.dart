import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class OrderModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double deliveryFee;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String deliveryCity;
  final String postalCode;
  final String? additionalInfo;
  final GeoPoint deliveryLocation;
  final String status;
  final DateTime createdAt;
  final String artisanId;
  final List<String> productIds;
  final List<String> artisanIds;

  OrderModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.deliveryFee,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.postalCode,
    this.additionalInfo,
    required this.deliveryLocation,
    required this.status,
    required this.createdAt,
    required this.artisanId,
    required this.productIds,
    required this.artisanIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'deliveryCity': deliveryCity,
      'postalCode': postalCode,
      'additionalInfo': additionalInfo,
      'deliveryLocation': deliveryLocation,
      'status': status,
      'createdAt': createdAt,
      'artisanId': artisanId,
      'productIds': productIds,
      'artisanIds': artisanIds,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryCity: map['deliveryCity'] ?? '',
      postalCode: map['postalCode'] ?? '',
      additionalInfo: map['additionalInfo'],
      deliveryLocation: map['deliveryLocation'] as GeoPoint,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      artisanId: map['artisanId'] ?? '',
      productIds: List<String>.from(map['productIds'] ?? []),
      artisanIds: List<String>.from(map['artisanIds'] ?? []),
    );
  }
}
