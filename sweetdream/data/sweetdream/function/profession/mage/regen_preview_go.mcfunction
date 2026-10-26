$execute store result score #jregenmax zx.meta run data get storage manacore:players "$(uuid)".stats.max_mana 10
scoreboard players operation #jregenmax zx.meta *= #jorbs zx.meta
