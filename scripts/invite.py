import requests

# --- KONFIGURASI ---
GITHUB_TOKEN = "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"
GITHUB_USERNAME = "zicofarry" # Contoh: zicofarry

# Daftar username yang ingin di-invite
COLLABORATORS = ["rulikaa", "reppapi", "Alagaputra", "raffienanda"]

# Daftar 27 repository kamu
REPOS = [
    "clay-auth-service", "clay-user-service", "clay-ride-order-service",
    "clay-food-order-service", "clay-delivery-order-service", "clay-matching-service",
    "clay-geo-service", "clay-tracking-service", "clay-payment-service",
    "clay-wallet-service", "clay-pricing-service", "clay-merchant-service",
    "clay-chat-service", "clay-rating-service", "clay-history-service",
    "clay-security-service", "clay-promotion-service", "clay-search-service",
    "clay-notification-service", "clay-push-service", "clay-email-service",
    "clay-sms-service", "clay-audit-log-service", "clay-gateway",
    "clay-shared", "clay-infra", "clay-docs"
]

def add_collaborators():
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

    for repo in REPOS:
        print(f"\n--- Processing Repo: {repo} ---")
        for collaborator in COLLABORATORS:
            # Endpoint API untuk menambah kolaborator
            # Default permission adalah 'push' (bisa edit code)
            url = f"https://api.github.com/repos/{GITHUB_USERNAME}/{repo}/collaborators/{collaborator}"
            
            response = requests.put(url, headers=headers)
            
            if response.status_code == 201:
                print(f"[SUCCESS] Invited {collaborator} to {repo}")
            elif response.status_code == 204:
                print(f"[INFO] {collaborator} is already a collaborator in {repo}")
            else:
                print(f"[FAILED] Could not invite {collaborator}. Status: {response.status_code}, Msg: {response.json().get('message')}")

if __name__ == "__main__":
    if GITHUB_TOKEN == "GANTI_DENGAN_TOKEN_KAMU":
        print("Error: Tolong isi GITHUB_TOKEN terlebih dahulu!")
    else:
        add_collaborators()
        print("\nSelesai! Pastikan teman-teman kamu cek email atau notifikasi GitHub mereka untuk 'Accept Invitation'.")