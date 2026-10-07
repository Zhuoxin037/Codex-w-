# ============================================================
# sweetdream:equipment/armor/eternity/give —— 给一件「永恒」（胸甲）
# ------------------------------------------------------------
# 【custom_data】"eternity" -> 装备 id
#   ★ 判定一律写成 custom_data~{zx:["eternity"]}(部分匹配 + 独有标记)
# 【数值要和实现对上】魔力上限 +280; 触发门槛 魔力 > 50; 每次补附消耗 50 魔力。
# 【★ 效果已实装(2026-10-06 晚)★】
#   ① 魔力上限 +280: second -> passive(差值账本 zx.et_mana)
#   ② "消耗任一标签 -> 花 50 魔力使其再次附着": 挂在**消耗标签的统一入口**上 ——
#      会消耗通用标签的技能都调 lib/mark_consume -> lib/mark_take -> eternity/reclaim。
#      当前消耗点: 引梦镰(噬心) / 烈火残躯(夜火) / 虹彩(随机一种) / 清醒梦(白昼梦,
#      big 与漫彩两处)。★ 后两处是"目标生物身上的标签被吞", 消耗者由 lib/find_by
#      反查回施法者, 所以扣的是**施法者**的 50 魔力。
#      ★ 热熔 / 余烬的"流火 -> 夜火"是**替换**不是消耗, 故意不走入口(否则会双状态)。
#   "本次附着的标签不可再触发该效果": 消耗只有"技能主动吃"一条路, 刷新后不会连锁;
#   同一个技能再打一次会再消耗一次、再扣 50 —— 这是文案"每次消耗了…就…"的字面意思。
# 【五个标签都是共用状态】「渊海」「流火」「夜火」「白昼梦」「噬心」, 不单独分段。
# 【模型】不写 item_model —— 盔甲走原版 netherite 外观。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s netherite_chestplate[item_name={text:"永恒",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +280。自身魔力值若高于","color":"gray","italic":false},{"text":"50 点，则自身每次消耗了「渊海」、","color":"gray","italic":false},{"text":"「流火」、「夜火」、「白昼梦」、","color":"gray","italic":false},{"text":"「噬心」任一标签时消耗 50 魔力值并使","color":"gray","italic":false},{"text":"其再次附着，本次附着的标签不可再触发","color":"gray","italic":false},{"text":"该效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["eternity","chestplate","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
