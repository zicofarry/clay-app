package com.clay.core.network.api

import com.clay.core.model.Order
import com.clay.core.model.RideBooking
import retrofit2.http.*

interface RideOrderApi {
    @POST("api/v1/ride/book")
    suspend fun bookRide(@Body request: BookRideRequest): RideBooking

    @GET("api/v1/ride/orders/{id}")
    suspend fun getRideOrder(@Path("id") orderId: String): Order
}

data class BookRideRequest(
    val pickupLat: Double,
    val pickupLng: Double,
    val pickupAddress: String,
    val destLat: Double,
    val destLng: Double,
    val destAddress: String,
    val vehicleType: String,
)

interface FoodOrderApi {
    @GET("api/v1/food/restaurants")
    suspend fun getRestaurants(): List<RestaurantResponse>

    @GET("api/v1/food/restaurants/{id}/menu")
    suspend fun getMenu(@Path("id") restaurantId: String): List<FoodItemResponse>

    @POST("api/v1/food/orders")
    suspend fun placeOrder(@Body request: PlaceFoodOrderRequest): FoodOrderResponse
}

data class RestaurantResponse(val id: String, val name: String, val imageUrl: String, val rating: Double, val category: String)
data class FoodItemResponse(val id: String, val name: String, val price: Int, val description: String, val imageUrl: String)
data class PlaceFoodOrderRequest(val restaurantId: String, val items: List<OrderItemRequest>, val deliveryAddress: String, val notes: String)
data class OrderItemRequest(val menuItemId: String, val quantity: Int)
data class FoodOrderResponse(val id: String, val status: String, val totalPrice: Int)
