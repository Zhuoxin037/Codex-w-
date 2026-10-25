# ============================================================
# sweetdream:equipment/armor/dongtu/give —— 给一件「冻土」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "dongtu" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["dongtu"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】diamond_boots（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/armor_dongtu.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。
#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。
# ============================================================
give @s diamond_boots[item_name={text:"冻土",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"站立不动 1.5 秒后获得「冻土」：获得抗","color":"gray","italic":false},{"text":"性提升Ⅰ，并每秒恢复自身 3% 最大生命","color":"gray","italic":false},{"text":"值，最多持续 6 秒。移动后「冻土」立刻","color":"gray","italic":false},{"text":"中断，并从此刻起 20 秒内不能再次获得。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["dongtu","boots","armor"],tags:["heal","buff","max_hp"]},tooltip_display={hidden_components:["unbreakable"]}]
