package com.clay.app.navigation

import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.clay.core.ui.components.BottomNavItem
import com.clay.core.ui.components.ClayBottomNav
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Receipt
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Receipt
import androidx.compose.material.icons.outlined.Chat
import androidx.compose.material.icons.outlined.Person
import com.clay.feature.auth.LoginScreen
import com.clay.feature.auth.RegisterScreen
import com.clay.feature.auth.OtpScreen

@Composable
fun ClayNavHost() {
    val navController = rememberNavController()
    val currentBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = currentBackStackEntry?.destination?.route

    val bottomNavItems = listOf(
        BottomNavItem("Beranda", Icons.Outlined.Home, Icons.Filled.Home),
        BottomNavItem("Aktivitas", Icons.Outlined.Receipt, Icons.Filled.Receipt),
        BottomNavItem("Pesan", Icons.Outlined.Chat, Icons.Filled.Chat),
        BottomNavItem("Akun", Icons.Outlined.Person, Icons.Filled.Person),
    )

    val showBottomBar = currentRoute in listOf(
        Screen.Home.route, Screen.Activity.route,
        Screen.Chat.route, Screen.Profile.route,
    )

    NavHost(
        navController = navController,
        startDestination = Screen.AuthGraph.route,
    ) {
        composable(Screen.AuthGraph.route) {
            AuthGraph(navController)
        }

        composable(Screen.MainGraph.route) {
            Scaffold(
                bottomBar = {
                    if (showBottomBar) {
                        ClayBottomNav(
                            items = bottomNavItems,
                            selectedIndex = when (currentRoute) {
                                Screen.Home.route -> 0
                                Screen.Activity.route -> 1
                                Screen.Chat.route -> 2
                                Screen.Profile.route -> 3
                                else -> 0
                            },
                            onItemSelected = { index ->
                                val route = when (index) {
                                    0 -> Screen.Home.route
                                    1 -> Screen.Activity.route
                                    2 -> Screen.Chat.route
                                    3 -> Screen.Profile.route
                                    else -> Screen.Home.route
                                }
                                navController.navigate(route) {
                                    popUpTo(Screen.MainGraph.route) { saveState = true }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                        )
                    }
                },
            ) { padding ->
                MainGraph(navController, Modifier.padding(padding))
            }
        }
    }
}

@Composable
private fun AuthGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Screen.Login.route,
        route = Screen.AuthGraph.route,
    ) {
        composable(Screen.Login.route) {
            LoginScreen(
                onNavigateToRegister = { navController.navigate(Screen.Register.route) },
                onLoginSuccess = {
                    navController.navigate(Screen.MainGraph.route) {
                        popUpTo(Screen.AuthGraph.route) { inclusive = true }
                    }
                },
            )
        }
        composable(Screen.Register.route) {
            RegisterScreen(
                onBack = { navController.popBackStack() },
                onRegisterSuccess = { phone ->
                    navController.navigate(Screen.Otp.createRoute(phone))
                },
            )
        }
        composable(
            Screen.Otp.route,
            arguments = listOf(navArgument("phone") { type = NavType.StringType }),
        ) {
            OtpScreen(
                onBack = { navController.popBackStack() },
                onVerifySuccess = {
                    navController.navigate(Screen.MainGraph.route) {
                        popUpTo(Screen.AuthGraph.route) { inclusive = true }
                    }
                },
            )
        }
    }
}

@Composable
private fun MainGraph(navController: NavHostController, modifier: Modifier) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route,
        route = Screen.MainGraph.route,
        modifier = modifier,
    ) {
        composable(Screen.Home.route, enterTransition = { fadeIn() }, exitTransition = { fadeOut() }) {
            com.clay.feature.home.HomeScreen(
                onNavigateToSearch = { navController.navigate(Screen.Search.route) },
                onNavigateToNotifications = { navController.navigate(Screen.Notifications.route) },
                onNavigateToRide = { navController.navigate(Screen.DestinationInput.route) },
                onNavigateToFood = { navController.navigate(Screen.ClayFood.route) },
                onNavigateToSend = { navController.navigate(Screen.ClaySend.route) },
                onNavigateToPet = { navController.navigate(Screen.ClayPet.route) },
                onNavigateToWaste = { navController.navigate(Screen.ClayWaste.route) },
                onNavigateToCare = { navController.navigate(Screen.ClayCare.route) },
                onNavigateToOtherServices = { navController.navigate(Screen.OtherServices.route) },
                onNavigateToWallet = { navController.navigate(Screen.Wallet.route) },
            )
        }

        composable(Screen.Search.route) {
            com.clay.feature.home.SearchScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Notifications.route) {
            com.clay.feature.notifications.NotificationsScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.DestinationInput.route) {
            com.clay.feature.ride.DestinationInputScreen(
                onBack = { navController.popBackStack() },
                onProceed = { navController.navigate(Screen.PickupMap.route) },
            )
        }

        composable(Screen.PickupMap.route) {
            com.clay.feature.ride.PickupMapScreen(
                onBack = { navController.popBackStack() },
                onConfirm = { navController.navigate(Screen.DestinationConfirmation.route) },
            )
        }

        composable(Screen.DestinationConfirmation.route) {
            com.clay.feature.ride.DestinationConfirmationScreen(
                onBack = { navController.popBackStack() },
                onBook = { navController.navigate(Screen.OrderTracking.createRoute("TMP001")) },
            )
        }

        composable(
            Screen.OrderTracking.route,
            arguments = listOf(navArgument("orderId") { type = NavType.StringType }),
        ) {
            com.clay.feature.ride.OrderTrackingScreen(
                onBack = { navController.popBackStack() },
                onComplete = { navController.popBackStack(Screen.Home.route, inclusive = false) },
            )
        }

        composable(Screen.ClayFood.route) {
            com.clay.feature.food.ClayFoodScreen(
                onBack = { navController.popBackStack() },
                onRestaurantClick = { id -> navController.navigate(Screen.FoodDetail.createRoute(id)) },
                onCartClick = { navController.navigate(Screen.Cart.route) },
            )
        }

        composable(
            Screen.FoodDetail.route,
            arguments = listOf(navArgument("restaurantId") { type = NavType.StringType }),
        ) {
            com.clay.feature.food.FoodDetailScreen(
                onBack = { navController.popBackStack() },
                onAddToCart = { navController.popBackStack() },
            )
        }

        composable(Screen.Cart.route) {
            com.clay.feature.food.CartScreen(
                onBack = { navController.popBackStack() },
                onCheckout = { navController.navigate(Screen.Checkout.route) },
            )
        }

        composable(Screen.Checkout.route) {
            com.clay.feature.food.CheckoutScreen(
                onBack = { navController.popBackStack() },
                onOrderPlaced = { navController.popBackStack(Screen.Home.route, inclusive = false) },
            )
        }

        composable(Screen.ClaySend.route) {
            com.clay.feature.send.ClaySendScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.ClayPet.route) {
            com.clay.feature.services.ClayPetScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.ClayWaste.route) {
            com.clay.feature.services.ClayWasteScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.ClayCare.route) {
            com.clay.feature.services.ClayCareScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.OtherServices.route) {
            com.clay.feature.services.OtherServicesScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Activity.route) {
            com.clay.feature.activity.ActivityScreen(
                onBack = { navController.popBackStack() },
                onOrderClick = { /* navigate to order detail */ },
            )
        }

        composable(Screen.Chat.route) {
            com.clay.feature.chat.ChatListScreen(
                onBack = { navController.popBackStack() },
                onConversationClick = { id -> navController.navigate(Screen.ChatDetail.createRoute(id)) },
            )
        }

        composable(
            Screen.ChatDetail.route,
            arguments = listOf(navArgument("conversationId") { type = NavType.StringType }),
        ) {
            com.clay.feature.chat.ChatDetailScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Profile.route) {
            com.clay.feature.profile.ProfileScreen(
                onNavigateToWallet = { navController.navigate(Screen.Wallet.route) },
                onNavigateToVoucher = { navController.navigate(Screen.Voucher.route) },
                onNavigateToSettings = { navController.navigate(Screen.Settings.route) },
                onNavigateToHelp = { navController.navigate(Screen.Help.route) },
            )
        }

        composable(Screen.Wallet.route) {
            com.clay.feature.wallet.WalletScreen(
                onBack = { navController.popBackStack() },
                onTopUp = { navController.navigate(Screen.TopUp.route) },
                onVoucher = { navController.navigate(Screen.Voucher.route) },
            )
        }

        composable(Screen.TopUp.route) {
            com.clay.feature.wallet.TopUpScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Voucher.route) {
            com.clay.feature.wallet.VoucherScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Settings.route) {
            com.clay.feature.profile.SettingsScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Help.route) {
            com.clay.feature.profile.HelpScreen(onBack = { navController.popBackStack() })
        }
    }
}
