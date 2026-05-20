import requests
import time

# Trello API Credentials
API_KEY = "f31f6ee3a188877d188f7255c5080198"
API_TOKEN = "ATTAdde4e033eb1a09ae8678de72d158f355abbe7ad200284ea1dca05de2800d9ffb78C0870E"
BOARD_ID = "K8DarPjY"

# Data Card
CARD_TITLE = "[Figma] Setup Design System & Master Components"
CARD_DESC = """Tujuan: Membuat fondasi desain (UI Kit) agar pengerjaan puluhan halaman aplikasi "Clay" seragam, konsisten, dan proses mendesain tim jauh lebih cepat. Semua komponen WAJIB dijadikan "Master Component" (Variants) di Figma."""

# Data Checklists (Native Trello Checklists)
CHECKLISTS = [
    {
        "name": "1. Foundations (Pondasi Dasar)",
        "items": [
            "Tentukan Color Palette (Primary/Brand, Secondary, Success, Error, Warning, Neutral/Grayscale)",
            "Buat Typography / Text Styles (Heading 1-3, Text Body, Caption)",
            "Atur Spacing & Grid System (Sistem kelipatan 4px/8px)",
            "Tentukan standar Drop Shadows (bayangan) & Corner Radius"
        ]
    },
    {
        "name": "2. Core Components (Wajib pakai Variants)",
        "items": [
            "Buttons (Primary, Secondary, Outline, Text-only, Disabled)",
            "Input Fields & Forms (Kolom teks, Search, Dropdown, Checkbox, Radio, Toggle)",
            "Siapkan Library Icon Standar (minimal 24x24px)",
            "Badges & Tags (Label Promo, Status Order)"
        ]
    },
    {
        "name": "3. Complex Components",
        "items": [
            "Navigation (Bottom Navigation Bar & Header/App Bar)",
            "Cards (Master untuk Kartu Restoran, Menu Makanan, Riwayat Order)",
            "Modals & Bottom Sheets (Pop-up peringatan & menu dari bawah)",
            "Feedback States (Empty State, Skeleton Loading, Toast Snackbar)"
        ]
    }
]

def get_lists_on_board():
    url = f"https://api.trello.com/1/boards/{BOARD_ID}/lists"
    query = {'key': API_KEY, 'token': API_TOKEN}
    response = requests.get(url, params=query)
    response.raise_for_status()
    return response.json()

def create_card(list_id):
    url = "https://api.trello.com/1/cards"
    query = {
        'idList': list_id,
        'key': API_KEY,
        'token': API_TOKEN,
        'name': CARD_TITLE,
        'desc': CARD_DESC,
        'pos': 'top'
    }
    response = requests.post(url, params=query)
    response.raise_for_status()
    card_data = response.json()
    print(f"✅ Card berhasil dibuat: {CARD_TITLE}")
    return card_data['id']

def create_checklist(card_id, checklist_name):
    url = "https://api.trello.com/1/checklists"
    query = {
        'idCard': card_id,
        'name': checklist_name,
        'key': API_KEY,
        'token': API_TOKEN
    }
    response = requests.post(url, params=query)
    response.raise_for_status()
    return response.json()['id']

def add_checklist_item(checklist_id, item_name):
    url = f"https://api.trello.com/1/checklists/{checklist_id}/checkItems"
    query = {
        'name': item_name,
        'key': API_KEY,
        'token': API_TOKEN
    }
    response = requests.post(url, params=query)
    response.raise_for_status()

def main():
    print("Mencari List (Kolom) di Board Trello...")
    try:
        trello_lists = get_lists_on_board()
    except Exception as e:
        print(f"Gagal koneksi ke Trello.\nError: {e}")
        return

    print("\nPilih List (Kolom) tempat task akan dibuat:")
    for i, t_list in enumerate(trello_lists):
        print(f"{i + 1}. {t_list['name']}")
    
    choice = int(input("\nMasukkan nomor list (contoh: 1): ")) - 1
    selected_list_id = trello_lists[choice]['id']

    print("\nMengunggah Card ke Trello...")
    try:
        # 1. Buat Card Utama
        card_id = create_card(selected_list_id)
        
        # 2. Buat Checklist & Items
        for cl in CHECKLISTS:
            print(f"  -> Membuat checklist '{cl['name']}'...")
            checklist_id = create_checklist(card_id, cl['name'])
            
            for item in cl['items']:
                add_checklist_item(checklist_id, item)
                time.sleep(0.1) # Jeda sedikit agar tidak kena rate limit API Trello
                
        print("\n🎉 Selesai! Task Design System dengan fitur Checklist Native Trello berhasil dibuat.")
    except Exception as e:
        print(f"\n❌ Terjadi kesalahan saat memanggil API Trello: {e}")

if __name__ == "__main__":
    main()
