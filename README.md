
# 🕸️ Wayback URL Fetcher

A blazing-fast Python CLI tool that fetches historical URLs from the **Wayback Machine (archive.org)** for a single domain or a list of domains — perfect for **bug bounty**, **OSINT**, and **web recon**.

Built by: **Mayank Malaviya** ([@AIwolfie](https://github.com/AIwolfie)) ⚡

---

## 📦 Features

✅ Fetch URLs archived by the Wayback Machine  
✅ Supports single domain `-d` or list from file `-l`  
✅ Multithreaded for fast execution  
✅ Outputs unique URLs only  
✅ Verbose mode to show live fetching  
✅ Summary of total domains, URLs, and time taken  
✅ Smart suggestions if no results found  
✅ Built-in help menu and credits  

---

## 🚀 Installation

### 1. Clone or download this repo
```bash
git clone https://github.com/AIwolfie/waybackfetcher.git
cd waybackfetcher
````

### 2. Make the script executable

```bash
chmod +x waybackfetcher.py
```

### 3. (Optional) Install globally to use like a command

#### A. Move to `/usr/local/bin/`

```bash
sudo mv waybackfetcher.py /usr/local/bin/waybackfetcher
```

#### B. Or symlink if you still want to edit:

```bash
sudo ln -s $(pwd)/waybackfetcher.py /usr/local/bin/waybackfetcher
```

---

## 🧪 Usage

### Single domain

```bash
waybackfetcher -d example.com -o urls.txt
```

### Multiple domains

```bash
waybackfetcher -l domains.txt -o results.txt
```

### Verbose output (shows URLs live + per-domain count)

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
usage: waybackfetcher [-h] (-d DOMAIN | -l LIST) -o OUTPUT [-v]

🕸️ Wayback URL Fetcher - Fast historical URL fetcher from the Wayback Machine.

options:
  -h, --help        Show this help message and exit
  -d DOMAIN         Single domain (e.g. example.com)
  -l LIST           File containing domains (one per line)
  -o OUTPUT         Output file to save all unique URLs
  -v, --verbose     Show live URLs and per-domain counts
```

---

## 📥 Output

* All URLs are saved to the file specified with `-o`
* Duplicates are removed
* Each run prints a summary including:

  * Domains processed
  * Total unique URLs
  * Time taken

---

## 🧠 Suggestions if no URLs are found

If you see:

```
[!] No URLs found for:
   - somedomain.com

💡 Tips:
   - Maybe it’s a *new domain* (no archive yet).
   - Try *subdomain enumeration* for more data.
   - Check spelling or try alternative TLDs.
```

These are friendly hints to improve recon coverage.

---

## 🧑‍💻 Author

**👨‍💻 Mayank Malaviya**

* GitHub: [AIwolfie](https://github.com/AIwolfie)
* Medium: [@mayankmalaviya](https://medium.com/@mayankmalaviya)
* LinkedIn: [Mayank's Profile](https://linkedin.com/in/mayank-malaviya)

---

## 📜 License

MIT License

---

## ☕ Like it?

Star it on GitHub and share with your recon team 🖤

```

---

Let me know if you want a `setup.sh` installer script that:
- Checks Python version
- Installs dependencies
- Installs the tool globally in one go.