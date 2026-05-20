package com.clay.core.data.repository

import com.clay.core.common.Result
import com.clay.core.model.User
import com.clay.core.model.UserRole
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

interface AuthRepository {
    suspend fun login(identifier: String, password: String): Result<User>
    suspend fun register(name: String, email: String, phone: String, password: String): Result<User>
    suspend fun requestOtp(phone: String): Result<Int>
    suspend fun verifyOtp(phone: String, otp: String): Result<Boolean>
    suspend fun logout()
    suspend fun isLoggedIn(): Boolean
    suspend fun getCurrentUser(): Result<User>
}

@Singleton
class AuthRepositoryImpl @Inject constructor() : AuthRepository {

    private val mockUser = User(
        id = "USR001",
        name = "Raffi Ahmad",
        email = "raffi@clay.id",
        phone = "08123456789",
        avatarUrl = null,
        role = UserRole.CONSUMER,
        referralCode = "CLAYRAFFI",
        isPhoneVerified = true,
        isEmailVerified = true,
    )

    override suspend fun login(identifier: String, password: String): Result<User> {
        delay(800)
        return Result.Success(mockUser)
    }

    override suspend fun register(name: String, email: String, phone: String, password: String): Result<User> {
        delay(1000)
        return Result.Success(mockUser.copy(name = name, email = email, phone = phone))
    }

    override suspend fun requestOtp(phone: String): Result<Int> {
        delay(500)
        return Result.Success(60)
    }

    override suspend fun verifyOtp(phone: String, otp: String): Result<Boolean> {
        delay(500)
        return Result.Success(true)
    }

    override suspend fun logout() {}

    override suspend fun isLoggedIn(): Boolean = false

    override suspend fun getCurrentUser(): Result<User> = Result.Success(mockUser)
}
