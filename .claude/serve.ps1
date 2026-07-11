$port = if ($env:PORT) { $env:PORT } else { 4173 }
$root = Split-Path $PSScriptRoot -Parent
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Output "Serving on http://localhost:$port/"
while ($true) {
  $ctx = $listener.GetContext()
  $path = $ctx.Request.Url.AbsolutePath
  $rel = $path.TrimStart('/') -replace '/', '\'
  $file = Join-Path $root $rel
  # Serve the named file when the path points at one inside the repo (e.g.
  # /tests/hansard-url.test.html and the sources it fetches); otherwise keep the
  # original routing: /demo -> demo.html, anything else -> the prototype.
  if ($rel -and -not $rel.Contains('..') -and (Test-Path $file -PathType Leaf)) {
    $doc = $file
  } elseif ($path -match 'demo') {
    $doc = Join-Path $root 'demo.html'
  } else {
    $doc = Join-Path $root 'govfeed-prototype.html'
  }
  $text = [IO.File]::ReadAllText($doc)
  # The app files are body fragments; wrap them. Files with their own doctype
  # (index.html, the Pages build) are served as-is.
  $html = if ($text -match '^\s*<!doctype') { $text }
          else { '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"></head><body>' + $text + '</body></html>' }
  $bytes = [Text.Encoding]::UTF8.GetBytes($html)
  $ctx.Response.ContentType = 'text/html; charset=utf-8'
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $ctx.Response.Close()
}
