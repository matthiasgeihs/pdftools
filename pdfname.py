#!/usr/bin/env python3

from PyPDF2 import PdfReader
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
from typing import NamedTuple
from os import path, rename
from sys import argv

class ManuscriptInfo(NamedTuple):
    authors: list[str]
    year: int
    title: str

# Extract identifying search string from PDF.
def extract_search_string(fn: str) -> str:
    # Load PDF.
    reader = PdfReader(fn)

    # Assume first line contains title. Read first line and return.
    page = reader.pages[0]
    text = page.extract_text()
    first_line_end = text.lower().find("\n")
    title = text[:first_line_end]
    return title

# Find manuscript metadata by search string.
def find_info(search_string: str) -> ManuscriptInfo | None:
    # Convert search string to query string.
    tokens = search_string.split(" ")
    tokens = filter(ascii_encodable, tokens)
    qry = '+'.join(tokens)
    qry = qry.replace('-', '+')

    # Query dblp and parse results. Assume first result is correct.
    contents = urllib.request.urlopen(f"https://dblp.org/search/publ/api?q={qry}").read()
    root = ET.fromstring(contents)
    hits = root.find("hits")
    if hits == None or len(hits) == 0:
        return None
    info = hits[0].find("info")
    if info == None:
        return None
    
    # Get authors.
    authors = info.find("authors")
    if authors == None:
        return None
    authors = [author.text for author in authors]

    # Get title.
    title = info.find("title")
    if title == None:
        return None
    title = title.text

    # Get year.
    year = info.find("year")
    if year == None:
        return None
    year = int(year.text)
    
    return ManuscriptInfo(authors, year, title)

# Make file title from manuscript meta data.
def make_file_title(info: ManuscriptInfo) -> str:
    # flln ~ first letter of last name.
    def flln(author: str) -> str:
        last_name = author.split(" ")[-1]
        return last_name[0].capitalize()
    
    # First letter of last name of up to first 3 authors.
    first_letters = map(flln, info.authors[:3])
    fn = ''.join(first_letters)

    # Append "+" if more than 3 authors.
    if len(info.authors) > 3:
        fn += "+"
    
    # Append year.
    fn += str(info.year)

    # Append first two words of title.
    tokens = info.title.split(" ")[:2]
    tokens = map(filter_ascii, tokens)
    tokens = map(lambda x: x.capitalize(), tokens)
    fn += ''.join(tokens)
    return fn

# Rename manuscript file based on content.
def name_pdf(fn: str, search_string: str | None = None):
    if search_string == None:
        search_string = extract_search_string(fn)
    
    info = find_info(search_string)
    if info == None:
        print("Could not find metadata for PDF. Exiting.")
        exit(1)
    
    title = make_file_title(info)
    base_path = path.dirname(fn)
    new_fn = path.join(base_path, title + ".pdf")
    print(f'Renaming "${fn}" to "${new_fn}"...')
    rename(fn, new_fn)
    print("Done.")

### BEGIN ASCII UTILS ###

def ascii_encodable(s: str) -> bool:
    try:
        s.encode("ascii")
    except UnicodeError:
        return False
    return True

def filter_ascii(s: str) -> str:
    return s.encode('ascii', errors='ignore').decode()

### END ASCII UTILS ###

if __name__ == '__main__':
    if len(argv) < 2:
        print("Usage: [file_name] [search_string:optional]")
        print("Please provide a PDF file name as the first argument.")
        print("Optionally, provide a search string for finding the metadata.")
        exit(1)

    fn = argv[1]
    search_string = argv[2] if len(argv) >= 3 else None
    name_pdf(fn, search_string)
