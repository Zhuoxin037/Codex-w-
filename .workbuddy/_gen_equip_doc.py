# -*- coding: utf-8 -*-
"""生成《坠梦 · 武器及装备总表》markdown（164 件已实装 + 批十九 20 件设计稿）。"""
import json, re, io, os

EQ = json.load(open(r"D:/数据包/.workbuddy/_equip_all.json", encoding="utf-8"))

# ---- 标签词表（真源 _tags_data.py 的 VOCAB 结构）----
VOCAB = [
    ("liuhuo", "状态", "流火"), ("yehuo", "状态", "夜火"), ("shixin", "状态", "噬心"),
    ("yuanhai", "状态", "渊海"), ("dream", "状态", "白昼梦"),
    ("max_hp", "数值", "最大生命值"), ("base_atk", "数值", "基础攻击力"),
    ("max_mana", "数值", "最大魔力值"), ("cur_mana", "数值", "当前魔力值"),
    ("true_dmg", "数值", "真实伤害"), ("flat", "数值", "固定值"),
    ("debuff", "机制", "削弱"), ("heal", "机制", "治疗"), ("consume", "机制", "消耗"),
    ("apply", "机制", "附加"), ("buff", "机制", "增益"), ("cd_down", "机制", "减冷却"),
    ("indep_mul", "机制", "独立乘区"), ("summon", "机制", "召唤物"), ("dash", "机制", "位移"),
    ("attract", "机制", "吸引"), ("field", "机制", "领域"), ("formation", "机制", "术阵"),
    ("timestop", "机制", "时停"), ("freeze", "机制", "冰冻"), ("slow", "机制", "减速"),
    ("lightning", "机制", "闪电"),
    ("overlimit", "超限", "超限"),
]
TAG_CN = {k: cn for k, _, cn in VOCAB}
TAG_GRP = {k: g for k, g, _ in VOCAB}

SLOT_CN = {"head": "头盔", "chest": "胸甲", "legs": "护腿", "feet": "靴子"}
CAT_ORDER = ["sword", "axe", "bow", "staff", "armor", "tool"]


def tagstr(tags):
    return " / ".join(f"{TAG_CN.get(t, t)} {t}" for t in tags) if tags else "—"


def summary(lore, n=90):
    s = lore.split("\n")[0]
    s = re.sub(r"^✦\s*", "", s).strip()
    s = re.sub(r"^被动技能", "", s).strip()
    s = re.sub(r"\s+", "", s)
    return (s[:n] + "…") if len(s) > n else (s or "—")


L = []
w = L.append
w("# 坠梦 · Fall Into the Dream —— 武器及装备总表")
w("")
w("> Minecraft Java 1.21.5 原版数据包 · V0.1.0")
w("> 生成时间：2026-10-21 ｜ 数据源：`sweetdream/data/sweetdream/function/equipment/**/give.mcfunction`（实机 give 真源，逐件解析）")
w("")
w("**本表共 184 条** = 已实装 **164 件** ＋ 批十九设计稿 **20 件**（未实装，附录单列）。")
w("")
w("字段口径：")
w("")
w("- **阶段**由 give 底材判定（本包没有等级字段，`rarity`、合成配方均无，阶段唯一载体就是底材）：铁=开局 ／ 钻=过渡 ／ 下界=终端 ／ 未分档=法杖·弩·副手底物无材质档。")
w("- **英文 ID** = `custom_data.zx[0]`，即进度与被动判定认人的装备 id。")
w("- **标签** = `custom_data.tags`，格式为「中文 英文」，词表见 §一。")
w("- **机制摘要** 为 lore 被动段压缩，完整描述以游戏内物品说明为准。")
w("")

# ---------- 一、标签词表 ----------
w("## 一、标签词表（%d 词 · 中英对照）" % len(VOCAB))
w("")
w("| 分组 | 中文 | 英文 tag |")
w("|---|---|---|")
for k, g, cn in VOCAB:
    w(f"| {g} | {cn} | `{k}` |")
w("")

# ---------- 二、装备总表 ----------
w("## 二、已实装装备总表（164 件）")
w("")
from collections import Counter
w("| 类型 | 件数 |")
w("|---|---|")
cnt = Counter(x["cat_cn"] for x in EQ)
for c in ["剑", "斧", "弩", "法杖", "盔甲", "副手"]:
    w(f"| {c} | {cnt.get(c,0)} |")
w(f"| **合计** | **{len(EQ)}** |")
w("")

for cat in CAT_ORDER:
    rows = [x for x in EQ if x["cat"] == cat]
    rows.sort(key=lambda x: (x["stage"], x["mat"], x["name"]))
    w(f"### {rows[0]['cat_cn']}（{len(rows)} 件）")
    w("")
    w("| # | 中文名 | 英文 ID | 底材 | 阶段 | 槽位 | 名称色 | 标签（中 / 英） | 机制摘要 |")
    w("|---|---|---|---|---|---|---|---|---|")
    for i, x in enumerate(rows, 1):
        slot = SLOT_CN.get(x["slot"], "—") if cat == "armor" else "—"
        w(f"| {i} | {x['name']} | `{x['id']}` | `{x['mat']}` | {x['stage']} | {slot} | "
          f"{x['rarity'] or '—'} | {tagstr(x['tags'])} | {summary(x['lore'])} |")
    w("")

# ---------- 三、附录 批十九 ----------
B19 = [
    ("积薪", "jixin", "头 · 下界", "+160", "基础攻击力 +3", "liuhuo / max_mana / base_atk"),
    ("播火", "bohuo", "胸 · 下界", "+180", "生命 +10、护甲 +2", "liuhuo / apply / debuff"),
    ("敛芒", "lianmang", "胸 · 下界", "+180", "生命 +12", "yehuo / max_mana / buff"),
    ("掌灯", "zhangdeng", "靴 · 下界", "+140", "移动速度 +8%", "yehuo / consume / cur_mana"),
    ("刻契", "keqi", "头 · 下界", "+160", "基础攻击力 +4", "shixin / true_dmg / base_atk"),
    ("嫁祸", "jiahuo", "腿 · 下界", "+200", "护甲 +3", "shixin / true_dmg / debuff"),
    ("伏流", "fuliu", "胸 · 下界", "+180", "护甲 +3", "yuanhai / apply / max_mana"),
    ("引潮", "yinchao", "腿 · 下界", "+190", "生命 +8", "yuanhai / cur_mana / apply"),
    ("偷生", "tousheng", "头 · 下界", "+160", "生命 +8", "dream / timestop / buff"),
    ("遗痕", "yihen", "靴 · 下界", "+140", "移动速度 +10%", "dream / timestop / true_dmg"),
    ("旧伤", "jiushang", "头 · 下界", "+140", "生命 +10", "heal / max_hp"),
    ("代罪", "daizui", "胸 · 下界", "+180", "护甲 +3", "summon / max_hp / debuff"),
    ("落霜", "luoshuang", "腿 · 下界", "+200", "护甲 +2", "freeze / debuff / field"),
    ("乘流", "chengliu", "靴 · 下界", "+140", "移速 +3%/100 蓝", "cur_mana / buff / dash"),
    ("镇岳", "zhenyue", "主手 · mace", "0", "每层岳势 基础攻击力 +2（最多 +6）", "flat / dash / debuff"),
    ("湿痕", "shihen", "钻腿", "+120", "护甲 +2", "yuanhai / apply"),
    ("浪蚀", "langshi", "钻靴", "+80", "移动速度 +5%", "yuanhai / debuff"),
    ("窥隙", "kuixi", "钻头", "+100", "基础攻击力 +2", "debuff / base_atk"),
    ("轻装", "qingzhuang", "铁头", "+40", "迅捷（机制内）", "buff / dash"),
    ("远行", "yuanxing", "铁腿", "+60", "生命 +4", "cur_mana / buff"),
]
w("## 三、附录 · 批十九设计稿 20 件（**尚未实装**）")
w("")
w("> 来源：`.workbuddy/批次19_终端五套_20261021.md`（2026-10-21 第六版 §三 全部重写）。")
w("> 状态：**设计稿，未进数据包**，表中没有 give 文件，故不计入 §二 的 164 件。")
w("> **这 20 件尚未定英文 ID**（`custom_data.zx` 未写入），故本表**只列中文名**；")
w("> 实装时需按包内先例取英文 id，并与现有 164 件查重后再落 give。")
w("")
w("| # | 中文名 | 槽位 · 阶段 | 魔力上限 | 属性 | 标签（中 / 英） |")
w("|---|---|---|---|---|---|")
for i, (nm, eid, slot, cap, attr, tg) in enumerate(B19, 1):
    tgs = [t.strip() for t in tg.split("/")]
    w(f"| {i} | {nm} | {slot} | {cap} | {attr} | {tagstr(tgs)} |")
w("")

# ---------- 四、标签覆盖统计 ----------
w("## 四、标签覆盖统计（164 件实装件）")
w("")
c = Counter(t for x in EQ for t in x["tags"])
w("| 中文 | 英文 tag | 分组 | 件数 |")
w("|---|---|---|---|")
for k, cn in sorted(((k, v) for k, v in TAG_CN.items()), key=lambda kv: -c.get(kv[0], 0)):
    w(f"| {cn} | `{k}` | {TAG_GRP[k]} | {c.get(k,0)} |")
w("")
w(f"- 标签总打点数：**{sum(c.values())}**")
w(f"- 无标签件：**{sum(1 for x in EQ if not x['tags'])}** "
  f"（{'、'.join(x['name'] for x in EQ if not x['tags']) or '无'}）")
w(f"- 挂技能函数（`custom_data.skill`）的件：**{sum(1 for x in EQ if x['skill'])}**")
w("")

out = "\n".join(L)
p = r"D:/数据包/.workbuddy/装备总表_20261021.md"
open(p, "w", encoding="utf-8").write(out)
print("written", p, len(out))
