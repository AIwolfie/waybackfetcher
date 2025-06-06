#!/usr/bin/env python3

import argparse
import requests
import threading
import time
from queue import Queue

__author__ = "Mayank Malaviya (aka AIwolfie)"
__version__ = "1.1"

lock = threading.Lock()
all_urls = []
empty_domains = []

def fetch_wayback_urls(domain, verbose=False):
    base_url = "https://web.archive.org/cdx/search/cdx"
    params = {
        "url": f"*.{domain}/*",
        "collapse": "urlkey",
        "output": "text",
        "fl": "original"
    }

    try:
        response = requests.get(base_url, params=params, timeout=15)
        response.raise_for_status()
        urls = response.text.splitlines()

        with lock:
            if urls:
                all_urls.extend(urls)
                if verbose:
                    print(f"[+] {domain} => {len(urls)} URL(s) found")
                    for url in urls:
                        print(f"    {url}")
            else:
                empty_domains.append(domain)
                if verbose:
                    print(f"[!] {domain} => No URLs found")
    except requests.RequestException as e:
        with lock:
            print(f"[!] Error fetching for {domain}: {e}")
            empty_domains.append(domain)

def worker(domain_queue, verbose):
    while not domain_queue.empty():
        domain = domain_queue.get()
        fetch_wayback_urls(domain, verbose=verbose)
        domain_queue.task_done()

def main():
    parser = argparse.ArgumentParser(
        description="🕸️ Wayback URL Fetcher - Fast historical URL fetcher from the Wayback Machine."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-d", "--domain", help="Single domain (e.g. example.com)")
    group.add_argument("-l", "--list", help="File containing domains (one per line)")
    parser.add_argument("-o", "--output", help="Output file to save all unique URLs", required=True)
    parser.add_argument("-v", "--verbose", action="store_true", help="Show live URLs and per-domain counts")

    args = parser.parse_args()

    # Banner
    print("===============================================")
    print(" Wayback URL Fetcher | by Mayank Malaviya ⚡")
    print(" GitHub: github.com/AIwolfie | Version:", __version__)
    print("===============================================\n")

    # Load domains
    if args.domain:
        domains = [args.domain.strip()]
    else:
        try:
            with open(args.list, "r") as f:
                domains = [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            print(f"[!] File not found: {args.list}")
            return

    start_time = time.time()
    print(f"[+] Starting with {len(domains)} domain(s)...\n")

    # Multithreading setup
    domain_queue = Queue()
    for domain in domains:
        domain_queue.put(domain)

    threads = []
    thread_count = min(10, len(domains))  # Max 10 threads or less if domains are fewer
    for _ in range(thread_count):
        t = threading.Thread(target=worker, args=(domain_queue, args.verbose))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    unique_urls = sorted(set(all_urls))

    # Save output
    try:
        with open(args.output, "w") as f:
            for url in unique_urls:
                f.write(url + "\n")
        print(f"\n[+] ✅ {len(unique_urls)} unique URLs saved to {args.output}")
    except Exception as e:
        print(f"[!] Could not write to {args.output}: {e}")

    end_time = time.time()

    # Summary
    print("\n============ SUMMARY ============")
    print(f"Domains Processed  : {len(domains)}")
    print(f"Total Unique URLs  : {len(unique_urls)}")
    print(f"Time Taken         : {end_time - start_time:.2f} seconds")
    if empty_domains:
        print(f"\n[!] No URLs found for:")
        for d in empty_domains:
            print(f"    - {d}")
        print("\n💡 Tips:")
        print("   - Maybe it’s a *new domain* (no archive yet).")
        print("   - Try *subdomain enumeration* for more data.")
        print("   - Check spelling or try alternative TLDs.")

    print("\n🚀 Thank you for using Wayback Fetcher!")
    print("===============================================")

if __name__ == "__main__":
    main()

    