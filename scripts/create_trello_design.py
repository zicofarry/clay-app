import requests
import json

# Trello API Credentials
API_KEY = "f31f6ee3a188877d188f7255c5080198"
API_TOKEN = "ATTAdde4e033eb1a09ae8678de72d158f355abbe7ad200284ea1dca05de2800d9ffb78C0870E"
BOARD_ID = "K8DarPjY"

# List tugas desain UI/UX (Figma)
DESIGN_TASKS = [
    {
        "title": "[Figma] Customer App: Auth & Profile",
        "desc": "- Halaman Login / Register\n- Input OTP\n- Setup Profil (Nama, Foto)\n- Daftar Alamat Tersimpan"
    },
    {
        "title": "[Figma] Customer App: Home & Wallet",
        "desc": "- Beranda Utama (Tombol Ride, Food, dll)\n- Saldo Wallet\n- Halaman Top-Up Saldo\n- Histori Transaksi"
    },
    {
        "title": "[Figma] Customer App: Ride Order Flow",
        "desc": "- Pilih lokasi jemput & tujuan\n- Pilih tipe kendaraan (Motor/Mobil)\n- Tampilan Maps & tracking posisi driver\n- Halaman Rating/Review"
    },
    {
        "title": "[Figma] Customer App: Food Order Flow",
        "desc": "- Daftar Restoran\n- Detail Menu Makanan\n- Keranjang Belanja (Cart) & Checkout\n- Tracking pesanan makanan"
    },
    {
        "title": "[Figma] Customer & Driver: Chat System",
        "desc": "- Tampilan antarmuka chat\n- Fitur kirim foto & lokasi"
    },
    {
        "title": "[Figma] Driver App: Onboarding",
        "desc": "- Form pendaftaran driver\n- Halaman upload dokumen (KTP, SIM, STNK, Foto Diri)"
    },
    {
        "title": "[Figma] Driver App: Dashboard & Income",
        "desc": "- Toggle status Online/Offline\n- Peta lokasi driver saat ini\n- Ringkasan pendapatan harian\n- Halaman Tarik Saldo (Withdraw)"
    },
    {
        "title": "[Figma] Driver App: Order Handling",
        "desc": "- Notifikasi order masuk (Tombol Terima / Tolak)\n- Navigasi Maps arah jalan\n- Konfirmasi pesanan selesai"
    },
    {
        "title": "[Figma] Merchant App: Dashboard & Order",
        "desc": "- Layar pantau pesanan masuk\n- Ubah status: Terima Pesanan, Sedang Dimasak, Siap Diambil"
    },
    {
        "title": "[Figma] Merchant App: Menu Management",
        "desc": "- Halaman tambah/edit menu makanan\n- Atur harga & foto menu\n- Toggle status stok (Habis/Tersedia)\n- Fitur Promo/Diskon"
    },
    {
        "title": "[Figma] Admin Web Dashboard: Verification",
        "desc": "- Tabel pendaftaran driver & merchant baru\n- Halaman review dokumen (Approve / Reject)"
    },
    {
        "title": "[Figma] Admin Web Dashboard: Audit & Tracking",
        "desc": "- Peta pantauan posisi semua driver secara live\n- Tabel Audit Log aktivitas user di dalam sistem"
    }
]

def get_lists_on_board():
    url = f"https://api.trello.com/1/boards/{BOARD_ID}/lists"
    query = {'key': API_KEY, 'token': API_TOKEN}
    response = requests.get(url, params=query)
    response.raise_for_status()
    return response.json()

def create_card(list_id, title, description):
    url = "https://api.trello.com/1/cards"
    query = {
        'idList': list_id,
        'key': API_KEY,
        'token': API_TOKEN,
        'name': title,
        'desc': description,
        'pos': 'bottom'
    }
    response = requests.post(url, params=query)
    if response.status_code == 200:
        print(f"✅ Berhasil membuat task: {title}")
    else:
        print(f"❌ Gagal membuat task: {title} - {response.text}")

def main():
    print("Mencari List (Kolom) di Board Trello...")
    try:
        trello_lists = get_lists_on_board()
    except Exception as e:
        print(f"Gagal koneksi ke Trello. Pastikan API Key dan Token benar.\nError: {e}")
        return

    print("\nPilih List (Kolom) tempat task DESIGN akan dibuat:")
    for i, t_list in enumerate(trello_lists):
        print(f"{i + 1}. {t_list['name']}")
    
    choice = int(input("\nMasukkan nomor list (contoh: 1): ")) - 1
    selected_list_id = trello_lists[choice]['id']

    print("\nMulai membuat 12 task Figma Design...\n")
    for task in DESIGN_TASKS:
        create_card(selected_list_id, task["title"], task["desc"])
    
    print("\n🎉 Selesai! Semua task desain Figma berhasil ditambahkan ke Trello.")

if __name__ == "__main__":
    main()
