package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.*
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface OrderRepository {
    suspend fun bookRide(pickup: String, destination: String, vehicleType: VehicleType): Result<RideBooking>
    suspend fun getOrderHistory(): Result<List<Order>>
    suspend fun getActiveOrder(): Result<Order?>
}

@Singleton
class OrderRepositoryImpl @Inject constructor() : OrderRepository {

    override suspend fun bookRide(pickup: String, destination: String, vehicleType: VehicleType): Result<RideBooking> {
        delay(1000)
        val prices = mapOf(VehicleType.EKONOMI to 25000, VehicleType.PLUS to 45000, VehicleType.LUX to 95000)
        val durations = mapOf(VehicleType.EKONOMI to "15 menit", VehicleType.PLUS to "12 menit", VehicleType.LUX to "10 menit")
        return Result.Success(
            RideBooking(
                pickup = pickup,
                destination = destination,
                vehicleType = vehicleType,
                estimatedPrice = prices[vehicleType] ?: 25000,
                estimatedDuration = durations[vehicleType] ?: "15 menit",
            )
        )
    }

    override suspend fun getOrderHistory(): Result<List<Order>> = Result.Success(
        listOf(
            Order("ORD001", ServiceType.RIDE, OrderStatus.COMPLETED, "Jl. Merdeka No. 10", "Mall Kelapa Gading", "2025-05-19 14:30", "Budi Santoso", 4.9, "Toyota Avanza B 1234 CD", null, 25000, 25000, 5),
            Order("ORD002", ServiceType.FOOD, OrderStatus.DELIVERED, "Warung Nusantara", null, "2025-05-19 13:00"),
            Order("ORD003", ServiceType.RIDE, OrderStatus.COMPLETED, "Kantor", "Senayan City", "2025-05-18 09:15", "Ahmad Rizki", 4.8, "Honda Brio B 5678 EF", null, 35000, 35000, 4),
            Order("ORD004", ServiceType.SEND, OrderStatus.COMPLETED, "Rumah", "Kantor", "2025-05-17 10:00"),
            Order("ORD005", ServiceType.RIDE, OrderStatus.COMPLETED, "Grand Indonesia", "Rumah", "2025-05-16 20:00", "Dewi Lestari", 4.9, "Daihatsu Sigra B 9012 GH", null, 30000, 30000, 5),
            Order("ORD006", ServiceType.PET, OrderStatus.COMPLETED, "PetShop Happy", null, "2025-05-15 11:30"),
            Order("ORD007", ServiceType.CARE, OrderStatus.COMPLETED, "RS Siloam", null, "2025-05-14 08:00"),
        )
    )

    override suspend fun getActiveOrder(): Result<Order?> = Result.Success(null)
}
