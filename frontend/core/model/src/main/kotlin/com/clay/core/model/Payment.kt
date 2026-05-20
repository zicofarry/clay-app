package com.clay.core.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Wallet(
    val balance: Int,
    val points: Int,
    val membershipTier: MembershipTier = MembershipTier.REGULAR,
)

@JsonClass(generateAdapter = true)
data class Transaction(
    val id: String,
    val type: TransactionType,
    val amount: Int,
    val description: String,
    val date: String,
    val status: TransactionStatus,
)

@JsonClass(generateAdapter = true)
data class PaymentMethod(
    val id: String,
    val type: PaymentMethodType,
    val label: String,
    val icon: String? = null,
    val isDefault: Boolean = false,
)

@JsonClass(generateAdapter = true)
data class Voucher(
    val id: String,
    val code: String,
    val description: String,
    val discountAmount: Int,
    val minPurchase: Int,
    val expiresAt: String,
    val isClaimed: Boolean = false,
)

enum class TransactionType {
    TOP_UP, PAYMENT, REFUND, TRANSFER, WITHDRAWAL
}

enum class TransactionStatus {
    SUCCESS, PENDING, FAILED
}

enum class PaymentMethodType {
    CLAY_PAY, VIRTUAL_ACCOUNT, CREDIT_CARD, OVO, DANA, GOPAY, ALFAMART, INDOMARET
}

enum class MembershipTier {
    REGULAR, SILVER, GOLD, PLATINUM
}
