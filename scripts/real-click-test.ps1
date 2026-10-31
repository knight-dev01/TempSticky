# Real OS-level mouse click test for the TempSticky header buttons.
# Unlike CDP .click(), this sends actual cursor + mouse_event input, so it
# exercises Windows drag-region hit testing exactly like a user click.
param(
  [string]$Selector = '#btn-mini',
  [int]$Port = 9222
)

$ErrorActionPreference = 'Stop'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Add-Type -Namespace TS -Name Native -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(System.IntPtr value);
[DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
[DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, System.UIntPtr extra);
[DllImport("user32.dll")] public static extern bool GetWindowRect(System.IntPtr hWnd, out RECT rect);
[DllImport("user32.dll")] public static extern System.IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr hWnd);
[StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
'@

# PER_MONITOR_AWARE_V2 so coordinates match the physical screen (150% scaling).
[TS.Native]::SetProcessDpiAwarenessContext([IntPtr]-4) | Out-Null

function Eval([string]$expr) {
  $out = & node (Join-Path $root 'scripts\cdp-eval.mjs') $Port $expr 2>&1
  return ($out -join "`n")
}

function WindowInfo { Eval 'window.tempsticky.windowInfo()' | ConvertFrom-Json }

$proc = Get-Process electron | Where-Object { $_.MainWindowTitle -eq 'TempSticky' } | Select-Object -First 1
if (-not $proc) { throw 'TempSticky window not found' }

$hwnd = $proc.MainWindowHandle
[TS.Native]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Milliseconds 400

$before = WindowInfo
$rectJson = Eval "(() => { const r = document.querySelector('$Selector').getBoundingClientRect(); return JSON.stringify({x:r.x,y:r.y,w:r.width,h:r.height,dpr:window.devicePixelRatio}); })()" | ConvertFrom-Json
$hit = Eval "(() => { const el = document.querySelector('$Selector'); const r = el.getBoundingClientRect(); const top = document.elementFromPoint(r.x + r.width/2, r.y + r.height/2); return top ? (top.id || top.className || top.tagName) : 'null'; })()"

$r = New-Object TS.Native+RECT
[TS.Native]::GetWindowRect($hwnd, [ref]$r) | Out-Null
$physW = $r.Right - $r.Left
$dipW = $before.bounds.width
$scale = $physW / $dipW

$px = [int]($r.Left + ($rectJson.x + $rectJson.w / 2) * $scale)
$py = [int]($r.Top + ($rectJson.y + $rectJson.h / 2) * $scale)

"selector   : $Selector"
"elementAtPt: $hit"
"windowDip  : $($before.bounds.width)x$($before.bounds.height) @ $($before.bounds.x),$($before.bounds.y)"
"windowPhys : ${physW}x$($r.Bottom - $r.Top) @ $($r.Left),$($r.Top)  scale=$scale"
"clickPhys  : $px,$py"

[TS.Native]::SetCursorPos($px, $py) | Out-Null
Start-Sleep -Milliseconds 250
[TS.Native]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)  # left down
Start-Sleep -Milliseconds 80
[TS.Native]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)  # left up
Start-Sleep -Milliseconds 900

$after = WindowInfo
"bodyClass  : " + (Eval 'document.body.className')
"windowAfter: $($after.bounds.width)x$($after.bounds.height) visible=$($after.visible) minimized=$($after.minimized)"
