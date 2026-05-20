package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.*
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface ServicesRepository {
    suspend fun getPromotions(): Result<List<Promotion>>
    suspend fun getNotifications(): Result<List<NotificationItem>>
    suspend fun getConversations(): Result<List<Conversation>>
    suspend fun getMessages(conversationId: String): Result<List<ChatMessage>>
}

@Singleton
class ServicesRepositoryImpl @Inject constructor() : ServicesRepository {

    override suspend fun getPromotions(): Result<List<Promotion>> = Result.Success(
        listOf(
            Promotion("P001", "PayDay Sale!", "Diskon 50% semua layanan Clay", discountPercent = 50, maxDiscount = 50000, validUntil = "2025-06-30"),
            Promotion("P002", "ClayFood Festival", "Gratis ongkir + diskon 25%", discountPercent = 25, validUntil = "2025-06-15"),
            Promotion("P003", "Weekend Special", "ClayRide diskon 30% setiap weekend", discountPercent = 30, maxDiscount = 30000),
        )
    )

    override suspend fun getNotifications(): Result<List<NotificationItem>> = Result.Success(
        listOf(
            NotificationItem("N001", "Promo PayDay!", "Dapatkan diskon 50% semua layanan", NotificationType.PROMO, createdAt = "2025-05-20 08:00"),
            NotificationItem("N002", "Pesanan Selesai", "ClayRide Anda telah selesai. Beri rating!", NotificationType.ORDER, createdAt = "2025-05-19 15:00"),
            NotificationItem("N003", "Pembayaran Berhasil", "Top Up Rp500.000 berhasil", NotificationType.PAYMENT, true, "2025-05-19 10:30"),
            NotificationItem("N004", "Promo ClayFood", "Gratis ongkir + diskon 25%", NotificationType.PROMO, true, "2025-05-18 12:00"),
            NotificationItem("N005", "Peringatan", "Saldo Anda tinggal Rp25.000", NotificationType.PAYMENT, createdAt = "2025-05-18 09:00"),
            NotificationItem("N006", "Pesanan Baru", "Pesanan ClayFood sedang diproses", NotificationType.ORDER, true, "2025-05-17 13:30"),
            NotificationItem("N007", "Promo Weekend", "ClayRide diskon 30%", NotificationType.PROMO, true, "2025-05-16 08:00"),
            NotificationItem("N008", "Top Up Berhasil", "Top Up Rp200.000 berhasil", NotificationType.PAYMENT, true, "2025-05-15 09:00"),
        )
    )

    override suspend fun getConversations(): Result<List<Conversation>> = Result.Success(
        listOf(
            Conversation("C001", "Budi Santoso", null, "Baik kak, saya sudah di lokasi", "2025-05-19 14:35", 0, ConversationType.DRIVER),
            Conversation("C002", "Clay Support", null, "Silakan jelaskan kendala Anda", "2025-05-19 13:00", 1, ConversationType.SUPPORT),
            Conversation("C003", "Kurir ClaySend", null, "Paket sudah sampai tujuan", "2025-05-18 10:30", 0, ConversationType.DRIVER),
            Conversation("C004", "Dokter Tania", null, "Jangan lupa minum obat 3x sehari", "2025-05-17 15:00", 2, ConversationType.MERCHANT),
            Conversation("C005", "PetShop Happy", null, "Anjing sudah selesai grooming", "2025-05-15 11:30", 0, ConversationType.MERCHANT),
        )
    )

    override suspend fun getMessages(conversationId: String): Result<List<ChatMessage>> = Result.Success(
        listOf(
            ChatMessage("M1", "driver", "Budi Santoso", "Halo kak, saya sudah di lokasi", "14:30", true),
            ChatMessage("M2", "user", "Saya", "Baik pak, sebentar lagi keluar", "14:31", true),
            ChatMessage("M3", "driver", "Budi Santoso", "Baik kak, saya tunggu", "14:32", true),
            ChatMessage("M4", "driver", "Budi Santoso", "Saya parkir di depan gerbang", "14:33", true),
            ChatMessage("M5", "user", "Saya", "Oke pak, sudah keluar", "14:34", true),
            ChatMessage("M6", "driver", "Budi Santoso", "Baik kak, saya sudah di lokasi", "14:35"),
        )
    )
}
