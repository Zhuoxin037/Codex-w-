# ------------------------------------------------------------
# internal/cooldown/increase_sec —— increase 的秒 -> tick 换算
# ------------------------------------------------------------
execute store result score #amt manacore.math run data get storage manacore:work a.seconds 20
execute if score #amt manacore.math matches 1.. run function manacore:internal/cooldown/increase_body with storage manacore:work a
