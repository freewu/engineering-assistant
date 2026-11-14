#!/usr/bin/env bash
# 用无头 Chrome 重新生成截图。
#
# 用法：
#   bash tool/screenshot.sh [端口]            重新生成 README 用的 docs/screenshots/*.png
#   bash tool/screenshot.sh [端口] --site     重新生成官网用的 docs/shots/<语言>/*.png
#   bash tool/screenshot.sh --check           校验上面两批截图是否齐全（CI 可用）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_OUT="$ROOT/docs/screenshots"
SITE_OUT="$ROOT/docs/shots"
PORT="8765"
MODE="readme"

usage() {
  cat <<'EOF'
用法：bash tool/screenshot.sh [端口] [--site|--check]
  端口     静态服务器端口，默认 8765
  --site   生成官网用的多语言截图（docs/shots/<语言>/）
  --check  只校验截图是否齐全，不启动浏览器
EOF
}

for arg in "$@"; do
  case "$arg" in
    --site) MODE="site" ;;
    --check) MODE="check" ;;
    -h | --help)
      usage
      exit 0
      ;;
    [0-9]*)
      PORT="$arg"
      ;;
    *)
      echo "未知参数：$arg（可用：端口号、--site、--check）" >&2
      usage >&2
      exit 2
      ;;
  esac
done
URL="http://localhost:$PORT"

# 官网提供与 README 相同的 19 个工具截图，只是附加 ?lang= 让界面跟着语言走。
TOOL_IDS=(
  material building_area concrete earthwork rebar masonry formwork roof
  insulation decoration paint distance area volume weight temperature
  energy pressure speed
)

# 官网支持的语言目录（与 docs/assets/site.js 的 SITE_LANGS 一致）
SITE_LANGS=(zh-Hans zh-Hant en)

# 截图清单：目录|文件名|窗口尺寸|像素倍率|URL。README 与官网各一份，拍摄与校验共用。
# README 要桌面布局（1440 宽），官网只要手机尺寸（390×844，2 倍像素密度，看着才不糊）。
plan_readme() {
  echo "docs/screenshots|calculator|1440,900|1|index.html"
  echo "docs/screenshots|tools|1440,900|1|index.html?page=tools"
  local id
  for id in "${TOOL_IDS[@]}"; do
    echo "docs/screenshots|$id|1440,900|1|index.html?page=tools&tool=$id"
  done
  echo "docs/screenshots|settings|1440,2220|1|index.html?page=settings"
  echo "docs/screenshots|light|1440,900|1|index.html?theme=light"
  echo "docs/screenshots|english|1440,900|1|index.html?page=tools&tool=distance&lang=en"
  echo "docs/screenshots|zh-hant|1440,900|1|index.html?page=tools&tool=temperature&lang=zh-Hant"
  echo "docs/screenshots|mobile|414,896|1|index.html"
}

# 官网只拍手机竖屏（390×844 是 iPhone 14 的逻辑尺寸），页面与工具都按 App 的样子展示。
SITE_VIEWPORT="390,844"
SITE_SCALE=2

plan_site() {
  local lang id
  for lang in "${SITE_LANGS[@]}"; do
    echo "docs/shots/$lang|calculator|$SITE_VIEWPORT|$SITE_SCALE|index.html?lang=$lang"
    echo "docs/shots/$lang|tools|$SITE_VIEWPORT|$SITE_SCALE|index.html?page=tools&lang=$lang"
    for id in "${TOOL_IDS[@]}"; do
      echo "docs/shots/$lang|$id|$SITE_VIEWPORT|$SITE_SCALE|index.html?page=tools&tool=$id&lang=$lang"
    done
    echo "docs/shots/$lang|settings|$SITE_VIEWPORT|$SITE_SCALE|index.html?page=settings&lang=$lang"
  done
}

# 校验模式：不启动浏览器，只看文件是否齐全（每张至少 20 KB，避免半截图）
if [[ "$MODE" == "check" ]]; then
  missing=0
  total=0
  for plan in plan_readme plan_site; do
    while IFS='|' read -r dir name _size _scale _path; do
      total=$((total + 1))
      file="$ROOT/$dir/$name.png"
      bytes=$(stat -c %s "$file" 2>/dev/null || echo 0)
      if ((bytes < 20000)); then
        echo "✗ 缺少或异常：$dir/$name.png（${bytes} 字节）"
        missing=$((missing + 1))
      fi
    done < <("$plan" </dev/null)
  done
  if ((missing > 0)); then
    echo "✗ 共 $missing / $total 张截图缺失，请执行 just shots 与 just site-shots"
    exit 1
  fi
  echo "✓ 截图齐全：$total 张（README + 官网）"
  exit 0
fi

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# Chrome 可执行文件
if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  CHROME="C:/Program Files/Google/Chrome/Application/chrome.exe"
elif [[ -x "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" ]]; then
  CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
else
  CHROME="$(command -v google-chrome || command -v chromium || echo "")"
fi
[[ -n "$CHROME" ]] || { echo "未找到 Chrome，可手动截图到 docs/ 下的对应目录"; exit 1; }

# Windows 版 Chrome 需要 Windows 风格的文件路径
win_path() {
  if is_wsl; then
    wslpath -w "$1"
  elif [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
    cygpath -w "$1"
  else
    echo "$1"
  fi
}

[[ -d "$ROOT/build/web" ]] || { echo "缺少 build/web，请先执行 just build-web"; exit 1; }

TMP_PROFILE="$(mktemp -d)"
# Windows 版 Chrome 无法使用 WSL 临时路径，需要换算
PROFILE_DIR="$(win_path "$TMP_PROFILE")"
SERVER_PID=""
cleanup() {
  [[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null || true
  rm -rf "$TMP_PROFILE"
}
trap cleanup EXIT

# 复用已有服务器，否则临时起一个（仅本机）
if ! curl -fsS "$URL/index.html" >/dev/null 2>&1; then
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$PORT" --directory "$ROOT/build/web" >/dev/null 2>&1 &
  else
    python -m http.server "$PORT" --directory "$ROOT/build/web" >/dev/null 2>&1 &
  fi
  SERVER_PID=$!
  for _ in $(seq 1 40); do
    curl -fsS "$URL/index.html" >/dev/null 2>&1 && break
    sleep 0.5
  done
  curl -fsS "$URL/index.html" >/dev/null 2>&1 || { echo "静态服务器启动失败"; exit 1; }
  echo "静态服务器：$URL (pid $SERVER_PID)"
fi

# 当前这一批截图输出到哪个目录（shoot 里读写）
SHOT_DIR="$README_OUT"

shoot() {
  local name="$1" size="$2" scale="$3" path="$4"
  local out="$SHOT_DIR/$name.png"
  local scale_flag=()
  if [[ "${scale:-1}" != "1" ]]; then
    scale_flag=(--force-device-scale-factor="$scale")
  fi
  echo "› $(basename "$SHOT_DIR")/$name.png ($size${scale:+ ×$scale})"
  local attempt bytes
  # 无头 Chrome 偶尔加载不完 CanvasKit 会截出残图，重试两次
  for attempt in 1 2 3; do
    timeout 90 "$CHROME" \
      --headless=new --no-sandbox --hide-scrollbars \
      --no-first-run --no-default-browser-check \
      --user-data-dir="$PROFILE_DIR/$(basename "$SHOT_DIR")-$name" \
      --window-size="$size" "${scale_flag[@]}" --virtual-time-budget=60000 \
      --screenshot="$(win_path "$out")" \
      "$URL/$path" </dev/null >/dev/null 2>&1 || true
    bytes=$(stat -c %s "$out" 2>/dev/null || echo 0)
    ((bytes >= 20000)) && break
    echo "  … 第 $attempt 次截图只剩 ${bytes} 字节，重试"
  done
  if ((bytes < 20000)); then
    echo "  ✗ 截图异常（${bytes} 字节），请重试"
    return 1
  fi
  echo "  ✓ ${bytes} 字节"
}

shoot_plan() {
  local plan="$1"
  local dir name size scale path
  # 先把清单读进数组：循环体里要起 Chrome，别让它抢走循环的 stdin
  local -a lines
  mapfile -t lines < <("$plan" </dev/null)
  for line in "${lines[@]}"; do
    IFS='|' read -r dir name size scale path <<<"$line"
    SHOT_DIR="$ROOT/$dir"
    mkdir -p "$SHOT_DIR"
    shoot "$name" "$size" "$scale" "$path" || exit 1
  done
}

if [[ "$MODE" == "site" ]]; then
  shoot_plan plan_site
  echo "✓ 官网截图已更新：docs/shots/{${SITE_LANGS[*]}}"
else
  shoot_plan plan_readme
  echo "✓ README 截图已更新：docs/screenshots"
fi
