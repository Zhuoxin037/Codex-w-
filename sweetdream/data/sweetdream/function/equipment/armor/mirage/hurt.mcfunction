# ============================================================
# sweetdream:equipment/armor/mirage/hurt —— 套装: 受伤后基础攻击力 +1(5 秒, 可叠加)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/mirage_hurt(entity_hurt_player)
# 【执行者】玩家(被打的那个人)
# 【为什么写在这一份里】套装两条都归幻昼管(见 passive 顶部注释)。
# 【★ 是"加一层", 不是"把时间刷回去" ★】旧写法是 `scoreboard players set
#   zx.mr_atk1 5` —— 第二次受伤只是把倒计时刷回 5 秒, 加成永远只有 +1。
#   文案要的是"受到伤害就 +": 每次受伤各加一层, 每层自己活 5 秒(先加的先掉),
#   不设上限。所以这里只管"+1 层", 到期由 expire 按环形记账收掉。
# 【摔落/窒息也算】entity_hurt_player 对没有攻击者的伤害同样触发, 正合文案
#   "自身受到伤害后"—— 想要"只有被生物打才算"的话在进度条件里加 source 判定。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/mirage_hurt

# 套装: 幻昼 + 异彩必须同时穿着
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run return 0
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run return 0

function sweetdream:equipment/armor/mirage/add_a
