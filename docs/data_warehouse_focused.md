# Rancangan Data Warehouse Clay — Fokus Manager

> **Goal:** Sebagai Manager Clay, kita punya 2 tujuan utama:
> 1. 📈 **Meningkatkan penggunaan user** (user engagement & retention)
> 2. 💰 **Meningkatkan profit** (revenue naik, cost turun)

---

## Kenapa Cuma 5 Dimensi?

Dari 8 dimensi sebelumnya, kita **pilih 5 yang paling berdampak** langsung ke 2 goal di atas. Prinsipnya: **"Kalau dimensi ini gak bisa bantu jawab pertanyaan bisnis yang kritis, buang."**

| Dimensi | Keep? | Alasan |
|---|---|---|
| ⏰ Dim_Time | ✅ | Wajib — tanpa waktu gak bisa lihat tren |
| 👤 Dim_User | ✅ | Wajib — target utama kita adalah user |
| 📍 Dim_Location | ✅ | Penting — ekspansi & alokasi driver per wilayah |
| 💳 Dim_Payment_Method | ✅ | Penting — cash vs digital langsung affect profit margin |
| 🎫 Dim_Promotion | ✅ | Penting — promo itu cost besar, harus diukur ROI-nya |
| 🏍️ Dim_Driver | ❌ | Pindah ke measures — cukup hitung jumlah driver, gak perlu detail per driver |
| 🏪 Dim_Merchant | ❌ | Pindah ke measures — cukup di-aggregate, bukan fokus utama manager level atas |
| 🔧 Dim_Service_Type | ❌ | Dijadikan **atribut di Fact Table** aja (kolom `service_type`) — cuma 3 nilai |

---

## Diagram: Fact Constellation — Versi Fokus

```mermaid
graph TB
    subgraph "🎯 FACT TABLES"
        F1["🚗 Fact_Ride_Orders<br/>────────────────<br/>fare_final, distance_km,<br/>surge_multiplier, platform_fee,<br/>is_cancelled, is_completed"]
        F2["🍔 Fact_Food_Orders<br/>────────────────<br/>total_cents, delivery_fee,<br/>discount_cents, item_count,<br/>is_cancelled, is_completed"]
        F3["📦 Fact_Delivery_Orders<br/>────────────────<br/>fare_final, distance_km,<br/>platform_fee, weight_kg,<br/>is_cancelled, is_completed"]
    end

    subgraph "📐 5 DIMENSI KUNCI"
        D1["⏰ Dim_Time<br/>────────────<br/>date, hour, day_of_week,<br/>month, quarter, year,<br/>is_weekend, is_peak_hour"]
        D2["👤 Dim_User<br/>────────────<br/>user_segment, city,<br/>reg_date, lifetime_orders,<br/>days_since_last_order"]
        D3["📍 Dim_Location<br/>────────────<br/>city, district,<br/>province, zone_type"]
        D4["💳 Dim_Payment<br/>────────────<br/>payment_type,<br/>payment_category"]
        D5["🎫 Dim_Promotion<br/>────────────<br/>promo_code, promo_type,<br/>discount_value, target_service"]
    end

    D1 --> F1
    D1 --> F2
    D1 --> F3

    D2 --> F1
    D2 --> F2
    D2 --> F3

    D3 --> F1
    D3 --> F2
    D3 --> F3

    D4 --> F1
    D4 --> F2
    D4 --> F3

    D5 --> F1
    D5 --> F2
    D5 --> F3

    style F1 fill:#FF6B6B,stroke:#CC0000,color:#fff
    style F2 fill:#FFA94D,stroke:#CC7700,color:#fff
    style F3 fill:#51CF66,stroke:#2B8A3E,color:#fff
    style D1 fill:#74C0FC,stroke:#1C7ED6,color:#000
    style D2 fill:#B197FC,stroke:#7048E8,color:#000
    style D3 fill:#63E6BE,stroke:#0CA678,color:#000
    style D4 fill:#A9E34B,stroke:#66A80F,color:#000
    style D5 fill:#FF922B,stroke:#E8590C,color:#000
```

---

## Detail: 5 Dimensi + Alasan Bisnis

### 1. ⏰ Dim_Time — "Kapan user paling aktif?"

```mermaid
erDiagram
    Dim_Time {
        int time_key PK "Surrogate Key"
        date full_date "2026-05-21"
        int hour "14"
        string day_of_week "Wednesday"
        int month "5"
        int quarter "2"
        int year "2026"
        boolean is_weekend "false"
        boolean is_peak_hour "true (11-13, 17-20)"
    }
```

| Goal | Pertanyaan yang bisa dijawab |
|---|---|
| 📈 User | "Jam berapa user paling banyak order? → push notif di jam itu" |
| 📈 User | "Hari apa order paling sepi? → kasih promo di hari itu" |
| 💰 Profit | "Kapan harus aktifkan surge pricing?" |
| 💰 Profit | "Quarter mana revenue paling tinggi? → forecast budget" |

### 2. 👤 Dim_User — "Siapa user kita dan gimana perilakunya?"

```mermaid
erDiagram
    Dim_User {
        string user_key PK "Surrogate Key"
        string user_id "Original ID"
        string city "Jakarta"
        date registration_date "2025-01-15"
        string user_segment "new / active / at_risk / churned"
        int lifetime_orders "47"
        int days_since_last_order "3"
        float avg_order_value "35000"
    }
```

**Segmentasi user_segment:**

| Segment | Definisi | Aksi Manager |
|---|---|---|
| `new` | Register < 30 hari, order < 3x | Kasih voucher onboarding |
| `active` | Order ≥ 1x dalam 14 hari terakhir | Pertahankan, kasih loyalty reward |
| `at_risk` | Terakhir order 15-30 hari lalu | Kirim push notif + diskon win-back |
| `churned` | Tidak order > 30 hari | Kampanye re-engagement agresif |

| Goal | Pertanyaan yang bisa dijawab |
|---|---|
| 📈 User | "Berapa % user yang churned bulan ini?" |
| 📈 User | "Promo apa yang paling efektif untuk user at_risk?" |
| 💰 Profit | "User segment mana yang punya avg_order_value tertinggi?" |
| 💰 Profit | "Berapa cost akuisisi user baru vs retain user lama?" |

### 3. 📍 Dim_Location — "Di mana demand tinggi dan profit bagus?"

```mermaid
erDiagram
    Dim_Location {
        string location_key PK "Surrogate Key"
        string city "Jakarta"
        string district "Kebayoran Baru"
        string province "DKI Jakarta"
        string zone_type "urban / suburban"
    }
```

| Goal | Pertanyaan yang bisa dijawab |
|---|---|
| 📈 User | "Kota mana yang pertumbuhan user-nya paling cepat?" |
| 📈 User | "District mana yang underserved? → prioritas ekspansi" |
| 💰 Profit | "Kota mana yang cancellation rate-nya tinggi? → alokasi driver" |
| 💰 Profit | "Zona mana yang delivery cost-nya terlalu mahal?" |

### 4. 💳 Dim_Payment_Method — "Gimana cara user bayar?"

```mermaid
erDiagram
    Dim_Payment_Method {
        string payment_key PK "Surrogate Key"
        string payment_type "gopay / cash / clay_wallet / credit_card"
        string payment_category "digital_wallet / cash / card"
    }
```

| Goal | Pertanyaan yang bisa dijawab |
|---|---|
| 📈 User | "Berapa % user masih pakai cash? → dorong migrasi ke digital" |
| 💰 Profit | "Digital payment → settlement lebih cepat, fraud lebih rendah" |
| 💰 Profit | "User yang pakai Clay Wallet → lebih loyal (uang sudah di-topup)" |
| 💰 Profit | "Cash order punya cancellation rate lebih tinggi? → validasi" |

**Kenapa ini penting untuk profit:**
- 💵 **Cash** = driver harus bawa uang kembalian, risiko fraud tinggi, settlement lambat
- 💳 **Digital** = settlement instan, fraud rendah, user cenderung order lebih besar

### 5. 🎫 Dim_Promotion — "Promo mana yang worth it?"

```mermaid
erDiagram
    Dim_Promotion {
        string promo_key PK "Surrogate Key"
        string promo_code "HEMAT50"
        string promo_type "percentage / fixed / free_delivery"
        int discount_value "50"
        int max_discount_cents "25000"
        int min_order_cents "30000"
        string target_service "ride / food / delivery / all"
    }
```

| Goal | Pertanyaan yang bisa dijawab |
|---|---|
| 📈 User | "Promo tipe apa yang paling banyak menarik user baru?" |
| 📈 User | "Free delivery vs percentage discount — mana yang lebih efektif?" |
| 💰 Profit | "Berapa ROI tiap promo? (revenue generated / discount given)" |
| 💰 Profit | "Ada gak promo yang burn rate-nya tinggi tapi gak nambah retention?" |

---

## Detail: Fact Tables + Measures

### Fact_Ride_Orders

```mermaid
erDiagram
    Fact_Ride_Orders {
        string order_id PK "dari ride-order-service"
        int time_key FK "→ Dim_Time"
        string user_key FK "→ Dim_User"
        string origin_location_key FK "→ Dim_Location"
        string dest_location_key FK "→ Dim_Location"
        string payment_key FK "→ Dim_Payment"
        string promo_key FK "→ Dim_Promotion (nullable)"
        string service_type "goride / gocar"
        float fare_final "💰 MEASURE - tarif akhir"
        float platform_fee "💰 MEASURE - fee Clay"
        float promo_discount "💰 MEASURE - potongan promo"
        float surge_multiplier "💰 MEASURE - faktor surge"
        float distance_km "📏 MEASURE - jarak tempuh"
        int duration_min "⏱️ MEASURE - durasi trip"
        int is_completed "📊 1 atau 0"
        int is_cancelled "📊 1 atau 0"
        string cancelled_by "user / driver / system"
    }
```

### Fact_Food_Orders

```mermaid
erDiagram
    Fact_Food_Orders {
        string order_id PK "dari food-order-service"
        int time_key FK "→ Dim_Time"
        string user_key FK "→ Dim_User"
        string delivery_location_key FK "→ Dim_Location"
        string payment_key FK "→ Dim_Payment"
        string promo_key FK "→ Dim_Promotion (nullable)"
        string service_type "gofood"
        int subtotal_cents "💰 MEASURE - harga item"
        int delivery_fee_cents "💰 MEASURE - ongkir"
        int service_fee_cents "💰 MEASURE - service fee"
        int discount_cents "💰 MEASURE - diskon"
        int total_cents "💰 MEASURE - grand total"
        int item_count "📊 MEASURE - jumlah item"
        float distance_km "📏 MEASURE - jarak"
        int is_completed "📊 1 atau 0"
        int is_cancelled "📊 1 atau 0"
        string cancelled_by "user / merchant / driver / system"
    }
```

### Fact_Delivery_Orders

```mermaid
erDiagram
    Fact_Delivery_Orders {
        string order_id PK "dari delivery-order-service"
        int time_key FK "→ Dim_Time"
        string user_key FK "→ Dim_User"
        string pickup_location_key FK "→ Dim_Location"
        string dropoff_location_key FK "→ Dim_Location"
        string payment_key FK "→ Dim_Payment"
        string promo_key FK "→ Dim_Promotion (nullable)"
        string service_type "gosend"
        float fare_final "💰 MEASURE - tarif akhir"
        float platform_fee "💰 MEASURE - fee Clay"
        float promo_discount "💰 MEASURE - potongan"
        float distance_km "📏 MEASURE - jarak"
        float package_weight_kg "📦 MEASURE - berat paket"
        int is_completed "📊 1 atau 0"
        int is_cancelled "📊 1 atau 0"
        string cancelled_by "user / driver / system"
    }
```

---

## Contoh Analisis: Dashboard Manager

### 📊 KPI Utama yang Bisa Diukur

```mermaid
graph TB
    subgraph "📈 GOAL 1: Meningkatkan User"
        A1["Monthly Active Users<br/>GROUP BY Dim_Time.month"]
        A2["User Retention Rate<br/>GROUP BY Dim_User.segment"]
        A3["New User Conversion<br/>GROUP BY Dim_Promotion"]
        A4["Order Frequency<br/>GROUP BY Dim_User + Dim_Time"]
        A5["Geographic Penetration<br/>GROUP BY Dim_Location.city"]
    end

    subgraph "💰 GOAL 2: Meningkatkan Profit"
        B1["Gross Revenue<br/>SUM(fare_final / total_cents)"]
        B2["Platform Fee Revenue<br/>SUM(platform_fee)"]
        B3["Promo Burn Rate<br/>SUM(discount) / COUNT(orders)"]
        B4["Cancellation Cost<br/>SUM(is_cancelled) per location"]
        B5["Digital Payment Shift<br/>GROUP BY Dim_Payment"]
    end

    style A1 fill:#E8F5E9,stroke:#4CAF50,color:#000
    style A2 fill:#E8F5E9,stroke:#4CAF50,color:#000
    style A3 fill:#E8F5E9,stroke:#4CAF50,color:#000
    style A4 fill:#E8F5E9,stroke:#4CAF50,color:#000
    style A5 fill:#E8F5E9,stroke:#4CAF50,color:#000
    style B1 fill:#FFF3E0,stroke:#FF9800,color:#000
    style B2 fill:#FFF3E0,stroke:#FF9800,color:#000
    style B3 fill:#FFF3E0,stroke:#FF9800,color:#000
    style B4 fill:#FFF3E0,stroke:#FF9800,color:#000
    style B5 fill:#FFF3E0,stroke:#FF9800,color:#000
```

### Query: Retention Rate per User Segment per Bulan

```sql
SELECT
    du.user_segment,
    dt.month_name,
    dt.year,
    COUNT(DISTINCT du.user_key) AS total_users,
    COUNT(DISTINCT CASE WHEN fr.is_completed = 1 THEN du.user_key END) AS active_users,
    ROUND(
        COUNT(DISTINCT CASE WHEN fr.is_completed = 1 THEN du.user_key END) * 100.0
        / NULLIF(COUNT(DISTINCT du.user_key), 0), 2
    ) AS retention_rate_pct
FROM Fact_Ride_Orders fr
JOIN Dim_User du ON fr.user_key = du.user_key
JOIN Dim_Time dt ON fr.time_key = dt.time_key
GROUP BY du.user_segment, dt.month_name, dt.year
ORDER BY dt.year, dt.month_name, retention_rate_pct DESC;
```

### Query: Promo ROI — Mana yang Worth It?

```sql
SELECT
    dp.promo_code,
    dp.promo_type,
    COUNT(*) AS times_used,
    SUM(ff.discount_cents) / 100 AS total_discount_rp,
    SUM(ff.total_cents) / 100 AS total_revenue_rp,
    ROUND(SUM(ff.total_cents) * 1.0 / NULLIF(SUM(ff.discount_cents), 0), 2) AS roi,
    COUNT(DISTINCT ff.user_key) AS unique_users_reached
FROM Fact_Food_Orders ff
JOIN Dim_Promotion dp ON ff.promo_key = dp.promo_key
WHERE dp.promo_key IS NOT NULL
GROUP BY dp.promo_code, dp.promo_type
HAVING SUM(ff.discount_cents) > 0
ORDER BY roi DESC;
```

### Query: Cash vs Digital — Impact ke Cancellation

```sql
SELECT
    dpm.payment_type,
    dpm.payment_category,
    COUNT(*) AS total_orders,
    SUM(fr.is_cancelled) AS cancelled,
    ROUND(SUM(fr.is_cancelled) * 100.0 / COUNT(*), 2) AS cancel_rate_pct,
    AVG(fr.fare_final) AS avg_fare
FROM Fact_Ride_Orders fr
JOIN Dim_Payment_Method dpm ON fr.payment_key = dpm.payment_key
GROUP BY dpm.payment_type, dpm.payment_category
ORDER BY cancel_rate_pct DESC;
```

---

## Kesimpulan: 5 Dimensi = 5 Lever Bisnis

| # | Dimensi | Lever untuk User 📈 | Lever untuk Profit 💰 |
|---|---|---|---|
| 1 | **⏰ Time** | Timing push notif & promo | Surge pricing & demand forecast |
| 2 | **👤 User** | Segmentasi & retention campaign | Identifikasi high-value users |
| 3 | **📍 Location** | Ekspansi ke area underserved | Optimasi alokasi driver & biaya |
| 4 | **💳 Payment** | Dorong adopsi digital wallet | Kurangi fraud & percepat settlement |
| 5 | **🎫 Promotion** | Akuisisi & win-back user | Kontrol burn rate & ukur ROI |
