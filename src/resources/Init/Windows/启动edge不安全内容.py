import winreg
import ctypes
import sys
import argparse
import subprocess

POLICY_KEY_PATH = r"SOFTWARE\Policies\Microsoft\Edge\InsecureContentAllowedForUrls"

# 默认规则（可通过参数追加/删除）
DEFAULT_URL_PATTERNS = [
    # # 内网 / 开发
    # "[*.]local",
    # "[*.]lan",
    # "[*.]internal",
    # "[*.]test",
    # "[*.]dev",

    # # 常见公网后缀（⚠️ 覆盖面极大）
    # "[*.]com",
    # "[*.]net",
    # "[*.]org",
    # "[*.]cn",
    # "[*.]io",
    
    "[*.]bilibili.com",
]

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def parse_bool(value):
    if isinstance(value, bool):
        return value
    text = str(value).strip().lower()
    if text in ("1", "true", "t", "yes", "y", "on"):
        return True
    if text in ("0", "false", "f", "no", "n", "off"):
        return False
    raise argparse.ArgumentTypeError("只支持 true/false")

def parse_patterns(values):
    patterns = []
    for item in values:
        parts = item.split(",")
        for part in parts:
            value = part.strip()
            if value:
                patterns.append(value)
    return patterns

def dedupe_keep_order(values):
    seen = set()
    result = []
    for value in values:
        if value not in seen:
            seen.add(value)
            result.append(value)
    return result

def read_existing_patterns():
    existing = []
    try:
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            POLICY_KEY_PATH,
            0,
            winreg.KEY_READ
        )
    except FileNotFoundError:
        return existing

    try:
        index = 0
        while True:
            name, value, _ = winreg.EnumValue(key, index)
            if name.isdigit() and isinstance(value, str) and value.strip():
                existing.append(value.strip())
            index += 1
    except OSError:
        pass
    finally:
        winreg.CloseKey(key)

    return existing

def write_patterns(patterns):
    key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, POLICY_KEY_PATH)
    try:
        # 先删除所有数字键名，避免残留
        to_delete = []
        index = 0
        while True:
            try:
                name, _, _ = winreg.EnumValue(key, index)
                if name.isdigit():
                    to_delete.append(name)
                index += 1
            except OSError:
                break
        for name in to_delete:
            winreg.DeleteValue(key, name)

        # 重写为连续编号
        for idx, pattern in enumerate(patterns, start=1):
            winreg.SetValueEx(key, str(idx), 0, winreg.REG_SZ, pattern)
    finally:
        winreg.CloseKey(key)

def restart_edge():
    subprocess.run(
        ["taskkill", "/F", "/IM", "msedge.exe"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False
    )
    subprocess.Popen(["cmd", "/c", "start", "", "msedge"])

def build_parser():
    parser = argparse.ArgumentParser(
        description="配置 Edge InsecureContentAllowedForUrls 策略"
    )
    parser.add_argument(
        "--add",
        nargs="*",
        default=[],
        help="新增 URL pattern，支持空格分隔或逗号分隔"
    )
    parser.add_argument(
        "--remove",
        nargs="*",
        default=[],
        help="删除已存在 URL pattern，支持空格分隔或逗号分隔"
    )
    parser.add_argument(
        "--restart-edge",
        type=parse_bool,
        default=False,
        help="是否自动重启 Edge（true/false），默认 false"
    )
    parser.add_argument(
        "--no-defaults",
        action="store_true",
        help="不使用默认 URL_PATTERNS，只基于注册表已有项 + 参数变更"
    )
    return parser

def main():
    parser = build_parser()
    args = parser.parse_args()

    if not is_admin():
        print("❌ 请使用【管理员权限】运行此脚本")
        sys.exit(1)

    print("🔧 正在配置 Edge 不安全内容策略...")

    existing = read_existing_patterns()
    add_patterns = parse_patterns(args.add)
    remove_patterns = set(parse_patterns(args.remove))

    base_patterns = [] if args.no_defaults else list(DEFAULT_URL_PATTERNS)
    merged = dedupe_keep_order(base_patterns + existing + add_patterns)

    final_patterns = [p for p in merged if p not in remove_patterns]

    write_patterns(final_patterns)

    print(f"  📌 原有数量: {len(existing)}")
    print(f"  ➕ 请求新增: {len(add_patterns)}")
    print(f"  ➖ 请求删除: {len(remove_patterns)}")
    print(f"  ✅ 最终写入: {len(final_patterns)}")
    for pattern in final_patterns:
        print(f"    - {pattern}")

    print("\n🎉 配置完成！")
    if args.restart_edge:
        restart_edge()
        print("👉 已自动重启 Edge")
    else:
        print("👉 可选：手动重启 Edge 让策略即时生效")
    print("👉 可访问 edge://policy 确认策略是否生效")

if __name__ == "__main__":
    main()
