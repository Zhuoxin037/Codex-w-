# -*- coding: utf-8 -*-
"""批 J2 · 为「包内还没有超限」的 32 件生成超限石 give(2026-10-23)

【★ 2026-10-23 已把 CONSUMABLE 改成 True ★】
  J2(give) -> J3(oldef) -> J4(apply + advancement) 三批走完之后, 进度链已经通了,
  石头现在是**真的能敲**: 主手石头右键 + 副手装备 -> consume_item -> apply/<id>
  -> station/api/apply(kind=overlimit) -> fit 三道门 -> 写 ol / 追加 overlimit 标签
  -> lore_refresh 改名 + 整段换描述。敲失败(fit 不过)会退材料并说明原因。
  【当日中间态】J2/J3 刚落地时 CONSUMABLE 是 False —— oldef/apply 都没有, 挂上
  就是"右键石头直接消失、什么也不发生"(静默吃物品)。以后再加新石头也照这个顺序:
  oldef + apply + advancement 齐了, 再回来把 CONSUMABLE 打开。

【lore 口径】正文 = 用户原文逐字照抄(NEW_超限➕武器.txt 的 `超限：` 段),
  只做三件事: ① 去掉段头里的「魔力 X · 冷却 Y 秒」 ② 去掉硬换行残留的「｜」
  ③ 按 lore_fmt 的 nfmt/wrap(37) 折行。**不改字、不缩写、不补数字**。
"""
import io
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, wrap, patch_text  # noqa: E402

DOC = "C:/Users/qq303/Downloads/NEW_超限➕武器.txt"
BASE = "D:/数据包/sweetdream/data/sweetdream"
ITEM = BASE + "/function/overlimit/item"
OUT_JSON = "D:/数据包/.workbuddy/_ol_j2.json"

CONSUMABLE = True    # ★ 2026-10-23 批 J4: oldef(J3) + apply/advancement(J4) 齐了, 挂上

# id -> (中文名, 底材类, CMD, 主题色 RGB)  CMD 57..88 见 _gen_stone_icons.py
META = {
    # ---- 剑 9 ----
    "yebu":           ("曳步",     "sword", 57, (150, 156, 168)),
    "rebound":        ("回锋",     "sword", 58, (232, 228, 216)),
    "tidemark":       ("潮痕",     "sword", 59, ( 94, 198, 216)),
    "grayscale":      ("灰度",     "sword", 60, (168, 168, 176)),
    "backflow_tide":  ("退汐",     "sword", 61, ( 47, 155, 184)),
    "profane":        ("剖心",     "sword", 62, (163,  39,  43)),
    "way_back":       ("归途",     "sword", 63, (224, 182,  74)),
    "gousi":          ("钩丝",     "sword", 64, ( 31, 143, 143)),
    "thunder_wedge":  ("雷楔",     "sword", 65, (232, 210,  74)),
    # ---- 斧 10 ----
    "xiugou":         ("锈犬",     "axe",   66, (197, 138,  46)),
    "draught":        ("饮鸩",     "axe",   67, (158,  43,  43)),
    "skyvault":       ("天穹",     "axe",   68, ( 94, 198, 216)),
    "frost_carve":    ("剜霜",     "axe",   69, (191, 230, 240)),
    "ballad":         ("歌谣",     "axe",   70, (232, 210,  74)),
    "chenyuan":       ("沉渊",     "axe",   71, ( 31, 143, 143)),
    "anchor":         ("沉锚",     "axe",   72, ( 74, 111, 208)),
    "scorch_bone":    ("焦骨",     "axe",   73, ( 90,  90,  90)),
    "deep_brine":     ("重溟",     "axe",   74, ( 26, 111, 143)),
    "meteor":         ("陨星",     "axe",   75, (217, 161,  60)),
    # ---- 弩 4 ----
    "backstring":     ("退弦",     "bow",   76, ( 95, 191, 106)),
    "reverse_string": ("逆弦",     "bow",   77, ( 94, 198, 216)),
    "dark_sun":       ("黯日",     "bow",   78, (163,  39,  43)),
    "dragon_tongue":  ("龙舌",     "bow",   79, (212,  74,  58)),
    # ---- 法杖 9 ----
    "five_curses":    ("五世恶咒", "staff", 80, (122,  79, 181)),
    "pour_sack":      ("倾囊",     "staff", 81, (232, 210,  74)),
    "burst_bank":     ("决堤",     "staff", 82, ( 94, 198, 216)),
    "apocalypse":     ("启示录",   "staff", 83, (224, 182,  74)),
    "fate_thread":    ("命缕",     "staff", 84, (163,  39,  43)),
    "cage_day":       ("囚昼",     "staff", 85, (122,  79, 181)),
    "fallen_dream":   ("堕梦",     "staff", 86, ( 90,  90,  90)),
    "thunderrod":     ("引雷针",   "staff", 87, (232, 210,  74)),
    "bent_ray":       ("折径",     "staff", 88, (201, 160, 232)),
}

HEAD = re.compile(r'^\[(\d{3})\]\s*(\S+?)\s+([a-z_]+)')
SEG = re.compile(r'^✦\s*([^｜]+?)｜(.*)$')
NUM = re.compile(r'^魔力\s*(?:[0-9]+|当前魔力值的\s*[0-9]+%)'
                 r'(?:\s*·\s*冷却\s*[0-9]+\s*秒)?｜?')
PLAIN = ('主动技能', '被动技能', '普攻')


def parse_doc():
    """返回 {id: {no, name, sections:[(段名, 魔力, 冷却, 正文)]}}"""
    lines = io.open(DOC, encoding='utf-8').read().split('\n')
    out, cur, grab = {}, None, False
    for raw in lines:
        s = raw.strip()
        m = HEAD.match(s)
        if m:
            no, name, uid = m.group(1), m.group(2), m.group(3)
            cur = out.setdefault(uid, {"no": no, "name": name, "sections": []})
            grab = False
            continue
        if cur is None:
            continue
        if s.startswith('超限'):
            grab = True
            s = s[2:].lstrip('：:').strip()
            if not s:
                continue
        elif not grab:
            continue
        if not s:
            if cur["sections"]:
                grab = False
            continue
        m = SEG.match(s)
        if not m:
            continue
        label, rest = m.group(1).strip(), m.group(2)
        mana, cd = None, None
        # ★ 门禁不能写 `re.match(r'^魔力\s*([0-9]+)')`: 法杖的消耗是
        #   「魔力 当前魔力值的 50%」, 数字不在第一位 ⇒ 老门禁假, 整段消耗前缀
        #   会原样留在正文里(2026-10-23 踩过: 倾囊/决堤 的石头说明出现
        #   "魔力 当前魔力值的 50%   ·   冷却 25 秒")。
        if label in PLAIN and rest.startswith('魔力'):
            mm = re.match(r'^魔力\s*(?:([0-9]+)|当前魔力值的\s*([0-9]+)%)', rest)
            if mm:
                # ★ 法杖的消耗是百分比(「当前魔力值的 50%」), 必须把**数字**留下 ——
                #   以前写成占位 'X%', oldef 的 ✦ 参数行会原样印出「当前魔力值的 X%」。
                mana = mm.group(1) or ('当前魔力值的 %s%%' % mm.group(2))
            cc = re.search(r'冷却\s*([0-9]+)\s*秒', rest[:26])
            if cc:
                cd = cc.group(1)
            rest = NUM.sub('', rest, count=1)
        rest = rest.replace('｜', '').replace('　', ' ').strip()
        rest = re.sub(r'^[·・]\s*', '', rest)          # 法杖「普攻」段的 "·   伤害 X"
        if rest and rest[-1] not in '。！？':
            rest += '。'
        cur["sections"].append((label, mana, cd, rest))
    return out


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def stone_body(name, sections):
    parts = ["敲入后%s更名为「超限·%s」，" % (name, name)]
    for (label, _m, _c, body) in sections:
        if not body.endswith('。'):
            body += '。'
        if label in PLAIN:
            parts.append("%s变为：%s" % (label, body))
        else:
            parts.append("「%s」变为：%s" % (label, body))
    return "".join(parts)


def lore_json(name, body):
    out = [
        '{"text":"✦ 超限石","color":"gold","bold":true,"italic":false}',
        '{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},'
        '{"text":"%s","color":"blue"},{"text":"   ·   ","color":"dark_gray"},'
        '{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]}' % name,
        '{"text":" ","italic":false}',
    ]
    for line in wrap(nfmt(body), 37):
        out.append('{"text":"%s","color":"gray","italic":false}' % esc(line))
    return "[" + ",".join(out) + "]"


def item_txt(uid, name, cmd, body):
    cons = ('consumable={animation:"none",consume_seconds:0,has_consume_particles:false,'
            'sound:"block.bamboo_wood_button.click_off"}' if CONSUMABLE else '')
    note = ("# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;\n"
            "#   进度 consume_item -> overlimit/apply/%s -> station/api/apply 校验/改名/换描述。"
            % uid if CONSUMABLE else
            "# 【consumable】本轮不挂 —— 石头是惰性的, 右键不会掉物品。")
    hint = ("#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。"
            if CONSUMABLE else
            "#   三件套(advancement + apply + oldef)补齐后改 CONSUMABLE=True 重跑。")
    status = ("# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。"
              if CONSUMABLE else
              "# 【状态】2026-10-23 批 J2 第一步: 只出 give + 图标。")
    return (
        "# ============================================================\n"
        "# sweetdream:overlimit/item/%s —— 给一块「超限·%s」\n"
        "# ------------------------------------------------------------\n"
        "# 【custom_data】只写一个标记 ol_%s :\n"
        "#   进度 advancement/overlimit/%s 靠它认\"右键用掉了哪块超限石\"。\n"
        "# 【底座】recovery_compass + custom_model_data={floats:[%d.0f]}(八芒星, 编号 %d)。\n"
        "#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。\n"
        "# 【适用】只有「%s」能敲(见 overlimit/api/fit: 副手 zx 必须含 %s 且还没敲过 ol)。\n"
        "%s\n"
        "%s\n"
        "%s\n"
        "%s\n"
        "# ============================================================\n"
        "\n"
        "give @s recovery_compass[max_stack_size=1,item_name={text:\"超限·%s\",bold:true,color:light_purple},"
        "custom_model_data={floats:[%d.0f]},lore=%s,"
        "custom_data={zx:[\"ol_%s\"]}%s]\n"
    ) % (uid, name, uid, uid, cmd, cmd, name, uid,
         status, note, hint,
         "#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。",
         name, cmd, lore_json(name, body), uid,
         ("," + cons) if CONSUMABLE else "")


def main():
    doc = parse_doc()
    miss = [i for i in META if i not in doc]
    if miss:
        print("!! 文档里找不到:", miss)
    os.makedirs(ITEM, exist_ok=True)
    table = {}
    for uid, (name, cat, cmd, rgb) in META.items():
        d = doc[uid]
        secs = d["sections"]
        body = stone_body(name, secs)
        txt = item_txt(uid, name, cmd, body)
        # ★ 最后再过一遍 lore_fmt.patch_text(2026-10-23): 我们自己 wrap(37) 的
        #   避头尾规则和规范器不完全一致 —— 断在「。」之后时, 规范器会把下一句的
        #   头几个字拽回本行(五个恶咒那块石头就是这么被判"版式不对"的)。
        #   patch_text 是 check.py 规则 31 的口径, 过了它才算合规, 而且它只重排
        #   行、不改字, 所以 stone_body 的逐字校验不受影响。
        txt, _n = patch_text(txt)
        io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(txt)
        table[uid] = {"no": d["no"], "name": name, "cat": cat, "cmd": cmd,
                      "rgb": list(rgb), "sections": secs, "stone_body": body,
                      "lore_lines": len(wrap(nfmt(body), 37))}
        print("ok %-15s %-3s %-6s cmd=%-3d 段数=%d 折行=%d" %
              (uid, d["no"], name, cmd, len(secs), table[uid]["lore_lines"]))
    io.open(OUT_JSON, "w", encoding="utf-8").write(
        json.dumps(table, ensure_ascii=False, indent=1) + "\n")
    print("写法:", len(table), "-> ", OUT_JSON)


if __name__ == '__main__':
    main()
