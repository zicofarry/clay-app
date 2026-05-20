package com.clay.feature.wallet

import androidx.compose.foundation.background
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
fun VoucherScreen(onBack: () -> Unit) {
    var promoCode by remember { mutableStateOf("") }
    var selectedTab by remember { mutableIntStateOf(0) }

    val vouchers = listOf(
        listOf("CLAYFOOD50", "Diskon 50% ClayFood", "max Rp25.000 • s/d 30 Jun 2025"),
        listOf("RIDE25", "Potongan Rp25.000 ClayRide", "min Rp75.000 • s/d 15 Jun 2025"),
        listOf("NEWUSER20", "Diskon 20%", "max Rp20.000 • s/d 1 Jul 2025"),
        listOf("SEND10", "Gratis ongkir ClaySend", "max Rp10.000 • s/d 20 Jun 2025"),
        listOf("WEEKEND50", "Diskon 50% akhir pekan", "max Rp50.000 • s/d 25 Jun 2025"),
    )

    Scaffold(
        topBar = { TopAppBar(title = { Text("Voucher", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            OutlinedTextField(
                value = promoCode,
                onValueChange = { promoCode = it },
                placeholder = { Text("Masukkan kode promo") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                trailingIcon = { TextButton(enabled = promoCode.isNotBlank()) { Text("Pakai") } },
            )

            Spacer(Modifier.height(16.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("Tersedia", "Digunakan").forEachIndexed { index, tab ->
                    FilterChip(selected = selectedTab == index, onClick = { selectedTab = index }, label = { Text(tab) })
                }
            }

            Spacer(Modifier.height(16.dp))

            vouchers.forEach { voucher ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = Blue50),
                ) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(48.dp).background(ClayPrimary, RoundedCornerShape(12.dp)), contentAlignment = Alignment.Center) {
                            Text("%", color = MaterialTheme.colorScheme.onPrimary, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                        }
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(voucher[0] as String, fontWeight = FontWeight.Bold)
                            Text(voucher[1] as String, style = MaterialTheme.typography.bodySmall)
                            Text(voucher[2] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                        }
                        OutlinedButton(onClick = {}, shape = RoundedCornerShape(8.dp), contentPadding = PaddingValues(horizontal = 12.dp)) {
                            Text("Klaim")
                        }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}
