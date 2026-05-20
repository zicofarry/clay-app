package com.clay.feature.food

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClayFoodScreen(
    onBack: () -> Unit,
    onRestaurantClick: (String) -> Unit,
    onCartClick: () -> Unit,
) {
    val categories = listOf("Promo 🔥", "Nasi 🍚", "Mie 🍜", "Ayam 🍗", "Minuman 🥤", "Sate 🍢")
    val restaurants = listOf(
        listOf("Warung Nusantara", "4.8", "Nasi • 25-35 min", "1.2 km", true),
        listOf("Bakso Akbar", "4.7", "Mie • 20-30 min", "0.8 km", true),
        listOf("Ayam Gepuk Sari", "4.9", "Ayam • 30-40 min", "1.5 km"),
        listOf("Sate Khas Senayan", "4.6", "Sate • 25-35 min", "2.0 km"),
        listOf("Es Teh Indonesia", "4.5", "Minuman • 10-15 min", "0.5 km"),
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("ClayFood", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    BadgedBox(badge = { Badge { Text("3") } }) {
                        IconButton(onClick = onCartClick) {
                            Icon(Icons.Default.ShoppingCart, contentDescription = "Cart")
                        }
                    }
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                categories.forEach { cat ->
                    FilterChip(
                        selected = cat == categories[0],
                        onClick = {},
                        label = { Text(cat) },
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                Text("Promo Spesial", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
                Spacer(Modifier.height(12.dp))

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Orange50),
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(Icons.Default.LocalOffer, contentDescription = null, tint = Orange500, modifier = Modifier.size(32.dp))
                        Spacer(Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Gratis Ongkir + Diskon 25%", fontWeight = FontWeight.Bold)
                            Text("Untuk pesanan pertama ClayFood", style = MaterialTheme.typography.bodySmall, color = Grey600)
                        }
                    }
                }

                Spacer(Modifier.height(20.dp))

                Text("Restoran Terdekat", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
                Spacer(Modifier.height(12.dp))

                restaurants.forEachIndexed { index, r ->
                    Card(
                        modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp).clickable { onRestaurantClick("R00${index + 1}") },
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Row(modifier = Modifier.padding(12.dp)) {
                            Box(
                                modifier = Modifier.size(72.dp).clip(RoundedCornerShape(12.dp)).background(Grey200),
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(Icons.Default.Restaurant, contentDescription = null, tint = Grey400)
                            }
                            Spacer(Modifier.width(12.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(r[0] as String, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
                                    if (r.size > 4 && r[4] == true) {
                                        Badge { Text("Promo") }
                                    }
                                }
                                Spacer(Modifier.height(4.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.Star, contentDescription = null, tint = Orange500, modifier = Modifier.size(14.dp))
                                    Spacer(Modifier.width(4.dp))
                                    Text(r[1] as String, fontWeight = FontWeight.Medium, fontSize = 13.sp)
                                    Spacer(Modifier.width(8.dp))
                                    Text(r[2] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                                }
                                Spacer(Modifier.height(2.dp))
                                Text(r[3] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}
