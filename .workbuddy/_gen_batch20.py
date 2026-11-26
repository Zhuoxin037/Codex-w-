# -*- coding: utf-8 -*-
"""
批 20（2026-10-27）：胜利誓约之剑 + 白昼梦后续 8 件终端盔甲（枢/承/空营/独行/溢流/蓄意/踏空/屏息）

【lore 折行】不手工折 —— 全部交给 lore_fmt.rebuild（默认 37 半角宽），
生成完再跑 `python lore_fmt.py`（干跑）必须 0 变化。

用法：
    python .workbuddy/_gen_batch20.py            # 干跑，只打印
    python .workbuddy/_gen_batch20.py --write    # 写文件
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import rebuild, json_to_snbt  # noqa: E402

ROOT = r"D:\数据包\fallendream\data\fallendream\function\equipment"
BASE = ROOT

EQ_SLOT = {"helmet": "head", "chestplate": "chest", "leggings": "legs", "boots": "feet"}
ARMOR_SOUND = {"iron": "minecraft:item.armor.equip_iron",
               "diamond": "minecraft:item.armor.equip_diamond",
               "netherite": "minecraft:item.armor.equip_netherite"}


def H(t):
    return {"text": t, "color": "gold", "bold": True, "italic": False}


def B(t):
    return {"text": t, "color": "gray", "italic": False}


def SP():
    return {"text": " ", "italic": False}


def COST(mana, cd):
    return {"text": "", "italic": False, "extra": [
        {"text": "魔力 ", "color": "gray"},
        {"text": str(mana), "color": "aqua"},
        {"text": "   ·   ", "color": "dark_gray"},
        {"text": "冷却 ", "color": "gray"},
        {"text": str(cd), "color": "yellow"},
    ]}


def _is_head(e):
    return bool(e.get("bold")) and str(e.get("text", "")).startswith("✦")


def _is_space(e):
    return "extra" not in e and str(e.get("text", "")).strip() == ""


def pad_sections(lore):
    out = []
    for e in lore:
        if _is_head(e) and out and not _is_space(out[-1]):
            out.append(SP())
        out.append(e)
    return out


# ============================================================
# 胜利誓约｜传说｜剑
# ============================================================
SWORD_NOTE = """# ============================================================
# fallendream:equipment/sword/oath_victory/give —— 给一件「胜利誓约」（传说 · 剑）
# ------------------------------------------------------------
# 【custom_data】"oath_victory" -> 装备 id; 判定一律写 custom_data~{zx:["oath_victory"]}
# 【被动】每次普攻命中生物后 20% 概率 +5 点临时生命值（走 lib/thp，硬上限 最大生命×2）。
#   触发口 = 进度 player_hurt_entity（只算平A），同刻去重 zx.ov_lt。
# 【主动】200 魔力 / 10 秒：突击到 5 格内生物背后 + 基础攻击力 ×5 伤害，
#   停留处展开半径 3 / 6 秒领域；自身在领域内每秒恢复 3 点生命 + 20% 最大生命的临时生命。
# 【★ 实装必读 ★】
#   ① 突击用 `at <target> rotated as <target> run tp @s ^ ^ ^-1.5` —— `at` 只换位置
#      基点、`rotated as` 只换朝向, `^` 的原点因此落在目标处、方向是目标背后。
#      **不要**读 Pos 自己算（精度差且多一次 NBT）。
#   ② 领域是地面上的区域：施法者走开就拿不到回复 ⇒ field_tick 每秒用 lib/u_by 反查
#      施法者并判 3 格距离，**不是**"给玩家挂计时"。
#   ③ 领域必须占 1 个术阵位（包内口径：领域 = 范围增益/减益）—— 但本件文案没写术阵，
#      故按「领域」实现，不登记 manacore 术阵（与神裁同款口径，见 verdict）。
# 【外观】已画（2026-10-27）。图标唯一真相来源 `.workbuddy/_gen_oath_victory_icon.py`：
#   骨架 hengdao + 分区换色（香槟金白刃 / 亮金护手 / 宝石红柄）+ 柄尾金坠。
#   三层链路：items/oath_victory.json → models/item/vanilla/oath_victory.json → 贴图。
# ============================================================"""

SWORD_LORE = [
    H("✦ 被动技能"),
    B("每次普攻命中生物后，有 20% 的概率使自身获得 5 点临时生命值。"),
    H("✦ 主动技能"),
    COST(200, "10 秒"),
    B("使用后立即突击到自身 5 格内的生物后方，并对其造成一次相当于自身基础攻击力 ×5 的伤害。之后自身在停留处展开一个半径 3 格、持续 6 秒的领域，自身在领域内时每秒恢复 3 点生命值并获得相当于自身最大生命值 ×0.2 的临时生命值。"),
]

# ============================================================
# 枢｜史诗｜头盔
# ============================================================
PIVOT_NOTE = """# ============================================================
# fallendream:equipment/armor/pivot/give —— 给一件「枢」（史诗 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"pivot" -> 装备 id; 判定写 custom_data~{zx:["pivot"]}
# 【机制】魔力值上限 +120；术阵位上限 +1。
# 【★ 术阵位上限只能走 stats.formation_limit ★】前置包 formation/create 就是按
#   `stats.formation_limit` 判满没满 ⇒ 用 manacore:api/stats/add ±1 改它，
#   **不要**自己去数 formations 有几个（那是占用数，不是上限）。
#   差值账本 zx.pv_lim：0 = 没加 / 1 = 已加 1，穿上加、脱下减，避免重登叠加。
# 【外观】尚未画。
# ============================================================"""

PIVOT_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +120。自身术阵位上限 +1。"),
]

# ============================================================
# 承｜史诗｜护腿
# ============================================================
BEARING_NOTE = """# ============================================================
# fallendream:equipment/armor/bearing/give —— 给一件「承」（史诗 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"bearing" -> 装备 id; 判定写 custom_data~{zx:["bearing"]}
# 【机制】魔力 +140；每占 1 术阵位 → 护甲 +2 / 韧性 +1（最多 3 层）；术阵为空时移速 +6%。
#   套装（枢 + 承）：术阵位全满 → 8 秒「阵成」（技能伤害 +15% 独立乘区 / 技能冷却 −10%）；
#   术阵自然结束或主动归还时返还 25 魔力；每 12 秒最多进入一次。
# 【★ 实装必读 ★】
#   ① 层数 = min(zx.fm_u, 3)，每秒重算（lib/fm/read 提供），用差值账本 zx.br_a / zx.br_t
#      换档 —— `attribute … modifier add` 同 id 重复会失败，必须先 remove。
#   ② 「阵成」的"技能冷却 −10%"**不能**写 stats.cooldown_reduction：那条属性被
#      upgrade/api/cd_stat 独占（它每秒整体覆盖）。改走 cooldown_start 事件，
#      对**刚进入冷却的那个技能** reduce 掉剩余时长的 10%（见 on_cast）。
#   ③ "术阵自然结束或主动归还时返还 25 魔力" ⇒ 挂在 #manacore:event/formation_remove 上。
#   ④ 「阵成」= 从"未满"变"满"的那一刻，不是"满着就一直触发"。
# 【外观】尚未画。
# ============================================================"""

BEARING_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +140。每占用 1 个术阵位，自身护甲值 +2、护甲韧性 +1（最多 3 层）。自身术阵为空时，移动速度 +6%。"),
    H("✦ 套装效果"),
    B("● 枢"),
    B("● 承"),
    SP(),
    B("术阵位全满时获得 8 秒「阵成」：技能伤害 +15%（独立乘区），技能冷却 -10%。术阵自然结束或被主动归还时，返还 25 点魔力值。每 12 秒最多进入一次「阵成」。"),
]

# ============================================================
# 空营｜史诗｜胸甲
# ============================================================
CAMP_NOTE = """# ============================================================
# fallendream:equipment/armor/empty_camp/give —— 给一件「空营」（史诗 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"empty_camp" -> 装备 id; 判定写 custom_data~{zx:["empty_camp"]}
# 【机制】魔力 +140；8 格内每 1 个敌对生物 → 护甲 +1 / 韧性 +0.5（最多 6 层）；
#   8 格内没有敌对生物 → 每秒回 3 魔力。
# 【★ 敌对生物口径 ★】`@e[type=!#fallendream:no_damage,distance=..8]`，与包内其余
#   AOE 选择器一致（排除 marker/法球/领域等无伤害实体）。每秒数一次，别每刻数。
# 【外观】尚未画。
# ============================================================"""

CAMP_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +140。自身 8 格内每有 1 个敌对生物，护甲值 +1、护甲韧性 +0.5（最多 6 层）。8 格内没有敌对生物时，每秒恢复 3 点魔力值。"),
]

# ============================================================
# 独行｜史诗｜靴子
# ============================================================
LONE_NOTE = """# ============================================================
# fallendream:equipment/armor/lone_walk/give —— 给一件「独行」（史诗 · 靴子）
# ------------------------------------------------------------
# 【custom_data】"lone_walk" -> 装备 id; 判定写 custom_data~{zx:["lone_walk"]}
# 【机制】魔力 +120 / 移速 +8%；8 格内敌对 ≤2 → 技能伤害 +8%；
#   套装（空营 + 独行）：8 格内敌对数量变化 → 4 秒「临敌」（护甲 +4 / 技能伤害 +10% 独立乘区），
#   每 16 秒最多触发一次。
# 【★ 两种乘区口径 ★】
#   ① "技能伤害 +8%"（没有写独立乘区） ⇒ 走加算池（lib/dmg_add_put，三条通道各加 8）
#      = 整体 +8%，非独立。
#   ② 套装「临敌」明写独立乘区 ⇒ 走 mul_pct 乘最终 damage（同 glimmer/hook_calc）。
#   两者都在同一个 hook_calc 里按顺序做。
# 【外观】尚未画。
# ============================================================"""

LONE_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +120，移动速度 +8%。自身 8 格内敌对生物不超过 2 个时，技能伤害 +8%。"),
    H("✦ 套装效果"),
    B("● 空营"),
    B("● 独行"),
    SP(),
    B("8 格内敌对生物数量变化时，获得 4 秒「临敌」：护甲值 +4、技能伤害 +10%（独立乘区）。每 16 秒最多触发一次。"),
]

# ============================================================
# 溢流｜罕见｜护腿
# ============================================================
OVERFLOW_NOTE = """# ============================================================
# fallendream:equipment/armor/overflow/give —— 给一件「溢流」（罕见 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"overflow" -> 装备 id; 判定写 custom_data~{zx:["overflow"]}
# 【机制】魔力 +80 / 最大生命 +4；被过量治疗后 50% 溢出量转临时生命（上限 最大生命×2）。
# 【★ 过量怎么算 ★】hook 在 lib/heal 的出口：#heal_pt（请求量）− #heal_got（实得）。
#   只覆盖本包 lib/heal 这条治疗链 —— 原版再生/瞬治满血时本来就不溢出，影响可忽略。
# 【外观】尚未画。
# ============================================================"""

OVERFLOW_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +80，最大生命值 +4。自身被过量治疗后，将溢出治疗量的 50% 转化为临时生命值，最多拥有相当于自身最大生命值 ×2 的临时生命值。"),
]

# ============================================================
# 蓄意｜史诗｜胸甲
# ============================================================
INTENT_NOTE = """# ============================================================
# fallendream:equipment/armor/intent/give —— 给一件「蓄意」（史诗 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"intent" -> 装备 id; 判定写 custom_data~{zx:["intent"]}
# 【机制】魔力 +150 / 最大生命 +20%；每使用 50 魔力 → +2 临时生命（单技能可重复触发）；
#   临时生命清空后 5 秒抗性提升Ⅱ + 迅捷Ⅲ，每 12 秒最多一次。
# 【★ 账本 ★】zx.it_sum（毫魔力点）由 lib/mana/pay 记账，**独立于剖面的 zx.pm_sum** ——
#   两件可同时穿，共用一份账本会互相饿死（见 lib/mana/pay 头注释）。
# 【★ "临时生命清空"怎么判 ★】lib/thp/tick 每秒比对真实吸收值，归零时会调本件的
#   on_empty（见 equipment/armor/intent/on_empty）。不要在 second 里重复检测。
# 【外观】尚未画。
# ============================================================"""

INTENT_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +150，最大生命值 +20%。自身每使用 50 点魔力值，便获得 2 点临时生命值（单次技能可重复触发）。自身临时生命值清空后，获得 5 秒抗性提升Ⅱ和迅捷Ⅲ；该效果每 12 秒最多触发一次。"),
]

# ============================================================
# 踏空｜罕见｜靴子
# ============================================================
AIR_NOTE = """# ============================================================
# fallendream:equipment/armor/air_step/give —— 给一件「踏空」（罕见 · 靴子）
# ------------------------------------------------------------
# 【custom_data】"air_step" -> 装备 id; 判定写 custom_data~{zx:["air_step"]}
# 【机制】魔力 +50；从空中落地 → 4 格内全部生物受 基础攻击力 伤害 + 击飞 1 格，
#   自身回 10 魔力；每 10 秒最多一次。
# 【★ 落地检测 ★】不用 `@a[nbt={OnGround:1b}]`（玩家 NBT 序列化 ≈10 ms/次，卡顿坑 1）。
#   改走进度 minecraft:fall_from_height（落地那一刻抛一次，事件型、可 revoke），
#   conditions 只要 distance.y ≥ 0.5（跳一下就够，排除走台阶）。
# 【外观】尚未画。
# ============================================================"""

AIR_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +50。自身从空中落地时，对自身 4 格内的全部生物造成一次相当于自身基础攻击力的伤害，并使其击飞 1 格，之后自身恢复 10 点魔力值。该效果每 10 秒最多触发一次。"),
]

# ============================================================
# 屏息｜罕见｜头盔
# ============================================================
BREATH_NOTE = """# ============================================================
# fallendream:equipment/armor/breath_hold/give —— 给一件「屏息」（罕见 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"breath_hold" -> 装备 id; 判定写 custom_data~{zx:["breath_hold"]}
# 【机制】魔力 +60；每 1 个空闲术阵位 → 每秒回 2 魔力；全满时改为每秒回 1 魔力。
# 【★ 空闲数 = 上限 − 占用 ★】用 lib/fm/read 每秒下发的 zx.fm_u / zx.fm_c。
#   全满（空闲 0）也给 1 点 —— 文案明写"改为"，不是 0。
# 【外观】尚未画。
# ============================================================"""

BREATH_LORE = [
    H("✦ 被动技能"),
    B("自身魔力值上限 +60。每有 1 个空闲术阵位，自身每秒恢复 2 点魔力值。术阵位全满时，改为每秒恢复 1 点魔力值。"),
]


ITEMS = [
    dict(key="sword/oath_victory", eid="oath_victory", cn="胜利誓约", base="netherite_sword",
         color="gold", cat="sword", slot=None, skill="oath_victory", vis=True,
         tags=["base_atk", "max_mana", "max_hp", "dash", "field", "heal", "buff"],
         note=SWORD_NOTE, lore=SWORD_LORE),
    dict(key="armor/pivot", eid="pivot", cn="枢", base="netherite_helmet",
         color="light_purple", cat="armor", slot="helmet",
         vis=True, tags=["max_mana", "formation"],
         note=PIVOT_NOTE, lore=PIVOT_LORE),
    dict(key="armor/bearing", eid="bearing", cn="承", base="netherite_leggings",
         color="light_purple", cat="armor", slot="leggings",
         vis=True, tags=["max_mana", "formation", "buff", "indep_mul", "cd_down"],
         note=BEARING_NOTE, lore=BEARING_LORE),
    dict(key="armor/empty_camp", eid="empty_camp", cn="空营", base="netherite_chestplate",
         color="light_purple", cat="armor", slot="chestplate",
         vis=True, tags=["max_mana"],
         note=CAMP_NOTE, lore=CAMP_LORE),
    dict(key="armor/lone_walk", eid="lone_walk", cn="独行", base="netherite_boots",
         color="light_purple", cat="armor", slot="boots",
         vis=True, tags=["max_mana", "buff", "indep_mul"],
         note=LONE_NOTE, lore=LONE_LORE),
    dict(key="armor/overflow", eid="overflow", cn="溢流", base="netherite_leggings",
         color="aqua", cat="armor", slot="leggings",
         vis=True, tags=["max_mana", "max_hp", "heal", "buff"],
         note=OVERFLOW_NOTE, lore=OVERFLOW_LORE),
    dict(key="armor/intent", eid="intent", cn="蓄意", base="netherite_chestplate",
         color="light_purple", cat="armor", slot="chestplate",
         vis=True, tags=["max_mana", "max_hp", "cur_mana", "buff", "heal"],
         note=INTENT_NOTE, lore=INTENT_LORE),
    dict(key="armor/air_step", eid="air_step", cn="踏空", base="netherite_boots",
         color="aqua", cat="armor", slot="boots",
         vis=True, tags=["max_mana", "base_atk", "dash", "debuff"],
         note=AIR_NOTE, lore=AIR_LORE),
    dict(key="armor/breath_hold", eid="breath_hold", cn="屏息", base="netherite_helmet",
         color="aqua", cat="armor", slot="helmet",
         vis=True, tags=["max_mana", "formation"],
         note=BREATH_NOTE, lore=BREATH_LORE),
]


def build(it):
    lore = rebuild(pad_sections(it["lore"]))
    zx = ['"%s"' % it["eid"]]
    if it["cat"] == "armor":
        zx.extend(['"%s"' % it["slot"], '"armor"'])
    else:
        zx.extend(['"%s"' % it["cat"], '"itemreplace"'])
    comps = []
    if it["cat"] != "armor":
        comps.append("item_name={text:\"%s\",bold:true,color:%s}" % (it["cn"], it["color"]))
    else:
        comps.append("item_name={text:\"%s\",bold:true,color:%s}" % (it["cn"], it["color"]))
    comps.append("lore=%s" % json_to_snbt(lore))
    comps.append("unbreakable={}")
    if it.get("skill"):
        comps.append('custom_data={zx:[%s],skill:"fallendream:%s",tags:%s}'
                     % (",".join(zx), it["skill"], json_to_snbt(it["tags"])))
    else:
        comps.append("custom_data={zx:[%s],tags:%s}" % (",".join(zx), json_to_snbt(it["tags"])))
    if it["cat"] != "armor":
        comps.append('consumable={animation:"none",consume_seconds:0,'
                     'has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}')
    comps.append('tooltip_display={hidden_components:["unbreakable"]}')
    # ★ 外观未画 ⇒ **不要**写 item_model / equippable：指向不存在的模型 = 紫黑块，
    #   而且 _chk_item_visual 会判"引用缺失"。画完再给 vis=True 并走 _sync_armor_rp.py。
    # ★ 两条链路的 key 不一样，别图省事合并：
    #     武器 → items/<id>.json            （模型 models/item/vanilla/<id>.json）
    #     盔甲 → items/armor_<id>.json      （模型 …/armor_<id>.json，equipment/armor_<id>.json）
    #   2026-10-27 真实事故：把两者写成同一个 'fallendream:%s'，8 件盔甲全部指向
    #   items/pivot.json 这类不存在的文件 —— 游戏里就是紫黑块，零日志；靠
    #   _chk_item_visual 才抓出来。
    if it.get("vis"):
        if it["cat"] == "armor":
            comps.append('item_model="fallendream:armor_%s"' % it["eid"])
            mat = it["base"].split("_")[0]
            comps.append('equippable={slot:"%s",asset_id:"fallendream:armor_%s",equip_sound:"%s"}'
                         % (EQ_SLOT[it["slot"]], it["eid"], ARMOR_SOUND[mat]))
        else:
            comps.append('item_model="fallendream:%s"' % it["eid"])
    return "give @s %s[%s]" % (it["base"], ",".join(comps))


def main():
    write = "--write" in sys.argv
    for it in ITEMS:
        d = os.path.join(BASE, it["key"])
        p = os.path.join(d, "give.mcfunction")
        body = "%s\n%s\n" % (it["note"], build(it))
        if not write:
            print("---- %s" % p)
            print(body[:400])
            continue
        os.makedirs(d, exist_ok=True)
        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(body)
        print("wrote", p)


if __name__ == "__main__":
    main()
