$port = if ($env:PORT) { $env:PORT } else { 4173 }
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Output "Serving on http://localhost:$port/"
while ($true) {
  $ctx = $listener.GetContext()
  $name = if ($ctx.Request.Url.AbsolutePath -match 'demo') { '..\demo.html' } else { '..\govfeed-prototype.html' }
  $doc = Join-Path $PSScriptRoot $name
  $html = '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"></head><body>' + [IO.File]::ReadAllText($doc) + '</body></html>'
  $bytes = [Text.Encoding]::UTF8.GetBytes($html)
  $ctx.Response.ContentType = 'text/html; charset=utf-8'
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $ctx.Response.Close()
}
