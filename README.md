
# 🕸️ Wayback URL Fetcher 

A blazing-fast **Bash CLI tool** that fetches historical URLs from the **Wayback Machine (archive.org)** for a single domain or a list of domains — perfect for **bug bounty**, **OSINT**, and **web recon**.

Built by: **Mayank Malaviya** ([@AIwolfie](https://github.com/AIwolfie)) ⚡

---

## 📦 Features

✅ Fetch URLs archived by the Wayback Machine  
✅ Supports single domain `-d` or domain list from file `-l`  
✅ Deduplicates results automatically  
✅ Verbose mode for live URL + domain feedback  
✅ error handling & summary  
✅ Written entirely in **pure Bash**, no Python needed!

---

## 🚀 Installation

### 1. Clone or download this repo

```bash
git clone https://github.com/AIwolfie/waybackfetcher.git
cd waybackfetcher
````

### 2. Make the script executable

```bash
chmod +x waybackfetcher.sh
```

### 3. (Optional) Install globally to use like a command

#### A. Move to `/usr/local/bin/`

```bash
sudo mv waybackfetcher.sh /usr/local/bin/waybackfetcher
```

#### B. Or symlink if you still want to edit:

```bash
sudo ln -s $(pwd)/waybackfetcher.sh /usr/local/bin/waybackfetcher
```

---

## 🧪 Usage

### Fetch for a single domain

```bash
waybackfetcher -d example.com -o urls.txt
```

### Fetch for a list of domains

```bash
waybackfetcher -l domains.txt -o results.txt
```

### Enable verbose mode (shows URLs + per-domain stats)

```bash
waybackfetcher -l domains.txt -o results.txt -v
```

---

## 🆘 Help Menu

Run:

```bash
waybackfetcher -h
```

Output:

```
Usage: waybackfetcher [-d DOMAIN | -l FILE] -o OUTPUT [-v]

  -d DOMAIN     Single domain to fetch URLs (e.g. example.com)
  -l FILE       File containing domains (one per line)
  -o FILE       Output file to save results
  -v            Verbose mode (show live status)
  -h            Show help menu
```

---

## 📥 Output

📝 All URLs are saved to the file you provide using `-o`
🧹 Results are automatically deduplicated
📊 After execution, a clean summary is printed with:

* Total domains processed
* Empty domains (no URLs found)
* Total unique URLs
* Time taken to complete

---

## 🧠 Suggestions if no URLs are found

If you see something like:

```
[!] No URLs found for:
   - xyzdomain.com
```

💡 Tips:

* It might be a new or rarely visited domain
* Try discovering subdomains using tools like `subfinder`, `amass`, or `crt.sh`
* Check domain spelling or use alternative TLDs (like `.in`, `.org`, `.net`)

---


## 🧑‍💻 Author

**👨‍💻 Mayank Malaviya**

* GitHub: [AIwolfie](https://github.com/AIwolfie)
* Medium: [@mayankmalaviya](https://aiwolfie.medium.com/)
* LinkedIn: [Mayank's Profile](https://www.linkedin.com/in/mayank-malaviya-69138b25a/)

---

## 📜 License

MIT License

---


🖤 Star the repo on GitHub and share with your OSINT/recon team!
