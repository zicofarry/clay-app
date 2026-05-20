package com.clay.core.network.api

import com.clay.core.model.Transaction
import com.clay.core.model.Voucher
import com.clay.core.model.Wallet
import retrofit2.http.*

interface WalletApi {
    @GET("api/v1/wallet")
    suspend fun getWallet(): Wallet

    @GET("api/v1/wallet/transactions")
    suspend fun getTransactions(): List<Transaction>

    @POST("api/v1/wallet/topup")
    suspend fun topUp(@Body request: TopUpRequest): TopUpResponse

    @GET("api/v1/promotions/vouchers")
    suspend fun getVouchers(): List<Voucher>
}

data class TopUpRequest(val amount: Int, val paymentMethod: String)
data class TopUpResponse(val transactionId: String, val amount: Int, val status: String)
