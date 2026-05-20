package com.clay.core.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class ServiceItem(
    val id: String,
    val name: String,
    val icon: String,
    val type: ServiceType,
    val description: String = "",
)

@JsonClass(generateAdapter = true)
data class Promotion(
    val id: String,
    val title: String,
    val description: String,
    val imageUrl: String? = null,
    val discountPercent: Int? = null,
    val maxDiscount: Int? = null,
    val validUntil: String? = null,
)

@JsonClass(generateAdapter = true)
data class NotificationItem(
    val id: String,
    val title: String,
    val message: String,
    val type: NotificationType,
    val isRead: Boolean = false,
    val createdAt: String,
)

@JsonClass(generateAdapter = true)
data class ChatMessage(
    val id: String,
    val senderId: String,
    val senderName: String,
    val message: String,
    val timestamp: String,
    val isRead: Boolean = false,
)

@JsonClass(generateAdapter = true)
data class Conversation(
    val id: String,
    val participantName: String,
    val participantAvatar: String? = null,
    val lastMessage: String,
    val lastMessageTimestamp: String,
    val unreadCount: Int = 0,
    val type: ConversationType,
)

enum class NotificationType {
    PROMO, ORDER, PAYMENT, SYSTEM
}

enum class ConversationType {
    DRIVER, SUPPORT, MERCHANT
}
