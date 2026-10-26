# -*- coding: utf-8 -*-
"""_tags_data.py —— 标签体系（批 A）的**单一真源**（词汇表 + 逐件标签）。

【这是什么】
  「标签」= 给每件装备打的一组**语义关键词**（如 `dash` 位移 / `max_mana` 最大魔力口径 /
  `liuhuo` 涉及流火），供将来的**肉鸽地图**做模糊查询（"抽一件命中 ≥2 个关键词的装备"）。

【载体】物品 `custom_data.tags`（与 `zx` 并列的独立字段）。
  `custom_data={zx:["red_lotus","axe","itemreplace"],tags:["liuhuo","yehuo","base_atk","consume"]}`
  ★ 不塞进 `zx`：`zx` 被 `overlimit/api/fit` / `upgrade/api/fit` 按"列表含某词"判断，
    动它会牵一发动全身。`tags` 是纯新增，零回归。
  ★ 字段名为什么不是 `tg`：本包 `tg` 已经是"trigger/toggle 菜单"的简称
    （`debug/tg_router` / `debug/tg_menu`），撞名。统一用 **`tags`**。

【模糊匹配】谓词的列表匹配是"**包含**"语义：
  · `custom_data~{zx:["staff"],tags:["dash"]}` —— 类别与语义**一条谓词同时查**（AND）。
  · `custom_data~{tags:["dash","attract"]}` —— 要求**同时含**这两个（= `all`）。
  · `any` / `at_least:N` —— 跑 N 次单标签判定再并集 / 计数（见 `tg/api/*`）。

【谁用它】
  · `_gen_batch5.py` / `_gen_batch6.py` 的 build()  —— 生成 43 件生成器装备的 `tags`；
  · `_gen_tags.py`   —— 回填另外 40 件**手写** give + 生成 `tg/def/load`（反查表）；
  · `check.py` 规则 `tgvocab` / `_chk_tags.py` —— 词汇表守门。

【★ 词汇表口径（用户 2026-10-10 拍板，逐条）】
  1. **状态 = "涉及到就写"**（红莲只是*消耗*流火，也算 `liuhuo`）。
  2. **数值 = "lore 涉及该数值就打"**（含属性加成，"魔力值上限 +100" → `max_mana`）。
  3. `debuff`（削弱）= **凡给敌方挂负面状态就算**（缓慢/虚弱/发光/反胃/燃烧/冰冻/时停/护甲减半/击退…）；
     原先与它重合的 `weaken`（减益）**已删**，统一用 `debuff`。
     ★ 2026-10-19 复核补：`timestop` / `freeze` / `slow` **是 `debuff` 的子类**，但实物里 11 件时停只有 2 件
       同时打了 `debuff` ⇒ 现状是"timestop 不自动带 debuff"。两种口径都自洽，**但必须全局一致**；
       目前按"不自动带"沿用（改动等于 9 件同时加词，另案处理）。
  4. `field`（领域）**只认 lore 明写"领域"的**（凡出现就照打；先例 威霆 / 神裁 / 云迹）。
     ★ 领域 = **范围增益 / 减益**，这是包内**固定叫法**，实现上**要占 1 个术阵位**。
  5. `formation`（术阵）**凡 lore 出现"术阵"就照打**（用户的设计意图：限流高强度持续技）。
     ★★ **术阵 = 纯数据占位符：无实体、不划范围、不打人**（2026-10-07 用户口径，10-14 重申）。
        底层 = 玩家名下登记条目（`manacore:players.<uuid>.formations`，8 槽 / 默认上限 3）+ marker 站位。
        ⇒ 写机制时 **"生成一个术阵，里面的生物每秒…"这种写法是错的**：范围效果一律写「领域」，
          划范围靠技能自己挂标签扫周围（先例 `wind_ontheground` 的 `zx.wg_cN` + `hit_pass`）。
  6. `summon`（召唤物）**只算独立实体**，lore 里用弯引号 `“”` 标出（入梦体/共鸣水晶/色彩/朽木/暗潮/暗海/旋风…）。
  7. `heal`（治疗）**只算"恢复/回复生命"**（回魔不算）——2026-10-15 批 14 起启用（续火等 10 件）。
     ★ 2026-10-19 复核补：「自身获得「X」，持续 N 秒」+ X 自带效果 ⇒ 算 `buff`（先例 `liaoyuan` 燎原）；
       `blind_candle` 烛火原先漏了，已补。但**没有"效果/持续"措辞、纯层数资源的**（如「静息」「毒浆」）不算。
  8. 装备**私有资源**（熔浆/燃灰/酒浆/冰凌/风声…）**不进标签**（它们是"资源"不是"分类"）。
  9. **类别词不进 `tags`**（走 `zx[1]`：`sword/axe/bow/staff/helmet/chestplate/leggings/boots/armor/tool`）。
 10. **超限形态 = 基础标签 + `overlimit`**（敲超限时由 `station/api/apply_go` 追加）。
 11. **套装效果两件都打**（lore 写在每件上就都打）。
 12. ★ `consume`（消耗）**只认消耗/清除/解除"某个状态或私有资源"**（消耗流火 / 清除渊海 / 消耗圣痕 / 解除冰冻 / 清除静息）。
     **"消耗 N 魔力(值)" 这类固定费用不算** `consume`（费用另有 `cur_mana` 口径，见 13）。先例：神裁/脑髓蛭的"消耗 50 魔力"都没 `consume`；天使核心的 `consume` 来自"消耗圣痕"。
     ★ 2026-10-19 复核补：**清除/吸收"私有资源"或自攒层数同样算**（先例：`empty_pillow` 清除「静息」→ 有；
       `backlight` 清除「回照」→ 有；`flame_brokenbody` 清除「熔浆」/ 吸收「夜火」→ **原先漏了，已补**）。
       反例噪音：`wind_ontheground` 清除「风声」没有 `consume`，属历史不一致，未擅自改动。
 13. ★ `cur_mana`（当前魔力）**只认"魔力作为口径/资源"**：伤害按当前魔力算、条件判"当前魔力值 ≤ N%"、按"本次消耗的魔力"回算。
     **被动触发的固定费用（"消耗 30 魔力并附加…"）不算**（先例：天使核心/神裁/反弹 都无 `cur_mana`）。
 14. ★ `flat`（固定值）**只认正文里的"固定伤害/保底"**（如"12 点固定伤害"）。
     **普攻/技能的拼色行「伤害 N」不算**（先例：共鸣水晶/终末启示 的"伤害 7 / 伤害 20" 都无 `flat`）。
     ★★ 2026-10-19 用户口径（设计方向，不是判定规则）：「**固定伤害不一定要写成一次性技能**，
        那样太无趣」。**"一段状态期间，之后每次攻击都附带 N 点固定伤害"** 完全算 `flat`，
        而且这是更鼓励的写法。实现上这类附伤**不吃任何乘区**（否则就不是"固定"了），
        所以 `flat` 与 `base_atk`/`indep_mul` 天然不该同时出现在一件附伤型装备上。
 15. ★ "范围留痕"类（如雨迹的"水迹"、"重溟/凝壳/迟庭"的领域除外）**不打标签**——只有 lore 明写"领域"才 `field`（口径 4）。
 16. ★★ **`lightning` 不属于状态体系**（2026-10-19 首次纠正，2026-10-22 用户再定：**归「机制」组**）。
     它虽然是"lore 提到就打"的效果词，但**闪电不能被"附加"、也没有"消耗闪电"这种设计**，
     与五大状态（`liuhuo/yehuo/shixin/yuanhai/dream`）不同质 ⇒ 分组归「机制」，不再占状态组。
     凡做"某状态应有 apply/consume"的推断，状态池只能用 `STATUS_KEYS`，**不能按 GROUP 筛**。
 17. ★ **`apply` 只服务"可施加的状态"**：五大状态 + 圣痕 / 电刺等私有层数。**冰冻 / 减速 / 时停走专词
     （`freeze`/`slow`/`timestop`），不再打 `apply`**。⇒ 统计时 "附加 + 冰冻" 恒为 0 是**口径正确**，
     不是设计缺失。（6 件冰冻 lore 全写"使其冰冻 N 秒"却无 `apply`，即为本条约定的实物体现。）
"""

# ---------------------------------------------------------------- 词汇表（28 词）
#   cat: 分组（词表用） · label: 中文名 · desc: 语义说明
VOCAB = [
    # ---- 状态（5）「涉及就打」----
    ("liuhuo", "状态", "流火", "lore 涉及「流火」状态"),
    ("yehuo", "状态", "夜火", "lore 涉及「夜火」状态"),
    ("shixin", "状态", "噬心", "lore 涉及「噬心」状态"),
    ("yuanhai", "状态", "渊海", "lore 涉及「渊海」状态"),
    ("dream", "状态", "白昼梦", "lore 涉及「白昼梦」状态"),
    # ★ 2026-10-22 用户定: 闪电**不是状态**, 归「机制」组（见下方 机制 段末条）。

    # ---- 数值口径（6）「lore 提到该数值就打」----
    ("max_hp", "数值", "最大生命值", "涉及「最大生命值 / 生命值上限」（含属性加成）"),
    ("base_atk", "数值", "基础攻击力", "涉及「基础攻击力 / 基础伤害」（含属性加成）"),
    ("max_mana", "数值", "最大魔力值", "涉及「最大魔力值 / 魔力值上限」（含属性加成）"),
    ("cur_mana", "数值", "当前魔力值", "涉及「当前魔力值 / 剩余魔力 / 消耗的魔力」"),
    ("true_dmg", "数值", "真实伤害", "伤害记为真实伤害"),
    ("flat", "数值", "固定值", "保底 / 固定值伤害"),

    # ---- 作用 / 机制（16）----
    ("debuff", "机制", "削弱", "给敌方挂负面状态（缓慢/虚弱/发光/反胃/燃烧/冰冻/时停/护甲减半/击退…）"),
    ("heal", "机制", "治疗", "治疗 / 回血（★ 2026-10-15 批 14 起有装备使用：续火/归息/失血/彼岸/绯缝/剜霜/踏灰/沸痕/殓丝/杂纹）"),
    ("consume", "机制", "消耗", "消耗 / 清除某个状态（消耗流火 / 清除渊海 / 移除噬心…）"),
    ("apply", "机制", "附加", "给目标施加某个状态（附加流火 / 附加圣痕 / 附加电刺…）"),
    ("buff", "机制", "增益", "给自身挂正向状态效果（力量/迅捷/再生/抗性/抗火/水下呼吸…）"),
    ("cd_down", "机制", "减冷却", "冷却时间 -N 秒 / 立即结束 / 刷新"),
    ("indep_mul", "机制", "独立乘区", "明确写「独立乘区」或「技能伤害 +N%」（独立乘区）"),
    ("summon", "机制", "召唤物", "召唤独立实体（lore 用“”标出）"),
    ("dash", "机制", "位移", "突进 / 瞬移 / 闪回 / 跃升 / 俯冲 / 击退"),
    ("attract", "机制", "吸引", "把生物拉向中心"),
    ("field", "机制", "领域", "★ 凡 lore 明写「领域」（= 范围增益/减益，包内固定叫法；占 1 个术阵位）"),
    ("formation", "机制", "术阵", "★ 凡 lore 出现「术阵」（纯数据占位符：无实体、不划范围）"),
    ("timestop", "机制", "时停", "时停 / 定身"),
    ("freeze", "机制", "冰冻", "冰冻"),
    ("slow", "机制", "减速", "lore 里的「缓慢」"),
    # ★ 2026-10-22 用户定: 闪电是**机制**不是状态。同为"涉及就打"的效果词, 但不进状态池。
    #   口径: lore 出现「闪电 / 落雷 / 雷击 / 电」就打(电弧的「电刺 / 电线」同族)。
    ("lightning", "机制", "闪电", "lore 涉及「闪电 / 落雷 / 雷击 / 电」（负离子 / 超•负•荷 / 威霆 / 电弧 / 引雷针 / 雷鸣 / 雷楔）"),

    # ---- 超限标记（1）----
    ("overlimit", "超限", "超限", "超限形态（= 基础标签 + 本词；敲超限时追加）"),
]

VOCAB_KEYS = [v[0] for v in VOCAB]

# ---------------------------------------------------------------- 词性（★ 统计期望时必须用这组）
#   GROUP 字段（"状态"/"数值"/"机制"）是**查询分组**，不是词性：`lightning` 按用户口径
#   归「机制」（2026-10-22），它**不是状态**。任何"某状态应该能附加/消耗"的推断都只能用 STATUS_KEYS。
STATUS_KEYS = ['liuhuo', 'yehuo', 'shixin', 'yuanhai', 'dream']   # 五大状态，可积累可消费
EFFECT_KEYS = ['lightning']                                        # 效果词：触发即生效，不积累不消费

# ---------------------------------------------------------------- 逐件标签表
#   顺序 = [状态] [数值] [机制]；类别不进此表（走 zx[1]）。
TAGS = {
    # ================= 剑 sword（17）=================
    "aurora_dream":      ["dream", "timestop"],
    "deepsea_echo":      ["yuanhai", "cur_mana", "apply", "buff"],
    "everfrost":         ["cur_mana", "freeze", "debuff"],
    "flame_brokenbody":  ["yehuo", "max_mana", "consume", "cd_down"],
    "hengdao":           ["max_mana", "dash"],
    "hush":              ["max_mana", "dash"],
    "liaoyuan":          ["liuhuo", "max_mana", "apply", "buff"],
    "liuguang":          ["base_atk", "flat"],
    "myriad":            ["cur_mana"],
    "qiansan":           ["base_atk"],
    "rebound":           ["base_atk", "consume"],
    "remelt":            ["liuhuo", "yehuo", "base_atk", "debuff"],
    "rogue_star":        ["base_atk", "flat"],
    "shadow_blade":      ["base_atk", "dash", "cd_down"],
    "sickle_dreams":     ["shixin", "max_mana", "apply", "timestop", "consume"],
    "tinder":            ["cur_mana", "max_hp", "debuff"],
    "verdict":           ["max_mana", "base_atk", "debuff", "field", "slow"],
    # ---- 新批次(2026-10-11) ----
    "tidemark":          ["yuanhai", "max_mana", "apply"],
    "grayscale":         ["liuhuo", "cur_mana", "debuff", "apply"],
    "crescent":          ["base_atk", "max_mana", "cd_down"],
    # ---- 批一 · 阶段补全(2026-10-20) ----
    "yebu":              ["slow", "debuff"],
    "gousi":             ["attract", "slow", "debuff", "indep_mul"],
    "chengxing":         ["flat", "base_atk"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "profane":           ["shixin", "base_atk", "consume", "indep_mul", "cd_down"],
    "way_back":          ["summon", "dash", "heal"],
    "empty_seat":        ["flat", "formation", "debuff"],

    # ================= 斧 axe（15）=================
    "agony":             ["max_hp", "base_atk", "formation"],
    "angel_core":        ["max_mana", "base_atk", "apply", "consume"],
    "anion":             ["lightning", "cur_mana"],
    "azure_star":        ["max_mana", "cur_mana", "indep_mul"],
    "ballad":            ["base_atk", "true_dmg", "timestop"],
    "charge":            ["lightning", "cur_mana", "formation", "buff", "cd_down"],
    "chenyuan":          ["yuanhai", "max_mana", "cur_mana", "cd_down", "slow", "debuff", "apply"],
    "draught":           ["max_hp", "base_atk", "buff"],
    "dream_reader":      ["dream", "cur_mana", "true_dmg", "summon", "timestop", "apply"],
    "fissure":           ["base_atk"],
    "meteor":            ["base_atk", "slow", "debuff"],
    "pyre":              ["cur_mana", "debuff"],
    "red_lotus":         ["liuhuo", "yehuo", "base_atk", "consume"],
    "skyvault":          ["max_mana", "base_atk", "dash", "cd_down", "debuff"],
    "thunderclap":       ["lightning", "max_mana", "cur_mana", "max_hp", "formation", "field", "debuff"],
    # ---- 新批次(2026-10-11《新的装备-超限等.md》) ----
    "sacred_relic":      ["liuhuo", "yehuo", "shixin", "yuanhai", "dream", "max_mana", "max_hp",
                          "true_dmg", "timestop", "formation", "summon"],
    "anchor":            ["max_mana", "base_atk", "dash"],
    "scorch_bone":       ["liuhuo", "yehuo", "base_atk", "max_mana", "apply", "consume"],
    # ---- 批一 · 阶段补全(2026-10-20) ----
    "xiugou":            ["summon", "base_atk"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "bind_ember":        ["liuhuo", "apply", "slow", "debuff", "cd_down"],
    "grave_tablet":      ["true_dmg", "base_atk", "cd_down"],
    "sunken_weight":     ["flat", "slow", "debuff"],

    # ================= 弩 bow（6）=================
    "arc":               ["lightning", "cur_mana", "base_atk"],
    "bone_erode":        ["cur_mana"],
    "cold_crow":         ["max_mana", "freeze", "debuff"],
    "lucid_dream":       ["dream", "max_mana", "cur_mana", "true_dmg", "timestop", "consume", "formation"],
    "rainbow":           ["liuhuo", "yehuo", "yuanhai", "dream", "shixin", "max_hp", "consume"],
    "sculk_echo":        ["base_atk"],
    # ---- 新批次(2026-10-11) ----
    "dragon_tongue":     ["liuhuo", "yehuo", "cur_mana", "consume"],
    "cloudtrail":        ["base_atk", "field"],
    "burst_dawn":        ["max_mana", "base_atk", "formation", "summon", "slow", "debuff"],
    # ---- 批 13 · 过渡/终端补缺(2026-10-13) ----
    "backstring":        ["dash", "buff", "flat"],
    # ---- 批一 · 阶段补全(2026-10-20) ----
    "lianshi":           ["cur_mana", "base_atk"],
    "tiejili":           ["slow", "debuff", "field"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "night_bind":        ["yehuo", "slow", "debuff"],

    # ================= 法杖 staff（12）=================
    "apocalypse":        ["max_mana", "cur_mana", "formation", "debuff"],
    "begonia":           ["yuanhai", "max_mana", "cur_mana", "formation", "attract", "consume"],
    "chime":             ["max_mana", "formation", "summon"],
    "delusion":          ["max_mana", "formation", "timestop"],
    "fallen_dream":      ["dream", "max_mana", "cur_mana", "true_dmg", "formation", "timestop", "apply"],
    "final_revelation":  ["max_mana", "slow", "debuff"],
    "gu_poison":         ["shixin", "max_hp", "cur_mana", "apply", "slow", "debuff", "consume", "formation"],
    "palette":           ["max_mana", "summon", "cd_down"],
    "polarized_light":   ["cur_mana", "formation", "slow", "debuff"],
    "sail":              ["yuanhai", "liuhuo", "dream", "shixin", "attract", "apply", "summon"],
    "twilight":          ["shixin", "max_mana", "apply", "debuff", "formation"],
    "wind_ontheground":  ["max_mana", "cur_mana", "formation", "buff"],
    # ---- 新批次(2026-10-11) ----
    "triad":             ["max_mana", "base_atk", "formation", "freeze", "debuff"],
    "five_curses":       ["cur_mana", "true_dmg", "slow", "debuff"],
    # ---- 批 13 · 过渡/终端补缺(2026-10-13) ----
    "thunderrod":        ["lightning", "debuff"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "burst_bank":        ["cur_mana", "dash", "debuff"],
    "cage_day":          ["dream", "apply", "base_atk", "debuff", "max_mana"],
    "stop_needle":       ["timestop", "cd_down", "max_mana"],
    "pour_sack":         ["cur_mana", "flat"],

    # ================= 盔甲 armor（25）=================
    "blaze_armor":       ["liuhuo", "max_mana", "buff", "debuff", "apply"],
    "brain_leech":       ["max_mana", "base_atk", "buff"],
    "dionysus_helmet":   ["max_mana", "buff"],
    "dusk_dawn":         ["liuhuo", "yehuo", "yuanhai", "dream", "shixin", "max_mana"],
    "ember":             ["liuhuo", "yehuo", "max_mana", "apply", "consume", "buff"],
    "eternity":          ["liuhuo", "yehuo", "yuanhai", "dream", "shixin", "max_mana", "consume", "apply"],
    "external_power":    ["max_mana", "max_hp", "buff"],
    "fade":              ["max_mana", "cd_down"],
    "flesh_mill":        ["max_mana", "buff"],
    "furnace_core":      ["max_mana", "max_hp", "base_atk"],
    "hex_belt":          ["max_mana"],
    "immolate":          ["liuhuo", "yehuo", "max_mana", "debuff"],
    "intravenous_pump":  ["max_mana", "max_hp", "buff"],
    "iridescent":        ["dream", "max_mana", "base_atk", "true_dmg", "slow", "debuff", "dash", "timestop", "apply"],
    "lethe_shore":       ["shixin", "max_mana", "buff", "apply", "indep_mul", "summon"],
    "lightless_sea":     ["yuanhai", "max_mana", "base_atk", "summon", "slow", "debuff", "apply"],
    "mana_helm":         ["max_mana"],
    "mana_plate":        ["max_mana"],
    "mirage":            ["dream", "max_mana", "base_atk", "true_dmg", "apply", "timestop"],
    "resonance":         ["max_mana", "indep_mul", "formation"],
    "spine_symbiote":    ["max_mana", "max_hp", "buff"],
    "spirit_sight":      ["liuhuo", "yehuo", "yuanhai", "dream", "shixin", "max_mana", "debuff"],
    "stellar_elegy":     ["liuhuo", "yehuo", "yuanhai", "dream", "shixin", "max_mana", "cur_mana", "buff"],
    "styx_walk":         ["shixin", "max_mana", "summon", "apply", "slow", "debuff", "indep_mul"],
    "withered_garden":   ["yuanhai", "max_mana", "summon", "apply", "slow", "debuff", "buff"],
    # ---- 批一 · 阶段补全(2026-10-20) ----
    "zhuzu":             ["field", "flat", "debuff"],
    "lvshuang":          ["slow", "debuff", "buff"],
    "dongtu":            ["heal", "buff", "max_hp"],
    "huilan":            ["heal", "max_hp"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "breathing_soil":    ["heal", "formation", "field", "max_hp"],

    # ================= 副手 tool（8）=================
    "bitter_cold":       ["yuanhai", "slow", "debuff", "apply"],
    "blaze_plume":       ["liuhuo", "debuff"],
    "look":              [],                     # 观测镜 = 纯工具，无战斗效果 ⇒ 空标签
    "mana_pump":         ["max_mana"],
    "nullify":           ["max_mana", "formation", "indep_mul"],
    "seraph_wing":       ["base_atk", "indep_mul"],
    "thunder":           ["lightning", "max_mana"],
    "wrath":             ["max_mana", "buff", "indep_mul"],
    # ---- 批 13 · 过渡/终端补缺(2026-10-13) ----
    "frostmirror":       ["freeze", "cd_down", "debuff"],
    "everlit":           ["summon", "true_dmg", "cur_mana"],
    # ---- 批二 · 标签补缺(2026-10-20) ----
    "sip_frost":         ["heal", "slow", "debuff"],
    "retro_shine":       ["true_dmg"],

    # ================= 批 14 · NEW.md 42 件（2026-10-15）=================
    # ★ 五套双件套(燧行/潮线/缝心/浅梦/残烛)的 10 件：套装段写在两件上 ⇒ 口径 11
    #   "套装效果两件都打"，所以两件的标签都含套装段的词。
    # ---- 剑 sword（4）----
    "backflow_tide":     ["yuanhai", "max_mana", "debuff", "consume", "dash"],
    "blind_candle":      ["yehuo", "max_mana", "consume", "buff"],
    "blood_loss":        ["shixin", "max_hp", "true_dmg", "heal", "consume"],
    "thunder_wedge":     ["lightning", "base_atk", "summon", "formation"],
    # ---- 斧 axe（4）----
    "death_bell":        ["dream", "max_mana", "debuff", "consume", "cd_down"],
    "deep_brine":        ["yuanhai", "max_mana", "debuff", "slow", "consume", "attract", "field"],
    "broken_page":       ["dream", "flat", "true_dmg", "consume"],
    "frost_carve":       ["max_hp", "base_atk", "freeze", "debuff", "heal", "consume"],
    # ---- 弩 bow（4）----
    "feather_sleep":     ["dream", "max_mana", "debuff", "slow", "consume"],
    "ember_string":      ["liuhuo", "yehuo", "max_mana", "apply", "consume"],
    "reverse_string":    ["base_atk", "max_mana", "cur_mana", "indep_mul"],
    "dark_sun":          ["liuhuo", "yehuo", "cur_mana", "indep_mul", "apply"],
    # ---- 法杖 staff（7）----
    "fate_thread":       ["shixin", "max_mana", "true_dmg", "apply"],
    "other_shore":       ["shixin", "yuanhai", "max_hp", "max_mana", "cur_mana", "true_dmg",
                          "heal", "consume", "apply"],
    "renew_fire":        ["heal"],
    "wake_bell":         ["dream", "max_mana", "true_dmg", "consume"],
    "long_night":        ["liuhuo", "yehuo", "max_mana", "debuff", "consume", "apply",
                          "indep_mul", "summon", "formation"],
    "bent_ray":          ["max_mana", "flat", "indep_mul", "apply", "consume"],
    "late_court":        ["max_mana", "base_atk", "debuff", "slow", "dash", "field", "formation"],
    # ---- 副手 tool（2）----
    "tide_buckle":       ["yuanhai", "consume", "attract"],
    "coffin_silk":       ["shixin", "max_hp", "max_mana", "true_dmg", "heal", "buff", "consume"],
    # ---- 盔甲 armor（21）----
    "last_breath":       ["shixin", "yuanhai", "max_mana", "heal", "consume"],
    "cross_dream":       ["dream", "max_mana", "dash", "buff", "consume"],
    "tread_ash":         ["max_hp", "max_mana", "heal", "cd_down", "dash"],
    "backlight":         ["yehuo", "max_mana", "cur_mana", "cd_down", "consume"],
    "gyre":              ["yuanhai", "max_mana", "flat", "dash", "consume"],
    "condensed_shell":   ["max_mana", "base_atk", "debuff", "freeze", "field", "formation"],
    "flint_hat":         ["liuhuo", "max_mana", "base_atk", "apply", "indep_mul"],
    "smoke_step":        ["liuhuo", "max_mana", "base_atk", "buff", "indep_mul"],
    "tide_watch":        ["yuanhai", "max_mana", "apply", "cd_down"],
    "beach_vein":        ["yuanhai", "max_mana", "cur_mana", "buff", "cd_down"],
    "needle_sleep":      ["shixin", "max_mana", "true_dmg", "buff", "apply", "consume", "indep_mul"],
    "crimson_seam":      ["shixin", "max_hp", "max_mana", "true_dmg", "heal", "buff",
                          "apply", "consume", "indep_mul"],
    "mirror_sleep":      ["dream", "max_mana", "buff", "apply"],
    "light_pillow":      ["dream", "max_mana", "buff", "apply"],
    "char_coat":         ["liuhuo", "yehuo", "max_mana", "base_atk", "buff", "consume"],
    "candle_step":       ["liuhuo", "yehuo", "max_mana", "base_atk", "buff", "consume"],
    "boil_trace":        ["liuhuo", "max_hp", "max_mana", "heal", "apply"],
    "thorn_vein":        ["shixin", "max_mana", "buff", "apply"],
    "rain_trace":        ["yuanhai", "max_mana", "base_atk", "dash", "apply"],
    "empty_pillow":      ["dream", "max_mana", "consume", "apply"],
    "mottle_vein":       ["liuhuo", "yehuo", "shixin", "yuanhai", "dream", "max_hp",
                          "max_mana", "debuff", "heal", "buff", "consume", "indep_mul",
                          "timestop", "dash"],

    # ================= 批 15 · 白昼梦系列 9 件（2026-10-25）=================
    # ★ 只出 give，机制未实装。★ 私有资源（碎刀/烛火/泵动/水墙/海浪/光效/回光）
    #   一律**不进词表**（口径 8：私有资源是"资源"不是"分类"）。
    # ★ 套装段写在两件上 ⇒ 两件的标签都含套装段的词（口径 11）。
    # ---- 弩 bow（1）----
    "bone_breaker":      ["summon", "base_atk", "cur_mana"],
    # ---- 盔甲 armor（8 · 全传说）----
    "bright_candle":     ["liuhuo", "yehuo", "max_mana", "cur_mana", "summon", "apply",
                          "consume", "buff"],
    "borrow_fire":       ["liuhuo", "max_mana", "true_dmg", "debuff", "apply"],
    "heart_vein":        ["shixin", "max_mana", "slow", "debuff", "apply", "heal"],
    "profile":           ["shixin", "max_mana", "max_hp", "cur_mana", "indep_mul", "apply",
                          "heal"],
    "tide_fold":         ["yuanhai", "max_mana", "cur_mana", "summon", "apply", "slow",
                          "debuff", "buff", "flat"],
    "ebb_tide":          ["yuanhai", "max_mana", "summon", "slow", "debuff", "buff",
                          "indep_mul"],
    "glimmer":           ["dream", "max_mana", "cur_mana", "indep_mul", "heal", "buff",
                          "debuff"],
    "late_dusk":         ["dream", "max_mana", "buff"],
}


def dump_check():
    """自检: 用到的词必须都在词汇表内; 装备数/词数汇报。"""
    bad = []
    for cid, ts in TAGS.items():
        for t in ts:
            if t not in VOCAB_KEYS:
                bad.append((cid, t))
    return bad


if __name__ == "__main__":
    bad = dump_check()
    print("词汇表 %d 词 / 装备 %d 件" % (len(VOCAB_KEYS), len(TAGS)))
    if bad:
        for cid, t in bad:
            print("  [×] %s 用了词表外的标签 %s" % (cid, t))
    else:
        print("全部标签都在词汇表内 ✓")


# 职业系统（用户《职业系统.md》）。
TAGS.update({'dream_waker': ['buff'], 'grimoire': ['max_mana', 'cur_mana', 'consume', 'indep_mul'], 'eagle_hat': ['max_mana'], 'mana_crystal': ['max_mana', 'formation'], 'mana_imbue': ['max_mana', 'consume'], 'foresight': ['max_mana', 'max_hp', 'heal', 'buff', 'debuff', 'slow', 'liuhuo', 'yehuo', 'shixin', 'yuanhai', 'dream', 'consume'], 'self_mind': ['cur_mana', 'max_mana', 'max_hp', 'heal', 'consume', 'dash'], 'illusion': ['max_mana', 'base_atk', 'formation', 'true_dmg', 'consume', 'timestop'], 'empathy': ['max_hp', 'buff'], 'indwell': ['cur_mana', 'formation', 'consume', 'debuff', 'slow']})
