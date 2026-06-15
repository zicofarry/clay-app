enum UserRole { user, driver, merchant, admin }

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  lookingForDriver,
  driverAssigned,
  pickedUp,
  delivered,
  completed,
  cancelled,
}

enum ServiceType { gocar, gofood, gosend }

enum PaymentMethod { gopay, cod, transfer }
