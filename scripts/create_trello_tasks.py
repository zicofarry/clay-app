import requests
import json
import os

# Trello API Credentials
# Dapatkan API Key & Token dari: https://trello.com/app-key
API_KEY = "f31f6ee3a188877d188f7255c5080198"
API_TOKEN = "ATTAdde4e033eb1a09ae8678de72d158f355abbe7ad200284ea1dca05de2800d9ffb78C0870E"

# Board ID dari URL: https://trello.com/b/K8DarPjY/tim20-couldcomputing
BOARD_ID = "K8DarPjY"

# List 24 Service yang ada di folder Clay
SERVICES = [
    "Audit Log", "Auth", "Chat", "Delivery Order", "Email", 
    "Food Order", "Gateway", "Geo", "History", "Matching", 
    "Merchant", "Notification", "Payment", "Pricing", "Promotion", 
    "Push", "Rating", "Ride Order", "Search", "Security", 
    "SMS", "Tracking", "User", "Wallet"
]

def get_lists_on_board():
    url = f"https://api.trello.com/1/boards/{BOARD_ID}/lists"
    query = {
        'key': API_KEY,
        'token': API_TOKEN
    }
    response = requests.get(url, params=query)
    response.raise_for_status()
    return response.json()

def create_card(list_id, service_name):
    url = "https://api.trello.com/1/cards"
    
    title = f"Bikin Unit & Functional test untuk {service_name} Service"
    description = """- membuat unit test
- membuat functional test
- build image docker
- jalankan docker
- test manual untuk mengecek jika sudah PASS semua"""

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

    print("\nPilih List (Kolom) tempat task akan dibuat:")
    for i, t_list in enumerate(trello_lists):
        print(f"{i + 1}. {t_list['name']}")
    
    choice = int(input("\nMasukkan nomor list (contoh: 1): ")) - 1
    selected_list_id = trello_lists[choice]['id']

    print("\nMulai membuat 24 task...\n")
    for service in SERVICES:
        create_card(selected_list_id, service)
    
    print("\n🎉 Selesai! Semua task berhasil ditambahkan ke Trello.")

if __name__ == "__main__":
    main()
