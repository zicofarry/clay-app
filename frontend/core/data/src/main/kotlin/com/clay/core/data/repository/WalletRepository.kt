package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.*
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface WalletRepository {
    suspend fun getWallet(): Result<Wallet>
    suspend fun getTransactions(): Result<List<Transaction>>
    suspend fun topUp(amount: Int, method: String): Result<Boolean>
    suspend fun getVouchers(): Result<List<Voucher>>
}

@Singleton
class WalletRepositoryImpl @Inject constructor() : WalletRepository {

    override suspend fun getWallet(): Result<Wallet> = Result.Success(
        Wallet(2500000, 2500, MembershipTier.GOLD)
    )

    override suspend fun getTransactions(): Result<List<Transaction>> = Result.Success(
        listOf(
            Transaction("T001", TransactionType.TOP_UP, 500000, "Top Up BCA", "2025-05-19 10:30", TransactionStatus.SUCCESS),
            Transaction("T002", TransactionType.PAYMENT, 35000, "ClayRide - Budi Santoso", "2025-05-19 14:30", TransactionStatus.SUCCESS),
            Transaction("T003", TransactionType.PAYMENT, 45000, "ClayFood - Warung Nusantara", "2025-05-19 13:00", TransactionStatus.SUCCESS),
            Transaction("T004", TransactionType.TOP_UP, 200000, "Top Up Mandiri", "2025-05-18 09:00", TransactionStatus.SUCCESS),
            Transaction("T005", TransactionType.REFUND, 15000, "Refund promo ClayFood", "2025-05-17 15:00", TransactionStatus.SUCCESS),
            Transaction("T006", TransactionType.PAYMENT, 25000, "ClayRide - Ahmad Rizki", "2025-05-16 20:00", TransactionStatus.SUCCESS),
        )
    )

    override suspend fun topUp(amount: Int, method: String): Result<Boolean> {
        delay(1000)
        return Result.Success(true)
    }

    override suspend fun getVouchers(): Result<List<Voucher>> = Result.Success(
        listOf(
            Voucher("V001", "CLAYFOOD50", "Diskon 50% pesanan ClayFood max Rp25rb", 25000, 50000, "2025-06-30"),
            Voucher("V002", "RIDE25", "Potongan Rp25rb perjalanan ClayRide", 25000, 75000, "2025-06-15"),
            Voucher("V003", "NEWUSER20", "Diskon 20% untuk pengguna baru", 20000, 100000, "2025-07-01"),
            Voucher("V004", "SEND10", "Gratis ongkir ClaySend", 10000, 50000, "2025-06-20"),
            Voucher("V005", "WEEKEND50", "Diskon 50% akhir pekan", 50000, 100000, "2025-06-25"),
        )
    )
}
