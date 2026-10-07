# ============================================================
# sweetdream:equipment/armor/resonance/give —— 给一件「共振」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "resonance" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["resonance"]}(部分匹配 + 独有标记)
# 【"当前有几个术阵"]用前置包的 formation/count 接口读, 别自己数。
# 【+10% 是乘区】走技能倍率的"整体乘区", 不是给三条通道各加 10。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_chestplate[item_name={text:"共振",bold:true,color:white},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身当前每有一个术阵则自身释放技能的","color":"gray","italic":false},{"text":"伤害 +10%。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["resonance","chestplate","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
