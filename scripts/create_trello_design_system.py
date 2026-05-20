import requests

# Trello API Credentials
API_KEY = "f31f6ee3a188877d188f7255c5080198"
API_TOKEN = "ATTAdde4e033eb1a09ae8678de72d158f355abbe7ad200284ea1dca05de2800d9ffb78C0870E"
BOARD_ID = "K8DarPjY"

# Task Design System
DESIGN_SYSTEM_TASK = {
    "title": "[Figma] Setup Design System & Master Components",
    "desc": """Tujuan: Membuat fondasi desain (UI Kit) agar pengerjaan puluhan halaman aplikasi "Clay" seragam, konsisten, dan proses mendesain tim jauh lebih cepat. Semua komponen WAJIB dijadikan "Master Component" di Figma.

### 📌 Task Checklist:

**1. Foundations (Pondasi Dasar)**
- [ ] Tentukan Color Palette (Primary/Brand, Secondary, Success, Error, Warning, dan Neutral/Grayscale).
- [ ] Buat Typography / Text Styles (Heading 1-3, Text Body reguler, dan teks Caption kecil).
- [ ] Atur Spacing & Grid System (Gunakan sistem kelipatan 4px atau 8px).
- [ ] Tentukan standar Drop Shadows (bayangan) & Corner Radius (lengkungan sudut).

**2. Core Components (Gunakan fitur "Variants" di Figma)**
- [ ] Buttons (Primary, Secondary, Outline, Text-only, dan bentuk Disabled).
- [ ] Input Fields & Forms (Kolom teks, Search bar, Dropdown, Checkbox, Radio, dan Toggle Switch).
- [ ] Siapkan Library Icon Standar (minimal 24x24px untuk ikon dasar aplikasi).
- [ ] Badges & Tags (Misal: label "Promo", status "Sedang Dimasak", "Selesai").

**3. Complex Components (Komponen Gabungan)**
- [ ] Navigation (Bottom Navigation Bar untuk aplikasi, dan Header/App Bar).
- [ ] Cards (Desain master untuk Kartu Restoran, Kartu Menu Makanan, Kartu Riwayat Order).
- [ ] Modals & Bottom Sheets (Desain Pop-up peringatan & menu yang muncul dari bawah layar).
- [ ] Feedback States (Tampilan Empty State/kosong, Skeleton Loading, dan Toast Snackbar notifikasi)."""
}

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
        'pos': 'top'  # Ditaruh paling atas karena ini prioritas utama
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

    print("\nPilih List (Kolom) tempat task Design System akan dibuat:")
    for i, t_list in enumerate(trello_lists):
        print(f"{i + 1}. {t_list['name']}")
    
    choice = int(input("\nMasukkan nomor list (contoh: 1): ")) - 1
    selected_list_id = trello_lists[choice]['id']

    print("\nMengunggah task Design System ke Trello...\n")
    create_card(selected_list_id, DESIGN_SYSTEM_TASK["title"], DESIGN_SYSTEM_TASK["desc"])
    
    print("\n🎉 Selesai! Task Design System sudah masuk ke Trello di posisi paling atas.")

if __name__ == "__main__":
    main()
