package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.Address
import com.clay.core.model.AddressType
import com.clay.core.model.User
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface UserRepository {
    suspend fun getProfile(): Result<User>
    suspend fun updateProfile(name: String?, email: String?): Result<User>
    suspend fun getAddresses(): Result<List<Address>>
    suspend fun addAddress(address: Address): Result<Address>
}

@Singleton
class UserRepositoryImpl @Inject constructor() : UserRepository {

    private val mockAddresses = listOf(
        Address("ADDR1", "Rumah", "Jl. Merdeka No. 10, Jakarta Pusat", -6.2002, 106.8166, true, AddressType.HOME),
        Address("ADDR2", "Kantor", "Jl. Sudirman Kav. 45, Jakarta Selatan", -6.2242, 106.8036, false, AddressType.OFFICE),
    )

    override suspend fun getProfile(): Result<User> = Result.Success(
        User(
            id = "USR001", name = "Raffi Ahmad", email = "raffi@clay.id",
            phone = "08123456789", role = com.clay.core.model.UserRole.CONSUMER,
            referralCode = "CLAYRAFFI", isPhoneVerified = true, isEmailVerified = true,
        )
    )

    override suspend fun updateProfile(name: String?, email: String?): Result<User> {
        delay(500)
        return getProfile()
    }

    override suspend fun getAddresses(): Result<List<Address>> {
        delay(300)
        return Result.Success(mockAddresses)
    }

    override suspend fun addAddress(address: Address): Result<Address> {
        delay(500)
        return Result.Success(address)
    }
}
