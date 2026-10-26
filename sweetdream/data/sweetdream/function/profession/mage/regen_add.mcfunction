function sweetdream:profession/mage/tally
# max mana ×10 × orbs = 1% per orb in millimana.
scoreboard players operation #jregenmax zx.meta *= #jorbs zx.meta
scoreboard players operation #regen manacore.math += #jregenmax zx.meta
