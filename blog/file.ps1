$root = (Get-Location).Path
$pat = [regex]::new('<div class="widget-powered[^"]*"[^>]*>.*?</div>\s*</div>', 'Singleline')
$utf8s = [Text.UTF8Encoding]::new($false, $true)
$sjis = [Text.Encoding]::GetEncoding(932)
$changed = 0
Get-ChildItem -Recurse -Filter *.html | Where-Object { $rel = $_.FullName.Substring($root.Length+1); $rel -ne 'index.html' -and $rel -ne 'new.html' -and $rel -ne 'write.html' -and -not $rel.StartsWith('posts\') } | ForEach-Object {
  $bytes = [IO.File]::ReadAllBytes($_.FullName)
  try { $text = $utf8s.GetString($bytes); $enc = [Text.UTF8Encoding]::new($false) } catch { $text = $sjis.GetString($bytes); $enc = $sjis }
  $new = $pat.Replace($text, '')
  if ($new -ne $text) { [IO.File]::WriteAllText($_.FullName, $new, $enc); $changed++ }
}
"変更したファイル数: $changed"
