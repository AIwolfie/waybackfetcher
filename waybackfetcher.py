#!/usr/bin/env python3

import argparse
import requests
from urllib.parse import urlencode
from pathlib import Path
import time

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
        if verbose:
            for url in urls:
                print(url)
        return urls
    except requests.RequestException as e:
        print(f"[!] Error fetching for {domain}: {e}")
        return []

def main():
    parser = argparse.ArgumentParser(description="Fetch Wayback Machine URLs for one or more domains.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-d", "--domain", help="Single domain (e.g. example.com)")
    group.add_argument("-l", "--list", help="File containing list of domains (one per line)")
    parser.add_argument("-o", "--output", help="File to save output", required=True)
    parser.add_argument("-v", "--verbose", action="store_true", help="Show all fetched URLs live")

    args = parser.parse_args()
    domains = []

    if args.domain:
        domains.append(args.domain.strip())
    elif args.list:
        try:
            with open(args.list, "r") as f:
                domains = [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            print(f"[!] File not found: {args.list}")
            return

    print(f"[+] Starting Wayback Fetcher for {len(domains)} domain(s)...")
    start_time = time.time()
    all_urls = []

    for domain in domains:
        print(f"\n[+] Fetching URLs for: {domain}")
        urls = fetch_wayback_urls(domain, verbose=args.verbose)
        all_urls.extend(urls)

    unique_urls = sorted(set(all_urls))

    try:
        with open(args.output, "w") as f:
            for url in unique_urls:
                f.write(url + "\n")
        print(f"\n[+] Saved {len(unique_urls)} unique URLs to {args.output}")
    except Exception as e:
        print(f"[!] Could not write to {args.output}: {e}")

    end_time = time.time()
    print("\n========= SUMMARY =========")
    print(f"Domains Processed : {len(domains)}")
    print(f"Total URLs Fetched: {len(unique_urls)}")
    print(f"Time Taken        : {end_time - start_time:.2f} seconds")
    print("===========================")

if __name__ == "__main__":
    main()
