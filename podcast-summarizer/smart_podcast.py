#!/usr/bin/env python3
"""
智能播客/视频处理器
- 下载音频 (yt-dlp)
- 语音转文字 (whisper)
- AI 智能分析 + 定制化翻译总结 (Claude API)

用法:
  python smart_podcast.py -u <URL>           # 从 URL 下载并处理
  python smart_podcast.py -f <文件路径>       # 处理本地文件（视频/音频/文本）
"""

import argparse
import subprocess                                                                                                                                                     
import sys
import os
import re
import json
import urllib.request
from pathlib import Path


# 文本文件后缀（跳过转写，直接总结）
TEXT_EXTS = {'.txt', '.srt', '.vtt'}


# ============================================================
#                       环境检测模块
# ============================================================

def run_silent(cmd: list[str]) -> bool:
    """静默运行命令，返回是否成功"""
    try:
        subprocess.run(cmd, capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def check_conda_env(env_name: str) -> bool:
    """检查 conda 环境是否存在"""
    try:
        result = subprocess.run(
            ["conda", "env", "list"],
            capture_output=True, text=True
        )
        return env_name in result.stdout
    except FileNotFoundError:
        return False


def check_whisper_in_conda() -> bool:
    """检查 whisper 环境中是否安装了 openai-whisper"""
    try:
        subprocess.run(
            ["conda", "run", "-n", "whisper", "pip", "show", "openai-whisper"],
            capture_output=True, check=True
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def check_environment() -> dict:
    """检查所有依赖"""
    results = {}
    
    checks = [
        ("conda", ["conda", "--version"], "brew install miniforge && conda init zsh"),
        ("yt-dlp", ["yt-dlp", "--version"], "brew install yt-dlp"),
        ("ffmpeg", ["ffmpeg", "-version"], "brew install ffmpeg"),
    ]
    
    for name, cmd, hint in checks:
        results[name] = {"ok": run_silent(cmd), "hint": hint}
    
    results["conda:whisper"] = {
        "ok": check_conda_env("whisper"),
        "hint": "conda create -n whisper python=3.10 -y"
    }
    
    if results["conda:whisper"]["ok"]:
        results["whisper"] = {
            "ok": check_whisper_in_conda(),
            "hint": "conda run -n whisper pip install openai-whisper"
        }
    else:
        results["whisper"] = {"ok": False, "hint": "先创建 conda:whisper 环境"}
    
    results["ANTHROPIC_API_KEY"] = {
        "ok": bool(os.environ.get("ANTHROPIC_API_KEY")),
        "hint": "export ANTHROPIC_API_KEY='your-key'  # 添加到 ~/.zshrc"
    }
    
    return results


def print_check_results(results: dict) -> list[str]:
    """打印检测结果，返回失败项"""
    print("\n🔍 环境检测\n" + "─" * 45)
    
    failed = []
    for name, status in results.items():
        icon = "✅" if status["ok"] else "❌"
        print(f"  {icon} {name}")
        if not status["ok"]:
            failed.append(name)
    
    print("─" * 45)
    return failed


def prompt_install(results: dict, failed: list[str]) -> bool:
    """提示用户处理缺失依赖"""
    if not failed:
        print("✅ 环境检测通过\n")
        return True
    
    print(f"\n⚠️  检测到 {len(failed)} 个问题:\n")
    for name in failed:
        print(f"   • {name}")
        print(f"     👉 {results[name]['hint']}\n")
    
    print("请选择:")
    print("  [i] 显示安装命令")
    print("  [c] 忽略继续（可能出错）")
    print("  [q] 退出")
    
    while True:
        choice = input("\n请输入选项 [i/c/q]: ").strip().lower()
        
        if choice == 'q':
            print("👋 已退出")
            return False
        elif choice == 'i':
            print("\n📋 请依次执行以下命令:\n" + "─" * 45)
            for name in failed:
                print(f"# {name}")
                print(f"{results[name]['hint']}\n")
            print("─" * 45 + "\n安装完成后请重新运行脚本")
            return False
        elif choice == 'c':
            print("⚠️  继续执行，可能遇到错误...\n")
            return True


def ensure_environment() -> bool:
    """环境检测主入口"""
    results = check_environment()
    failed = print_check_results(results)
    return prompt_install(results, failed)


# ============================================================
#                       Claude API 模块
# ============================================================

def call_claude(prompt: str, max_tokens: int = 4096) -> str:
    """使用标准库调用 Claude API（零依赖）"""
    
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise ValueError("ANTHROPIC_API_KEY 未设置")
    
    url = "https://api.longcat.chat/anthropic/v1/messages"
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "anthropic-version": "2023-06-01"
    }
    
    data = {
        "model": "LongCat-Flash-Chat",
        "max_tokens": max_tokens,
        "messages": [{"role": "user", "content": prompt}]
    }
    
    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode('utf-8'),
        headers=headers,
        method='POST'
    )
    
    try:
        with urllib.request.urlopen(req, timeout=300) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result["content"][0]["text"]
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise RuntimeError(f"API 错误 {e.code}: {error_body}")


# ============================================================
#                       核心处理流程
# ============================================================

def download_audio(url: str, output_dir: str = "./downloads") -> str:
    """使用 yt-dlp 下载音频（显示进度）"""
    Path(output_dir).mkdir(exist_ok=True)
    
    cmd = [
        "yt-dlp",
        "-x", "--audio-format", "mp3",
        "--cookies-from-browser", "chrome",
        "--restrict-filenames",          # 限制文件名为安全字符（ASCII，无空格/特殊字符）
        "--progress",                      # 显示进度
        "--newline",                       # 每次进度更新换行（避免刻覆盖问题）
        "-o", f"{output_dir}/%(title)s.%(ext)s",
        "--print", "after_move:filepath",
        url
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    audio_path = result.stdout.strip().split('\n')[-1]
    return audio_path


def transcribe_media(media_path: str, model: str = "medium", language: str = None) -> str:
    """
    使用 conda 环境中的 whisper 转写
    支持视频和音频文件（whisper 通过 ffmpeg 自动处理）
    
    Args:
        media_path: 媒体文件路径
        model: whisper 模型大小
        language: 音频语言（如 English, Chinese, Japanese 等），None 表示自动检测
    """
    media = Path(media_path)
    output_dir = media.parent
    output_txt = output_dir / f"{media.stem}.txt"
    
    cmd = [
        "conda", "run", "--no-capture-output", "-n", "whisper",
        "whisper", str(media),
        "--model", model,
        "--output_format", "txt",
        "--output_dir", str(output_dir)
    ]
    
    if language:
        cmd.extend(["--language", language])
    
    # 实时输出 Whisper 进度
    process = subprocess.Popen(
        cmd,
        stdout=sys.stdout,
        stderr=sys.stderr,
        bufsize=1
    )
    process.wait()
    
    # 检查输出文件是否真的生成了
    if process.returncode != 0 or not output_txt.exists():
        raise RuntimeError(f"Whisper 转写失败，文件未生成: {output_txt}")
    
    return str(output_txt)


def is_text_file(file_path: str) -> bool:
    """判断是否为文本文件"""
    return Path(file_path).suffix.lower() in TEXT_EXTS


def smart_summarize(transcript_path: str) -> str:
    """两阶段 AI 处理：分析内容 → 定制化处理"""
    
    with open(transcript_path, 'r') as f:
        transcript = f.read()
    
    # ===== 阶段 1: 分析内容，生成定制 Prompt =====
    print("   🔍 分析内容类型...")
    
    sample = transcript[:3000]
    analysis_prompt = f"""分析这段英文文本，生成最适合的中文处理 Prompt。

文本样本（前 3000 字符）：
---
{sample}
---

请输出：

## 内容分析
- 类型：（访谈/演讲/播客对话/教程/...）
- 嘉宾身份：（作家/创业者/技术专家/...）
- 内容特点：（观点密集/故事性强/信息琐碎/技术干货/...）

## 处理策略
（一句话说明为什么选择这个策略）

<prompt>
（用于处理全文的具体指令，要求输出中文。
  根据内容特点决定：是逐段翻译、提炼观点、结构化笔记、还是其他方式）
</prompt>
"""
    
    analysis_result = call_claude(analysis_prompt, max_tokens=1000)
    
    analysis_display = analysis_result.split('<prompt>')[0].strip()
    print(f"\n{analysis_display}\n")
    
    # ===== 阶段 2: 使用定制 Prompt 处理全文 =====
    print("   ✍️  执行定制处理...")
    
    prompt_match = re.search(r'<prompt>(.*?)</prompt>', analysis_result, re.DOTALL)
    if prompt_match:
        custom_prompt = prompt_match.group(1).strip()
    else:
        custom_prompt = "请将以下英文内容翻译成中文，并总结核心观点。"
    
    final_prompt = f"""{custom_prompt}

原文内容：
---
{transcript}
---
"""
    
    final_result = call_claude(final_prompt, max_tokens=8192)
    
    # ===== 保存结果 =====
    output_path = Path(transcript_path).with_suffix('.summary.md')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(f"# 处理报告\n\n")
        f.write(f"{analysis_display}\n\n")
        f.write(f"---\n\n")
        f.write(final_result)
    
    return str(output_path)


# ============================================================
#                       命令行参数解析
# ============================================================

def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description="智能播客/视频处理器 - 下载、转写、翻译总结一条龙",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s -c                                         # 检查环境配置
  %(prog)s -u "https://www.youtube.com/watch?v=xxx"   # 处理 YouTube 视频
  %(prog)s -f ~/Downloads/interview.mp4               # 处理本地视频
  %(prog)s -f ~/Downloads/podcast.mp3                 # 处理本地音频
  %(prog)s -f ~/Downloads/transcript.txt              # 直接处理文本
  %(prog)s -u "URL" -l Chinese                        # 指定音频语言为中文
        """
    )
    
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "-c", "--check",
        action="store_true",
        help="仅检查环境配置是否完整"
    )
    group.add_argument(
        "-u", "--url",
        metavar="URL",
        help="视频/音频 URL（支持 YouTube 等 yt-dlp 支持的站点）"
    )
    group.add_argument(
        "-f", "--file",
        metavar="FILE",
        help="本地文件路径（视频/音频 → 转写+总结，文本 → 直接总结）"
    )
    
    parser.add_argument(
        "-l", "--language",
        metavar="LANG",
        help="音频语言（如 English, Chinese, Japanese），不指定则自动检测"
    )
    
    return parser.parse_args()


# ============================================================
#                           主程序
# ============================================================

def main():
    print("""
╔═══════════════════════════════════════════╗
║     🎙️  智能播客/视频处理器                ║
║     yt-dlp + whisper + Claude             ║
╚═══════════════════════════════════════════╝
    """)
    
    # 1. 解析参数
    args = parse_args()
    
    # 2. 仅检查环境模式
    if args.check:
        if ensure_environment():
            sys.exit(0)
        else:
            sys.exit(1)
    
    # 3. 环境检测
    if not ensure_environment():
        sys.exit(1)
    
    try:
        # ========== 模式 A: URL 输入 ==========
        if args.url:
            print(f"📥 输入: URL\n")
            
            # 下载
            print("🎵 [1/3] 下载音频...")
            media_path = download_audio(args.url)
            print(f"   ✅ {media_path}\n")
            
            # 转写
            lang_hint = f"（语言: {args.language}）" if args.language else "（自动检测语言）"
            print(f"📝 [2/3] Whisper 转写{lang_hint}...")
            transcript_path = transcribe_media(media_path, language=args.language)
            print(f"   ✅ {transcript_path}\n")
            
            # 总结
            print("🤖 [3/3] AI 智能分析...")
            output_path = smart_summarize(transcript_path)
            
            print(f"""
╔═══════════════════════════════════════════╗
║  🎉 处理完成！                             ║
╚═══════════════════════════════════════════╝

📁 媒体: {media_path}
📄 转写: {transcript_path}
📋 总结: {output_path}
            """)
        
        # ========== 模式 B: 本地文件输入 ==========
        elif args.file:
            file_path = Path(args.file).expanduser().resolve()
            
            if not file_path.exists():
                print(f"❌ 文件不存在: {file_path}")
                sys.exit(1)
            
            # B1: 文本文件 → 跳过转写，直接总结
            if is_text_file(str(file_path)):
                print(f"📥 输入: 文本文件（跳过转写）\n")
                
                print("🤖 [1/1] AI 智能分析...")
                output_path = smart_summarize(str(file_path))
                
                print(f"""
╔═══════════════════════════════════════════╗
║  🎉 处理完成！                             ║
╚═══════════════════════════════════════════╝

📄 输入: {file_path}
📋 总结: {output_path}
                """)
            
            # B2: 视频/音频文件 → 转写 + 总结
            else:
                print(f"📥 输入: 媒体文件\n")
                
                lang_hint = f"（语言: {args.language}）" if args.language else "（自动检测语言）"
                print(f"📝 [1/2] Whisper 转写{lang_hint}...")
                transcript_path = transcribe_media(str(file_path), language=args.language)
                print(f"   ✅ {transcript_path}\n")
                
                print("🤖 [2/2] AI 智能分析...")
                output_path = smart_summarize(transcript_path)
                
                print(f"""
╔═══════════════════════════════════════════╗
║  🎉 处理完成！                             ║
╚═══════════════════════════════════════════╝

📁 媒体: {file_path}
📄 转写: {transcript_path}
📋 总结: {output_path}
                """)
        
    except subprocess.CalledProcessError as e:
        print(f"\n❌ 命令执行失败: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 已取消操作")
        sys.exit(130)
