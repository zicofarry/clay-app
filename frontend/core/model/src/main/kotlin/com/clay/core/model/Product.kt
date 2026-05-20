package com.clay.core.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Restaurant(
    val id: String,
    val name: String,
    val imageUrl: String,
    val rating: Double,
    val category: String,
    val estimatedTime: String,
    val distance: String,
    val isPromo: Boolean = false,
)

@JsonClass(generateAdapter = true)
data class FoodItem(
    val id: String,
    val name: String,
    val description: String,
    val price: Int,
    val imageUrl: String,
    val rating: Double = 0.0,
    val categoryId: String? = null,
    val addOns: List<FoodAddOn> = emptyList(),
    val isAvailable: Boolean = true,
)

@JsonClass(generateAdapter = true)
data class FoodAddOn(
    val id: String,
    val name: String,
    val price: Int,
    val isRequired: Boolean = false,
    val maxSelect: Int = 1,
    val options: List<AddOnOption> = emptyList(),
)

@JsonClass(generateAdapter = true)
data class AddOnOption(
    val id: String,
    val name: String,
    val price: Int = 0,
)

@JsonClass(generateAdapter = true)
data class CartItem(
    val foodItem: FoodItem,
    val quantity: Int = 1,
    val selectedAddOns: List<AddOnOption> = emptyList(),
    val notes: String = "",
) {
    val totalPrice: Int get() = (foodItem.price + selectedAddOns.sumOf { it.price }) * quantity
}

@JsonClass(generateAdapter = true)
data class FoodCategory(
    val id: String,
    val name: String,
    val icon: String,
)
