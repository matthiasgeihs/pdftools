# pdftools

A collection of PDF tools.

## pdfcrop
`pdfcrop` crops the whitespace from a PDF.
In comparison to other tools, it keeps hyperlinks intact.
Requires [`ghostscript`](https://ghostscript.com).
```zsh
pdfcrop file.pdf
```
This outputs `file_cropped.pdf`.

## pdfname
`pdfname` reads a research manuscript file and renames it based on its metadata.
```zsh
pdfname file.pdf [search_string]
```
This renames the file to `ABC2000PaperTitle.pdf`, if the paper has 3 authors whose last names start with A, B, C, the publishing year is 2000 and the paper title starts with "Paper title".
An optional search string can be provided to help the tool find the metadata.