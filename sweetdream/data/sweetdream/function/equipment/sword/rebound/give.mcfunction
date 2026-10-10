# ============================================================
# sweetdream:equipment/sword/rebound/give —— 给一件「回锋」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "rebound" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["rebound"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【专属层数「断刃」】被动攒层(攻击时魔力≥50 -> 扣 30 -> +1 层, 上限 3),
#   主动(80 / 12 秒)前方 3×5; 有「断刃」则消耗全部, 之后**每 0.35 秒(7 刻)重复一次**、
#   每层重复一次(2026-10-07 用户口径: 不再同刻一次性打完) -> 见 cast 的 ⑦/⑦' + tick_step。
#   ★ "每 0.35 秒"是**实现细节, 不写进 lore**(用户 2026-10-07 定): 描述只说"每层重复一次"。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_sword[item_model="sweetdream:rebound",item_name={text:"回锋",bold:true,color:white},lore=[{"text":"✦ 断刃","color":"gold","bold":true,"italic":false},{"text":"每次攻击时若有 50 及以上魔力则消耗 30","color":"gray","italic":false},{"text":"魔力值并为自身附加一层「断刃」","color":"gray","italic":false},{"text":"（最多 3 层）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"12 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"对自身前方 3×5 格内的生物造成相当于自","color":"gray","italic":false},{"text":"身基础攻击力 ×2 的伤害。若有「断刃」","color":"gray","italic":false},{"text":"则消耗全部「断刃」且每有一层则重复一","color":"gray","italic":false},{"text":"次以上效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["rebound","sword","itemreplace"],skill:"sweetdream:rebound",tags:["base_atk","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
