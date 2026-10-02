# ============================================================
# sweetdream:equipment/armor/mirage/hit_dream —— 套装: 打到带白昼梦的生物 +2(8 秒, 最多 10 层)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/mirage_hit_dream
#   触发器 player_hurt_entity, 条件里直接限定"被打的那只带 zx.status.dream"
#   —— 计分板标签存在实体的 **Tags** NBT 里, 所以能用 entity predicate 的
#      nbt 过滤。这样就**不需要知道被打的是哪一只**: 条件过了就是打中了。
#      (这也是 attack.mcfunction 里费劲定位目标的原因: 那边要"对那只生物"
#       施加效果, 这边只影响自己, 不用认人。)
# 【执行者】玩家(动手的那个人)
# 【★ 是"加一层", 不是"把时间刷回去" ★】每次命中各加一层, 每层自己活 8 秒,
#   最多 10 层(= +20 攻击力)。上限判在 add_b 里, 满了就一层都不加。
# 【结算在哪】真正的加/减由 passive 每秒按账本结算, 见 apply_set_atk。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/mirage_hit_dream

# 套装: 幻昼 + 异彩必须同时穿着(进度条件只保证打中带白昼梦的生物)
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run return 0
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run return 0

function sweetdream:equipment/armor/mirage/add_b
