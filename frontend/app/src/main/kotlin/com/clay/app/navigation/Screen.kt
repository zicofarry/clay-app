package com.clay.app.navigation

sealed class Screen(val route: String) {
    data object AuthGraph : Screen("auth")
    data object MainGraph : Screen("main")

    data object Login : Screen("login")
    data object Register : Screen("register")
    data object Otp : Screen("otp/{phone}") {
        fun createRoute(phone: String) = "otp/$phone"
    }

    data object Home : Screen("home")
    data object Search : Screen("search")
    data object Notifications : Screen("notifications")

    data object DestinationInput : Screen("ride/destination")
    data object PickupMap : Screen("ride/pickup")
    data object DestinationConfirmation : Screen("ride/confirm")
    data object OrderTracking : Screen("ride/tracking/{orderId}") {
        fun createRoute(orderId: String) = "ride/tracking/$orderId"
    }

    data object ClayFood : Screen("food")
    data object FoodDetail : Screen("food/detail/{restaurantId}") {
        fun createRoute(restaurantId: String) = "food/detail/$restaurantId"
    }
    data object Cart : Screen("food/cart")
    data object Checkout : Screen("food/checkout")

    data object ClaySend : Screen("send")
    data object ClayPet : Screen("pet")
    data object ClayWaste : Screen("waste")
    data object ClayCare : Screen("care")
    data object OtherServices : Screen("services/other")

    data object Profile : Screen("profile")
    data object Activity : Screen("activity")
    data object Chat : Screen("chat")
    data object ChatDetail : Screen("chat/{conversationId}") {
        fun createRoute(conversationId: String) = "chat/$conversationId"
    }
    data object Wallet : Screen("wallet")
    data object TopUp : Screen("wallet/topup")
    data object Voucher : Screen("wallet/voucher")
    data object Settings : Screen("settings")
    data object Help : Screen("help")
}
