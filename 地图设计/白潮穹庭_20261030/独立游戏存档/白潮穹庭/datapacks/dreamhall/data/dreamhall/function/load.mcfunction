gamerule doMobSpawning false
gamerule doDaylightCycle false
gamerule doWeatherCycle false
gamerule doFireTick false
gamerule keepInventory true
gamerule randomTickSpeed 0
gamerule spawnRadius 0
gamerule announceAdvancements false
time set 6000
weather clear
setworldspawn 0 65 168 180
scoreboard objectives add dh dummy
execute unless score #dh.setup dh matches 1 run function dreamhall:setup
