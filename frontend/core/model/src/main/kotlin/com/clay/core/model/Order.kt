package com.clay.core.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Order(
    val id: String,
    val type: ServiceType,
    val status: OrderStatus,
    val pickupAddress: String,
    val destinationAddress: String? = null,
    val createdAt: String,
    val driverName: String? = null,
    val driverRating: Double? = null,
    val vehicleInfo: String? = null,
    val estimatedTime: String? = null,
    val estimatedPrice: Int? = null,
    val finalPrice: Int? = null,
    val rating: Int? = null,
)

@JsonClass(generateAdapter = true)
data class RideBooking(
    val pickup: String,
    val destination: String,
    val vehicleType: VehicleType,
    val estimatedPrice: Int,
    val estimatedDuration: String,
)

@JsonClass(generateAdapter = true)
data class FoodOrder(
    val id: String,
    val restaurantName: String,
    val items: List<CartItem>,
    val totalPrice: Int,
    val deliveryFee: Int,
    val estimatedTime: String,
    val status: OrderStatus,
)

enum class OrderStatus {
    PENDING, CONFIRMED, PICKING_UP, IN_TRANSIT, DELIVERED, COMPLETED, CANCELLED
}

enum class VehicleType {
    EKONOMI, PLUS, LUX
}

enum class ServiceType {
    RIDE, FOOD, SEND, PET, WASTE, CARE
}
