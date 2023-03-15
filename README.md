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