package com.clay.feature.food

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CheckoutScreen(
    onBack: () -> Unit,
    onOrderPlaced: () -> Unit,
) {
    var showSuccess by remember { mutableStateOf(false) }
    var selectedPayment by remember { mutableIntStateOf(0) }

    if (showSuccess) {
        Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(32.dp)) {
                Icon(Icons.Default.CheckCircle, contentDescription = null, tint = Green500, modifier = Modifier.size(80.dp))
                Spacer(Modifier.height(16.dp))
                Text("Pesanan Berhasil!", fontWeight = FontWeight.Bold, fontSize = 24.sp)
                Spacer(Modifier.height(8.dp))
                Text("Pesananmu sedang diproses", color = Grey500)
                Spacer(Modifier.height(24.dp))
                Button(onClick = onOrderPlaced, modifier = Modifier.fillMaxWidth().height(52.dp), shape = RoundedCornerShape(12.dp)) {
                    Text("Kembali ke Beranda")
                }
            }
        }
        return
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Checkout", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) {
                        Text("Total", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text("Rp57.000", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = ClayPrimary)
                    }
                    Spacer(Modifier.height(8.dp))
                    Button(
                        onClick = { showSuccess = true },
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Text("Buat Pesanan", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp),
        ) {
            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(8.dp))
                        Text("Alamat Pengiriman", fontWeight = FontWeight.SemiBold)
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Jl. Merdeka No. 10, Jakarta Pusat", fontWeight = FontWeight.Medium)
                    Text("Raffi Ahmad • 08123456789", style = MaterialTheme.typography.bodySmall, color = Grey500)
                }
            }

            Spacer(Modifier.height(12.dp))

            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Schedule, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(8.dp))
                        Text("Waktu Pengiriman", fontWeight = FontWeight.SemiBold)
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Sekitar 25-35 menit • Sekarang")
                }
            }

            Spacer(Modifier.height(12.dp))

            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.ShoppingCart, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(8.dp))
                        Text("Pesanan", fontWeight = FontWeight.SemiBold)
                    }
                    Spacer(Modifier.height(8.dp))
                    listOf("Nasi Goreng Spesial x2" to 90000, "Es Teh Manis x1" to 5000).forEach { (name, price) ->
                        Row(Modifier.fillMaxWidth().padding(vertical = 4.dp)) {
                            Text(name, modifier = Modifier.weight(1f))
                            Text("Rp$price", fontWeight = FontWeight.Medium)
                        }
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Payment, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(8.dp))
                        Text("Metode Pembayaran", fontWeight = FontWeight.SemiBold)
                    }
                    Spacer(Modifier.height(8.dp))
                    listOf("ClayPay (Saldo: Rp2.500.000)", "BCA Virtual Account", "Mandiri Virtual Account").forEachIndexed { index, method ->
                        Row(
                            modifier = Modifier.fillMaxWidth().clickable { selectedPayment = index }.padding(vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            RadioButton(selected = selectedPayment == index, onClick = { selectedPayment = index })
                            Spacer(Modifier.width(8.dp))
                            Text(method)
                        }
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Ringkasan Pembayaran", fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(8.dp))
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Subtotal", color = Grey500); Text("Rp95.000") }
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Ongkos kirim", color = Grey500); Text("Rp7.000") }
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Biaya layanan", color = Grey500); Text("Rp2.000") }
                    HorizontalDivider(Modifier.padding(vertical = 4.dp))
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Total", fontWeight = FontWeight.Bold); Text("Rp104.000", fontWeight = FontWeight.Bold, color = ClayPrimary) }
                }
            }

            Spacer(Modifier.height(80.dp))
        }
    }
}
