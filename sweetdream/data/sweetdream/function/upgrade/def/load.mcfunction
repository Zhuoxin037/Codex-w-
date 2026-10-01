# ============================================================
# sweetdream:upgrade/def/load —— 升级定义表(由 core/load 调用)
# ------------------------------------------------------------
# 【存在哪】zx:config updef."<升级id>" = {cat:"<类别词>", dmg:.., mana:.., cd:.., note:".."}
#   cat  = 能装到哪个类别上 —— 就用 custom_data.zx 里那个词:
#          sword / axe / bow / staff / helmet / chestplate / leggings / boots
#   dmg  = 伤害乘区加算(0.1 = +10%)    mana = 魔力消耗乘区加算(负数=省蓝)
#   cd   = 冷却乘区加算(负数=减冷却)
# 【怎么加新升级】照抄一行改 id 和数字就行, 别的文件都不用动。
#   具体"怎么生效"由武器代码调 sweetdream:upgrade/api/bonus_held 读出来的数字决定。
# ============================================================

data modify storage zx:config updef."sharp" set value {cat:"sword",dmg:0.10,mana:0.0,cd:0.0,note:"伤害 +10%"}
data modify storage zx:config updef."efficiency" set value {cat:"sword",dmg:0.0,mana:-0.10,cd:0.0,note:"魔力消耗 -10%"}
data modify storage zx:config updef."swift" set value {cat:"sword",dmg:0.0,mana:0.0,cd:-0.10,note:"冷却 -10%"}