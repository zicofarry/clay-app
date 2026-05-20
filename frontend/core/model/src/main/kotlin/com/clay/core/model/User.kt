package com.clay.core.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class User(
    val id: String,
    val name: String,
    val email: String,
    val phone: String,
    val avatarUrl: String? = null,
    val role: UserRole = UserRole.CONSUMER,
    val referralCode: String? = null,
    val isPhoneVerified: Boolean = false,
    val isEmailVerified: Boolean = false,
)

enum class UserRole {
    CONSUMER, DRIVER, MERCHANT, ADMIN
}

@JsonClass(generateAdapter = true)
data class Address(
    val id: String,
    val label: String,
    val fullAddress: String,
    val latitude: Double,
    val longitude: Double,
    val isDefault: Boolean = false,
    val type: AddressType = AddressType.OTHER,
)

enum class AddressType {
    HOME, OFFICE, OTHER
}

@JsonClass(generateAdapter = true)
data class DriverProfile(
    val id: String,
    val userId: String,
    val name: String,
    val phone: String,
    val vehicleType: String,
    val vehiclePlate: String,
    val isVerified: Boolean = false,
    val rating: Double = 0.0,
    val totalTrips: Int = 0,
    val totalHours: Int = 0,
    val isOnline: Boolean = false,
)
