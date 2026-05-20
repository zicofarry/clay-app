package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.*
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface FoodRepository {
    suspend fun getCategories(): Result<List<FoodCategory>>
    suspend fun getRestaurants(): Result<List<Restaurant>>
    suspend fun getRestaurantMenu(restaurantId: String): Result<List<FoodItem>>
}

@Singleton
class FoodRepositoryImpl @Inject constructor() : FoodRepository {

    private val categories = listOf(
        FoodCategory("CAT1", "Promo", "🔥"),
        FoodCategory("CAT2", "Nasi", "🍚"),
        FoodCategory("CAT3", "Mie", "🍜"),
        FoodCategory("CAT4", "Ayam", "🍗"),
        FoodCategory("CAT5", "Minuman", "🥤"),
    )

    private val restaurants = listOf(
        Restaurant("R001", "Warung Nusantara", "https://picsum.photos/seed/food1/200", 4.8, "Nasi", "25-35 min", "1.2 km", true),
        Restaurant("R002", "Bakso Akbar", "https://picsum.photos/seed/food2/200", 4.7, "Mie", "20-30 min", "0.8 km", true),
        Restaurant("R003", "Ayam Gepuk Sari", "https://picsum.photos/seed/food3/200", 4.9, "Ayam", "30-40 min", "1.5 km"),
        Restaurant("R004", "Sate Khas Senayan", "https://picsum.photos/seed/food4/200", 4.6, "Sate", "25-35 min", "2.0 km"),
        Restaurant("R005", "Es Teh Indonesia", "https://picsum.photos/seed/food5/200", 4.5, "Minuman", "10-15 min", "0.5 km"),
    )

    override suspend fun getCategories(): Result<List<FoodCategory>> {
        delay(300)
        return Result.Success(categories)
    }

    override suspend fun getRestaurants(): Result<List<Restaurant>> {
        delay(500)
        return Result.Success(restaurants)
    }

    override suspend fun getRestaurantMenu(restaurantId: String): Result<List<FoodItem>> {
        delay(500)
        return Result.Success(
            listOf(
                FoodItem("F001", "Nasi Goreng Spesial", "Nasi goreng dengan topping ayam, udang, dan telur", 45000, "https://picsum.photos/seed/nasgor/200", 4.8),
                FoodItem("F002", "Mie Ayam Bakso", "Mie ayam dengan bakso sapi dan pangsit", 35000, "https://picsum.photos/seed/mieayam/200", 4.7),
                FoodItem("F003", "Ayam Geprek", "Ayam geprek sambal bawang dengan lalapan", 28000, "https://picsum.photos/seed/geprek/200", 4.9),
                FoodItem("F004", "Es Teh Manis", "Es teh manis segar", 5000, "https://picsum.photos/seed/esteh/200", 4.5),
            )
        )
    }
}
