"""Exercise tooltips and point-based combat on the private vanilla test server."""

import re
import time

from forest_combat import COST, MOSS_HIT_REDUCTION, RESIN_FUSE, ROOT_PERIOD
from world import ROOT, native
from verify import PLAYER, phase, status, storage, tags, trigger, wait
from verify_dimension import at_floor, enter, entity_count, on_floor, visit


def configure(work=None):
    native.WORK = work or ROOT / '.workbuddy/rogue_forest_combat_20261123'
    native.NATIVE = native.WORK / 'native'
    native.rcon.D = native.NATIVE


def check_team(minimum, maximum):
    planned = re.findall(r'"([a-z]+)"', storage('encounter_team'))
    assert planned and sum(COST[kind] for kind in planned) == status('#mob_budget')
    assert minimum <= status('#mob_budget') <= maximum
    assert entity_count('@e[tag=sd.floor_enemy,distance=0..]') == len(planned)
    return planned


def health(selector):
    result = at_floor(f'data get entity {selector} Health')
    return float(re.search(r': ([0-9.]+)f\s*$', result)[1])


def verify(work=None):
    configure(work)
    if PLAYER not in native.c('list'):
        native.clients()
    if 'sd.floor_run' in tags(PLAYER):
        trigger(3)
    wait(lambda: phase() == 0 and status('#rv_clean', 'zx.meta') == 0, 'close previous probe run')
    rooms = enter()
    merchant = next(room for room in rooms.values() if room[2] == 'merchant')
    visit(merchant)
    trigger(23)
    wait(lambda: 'minecraft:' in storage('merchant.stock[2].preview_id'), 'all three tooltip records')
    for index in range(3):
        preview = storage(f'merchant.stock[{index}].preview')
        assert 'minecraft:item_name' in preview and 'minecraft:lore' in preview, preview[:600]
        assert 'sd_floor_refund' not in preview
        command = f'function sweetdream_floor:market/stock_line with storage sweetdream_floor:run merchant.stock[{index}]'
        result = at_floor(f'execute store success score #tip sd.floor run {command}')
        assert status('#tip') == 1, result
    print('All three stock lines rendered with actual names, lore and components.', flush=True)

    battle = next(room for room in rooms.values() if room[2] == 'combat')
    visit(battle)
    trigger(20)
    wait(lambda: phase() == 2, 'ordinary point combat')
    native.c(f'gamemode creative {PLAYER}')
    print('Ordinary team', status('#mob_budget'), check_team(5,7), flush=True)

    at_floor('summon minecraft:husk ~1 ~ ~1 {Tags:["sd.floor_enemy","sd.mob.test_anchor"],NoAI:1b}')
    at_floor('kill @e[tag=sd.floor_enemy,tag=!sd.mob.test_anchor,distance=0..]')
    wait(lambda: entity_count('@e[tag=sd.mob.prop,distance=0..]') == 0, 'drain any natural pending hazard')

    at_floor('function sweetdream_floor:combat/mobs/spawn_root')
    root = '@e[tag=sd.mob.root,sort=nearest,limit=1]'
    ally = '@e[tag=sd.mob.test_anchor,sort=nearest,limit=1]'
    assert health(root)==12 and health(ally)==20
    at_floor(f'attribute {ally} minecraft:armor base set 0')
    at_floor(f'scoreboard players set {root} sd.mob_time {ROOT_PERIOD-1}')
    wait(lambda: health(ally) == 15, 'root hits another mob within its telegraphed ring')
    at_floor(f'kill {root}')
    print('Root had 12 HP and its delayed strike also hit another mob.', flush=True)

    native.c(f'clear {PLAYER}')
    native.c(f'gamemode adventure {PLAYER}')
    at_floor('function sweetdream_floor:combat/mobs/spawn_resin')
    resin = '@e[tag=sd.mob.resin,sort=nearest,limit=1]'
    assert health(resin)==10
    start = health(PLAYER)
    at_floor(f'damage {resin} 30 minecraft:player_attack by {PLAYER}')
    pending = '@e[tag=sd.mob.resin_pending,sort=nearest,limit=1]'
    def timer(entity):
        return int(re.search(r'(-?\d+) \[sd.mob_time\]', at_floor(f'scoreboard players get {entity} sd.mob_time'))[1])
    wait(lambda: entity_count('@e[tag=sd.mob.resin_pending,distance=0..]') == 1, 'resin shell pending on combat death')
    assert 0 < timer(pending) <= RESIN_FUSE
    wait(lambda: entity_count('@e[tag=sd.mob.resin_pending,distance=0..]') == 0, 'resin burst completes')
    assert health(PLAYER)==start-5, health(PLAYER)
    assert 'slowness' in at_floor(f'data get entity {PLAYER} active_effects')
    assert entity_count('@e[type=minecraft:experience_orb,distance=0..]') == 0
    print('Resin dealt 5 and slowed the player after death. A player kill produced no XP.', flush=True)
    native.c(f'gamemode creative {PLAYER}')

    at_floor('function sweetdream_floor:combat/mobs/spawn_moss')
    body = '@e[tag=sd.mob.moss,sort=nearest,limit=1]'
    assert health(body)==30
    at_floor(f'scoreboard players set {body} sd.mob_time 60')
    at_floor(f'damage {body} 2 minecraft:player_attack by {PLAYER}')
    wait(lambda: 'passed' in at_floor(f'execute as {body} if score @s sd.mob_cd matches 1..').lower(),
         'damage triggers moss acceleration')
    assert timer(body) <= 60-MOSS_HIT_REDUCTION
    for count in (1,2,3):
        at_floor(f'scoreboard players set {body} sd.mob_time 1')
        wait(lambda: entity_count('@e[tag=sd.mob.moss_child,distance=0..]')==1,'moss spawns one child')
        child = '@e[tag=sd.mob.moss_child,sort=nearest,limit=1]'
        assert health(child)==8
        at_floor('kill @e[tag=sd.mob.moss_child,distance=0..]')
    at_floor(f'scoreboard players set {body} sd.mob_time 1')
    time.sleep(.2)
    assert entity_count('@e[tag=sd.mob.moss_child,distance=0..]')==0
    print('Moss took damage, shortened the timer and capped at three 8-HP children.', flush=True)
    at_floor('kill @e[tag=sd.floor_enemy,distance=0..]')
    wait(lambda: phase()==3,'clear simulated encounter')
    trigger(38)
    wait(lambda: 'tag:' in storage('offers[0]'),'weapon offers')
    trigger(30)
    wait(lambda: phase()==1,'ordinary reward still works')

    elite = next(room for room in rooms.values() if room[2] == 'elite')
    visit(elite)
    trigger(20)
    wait(lambda: phase()==2,'elite begins')
    members = check_team(10,12)
    assert members.count('crown')==1
    assert health('@e[tag=sd.mob.crown,sort=nearest,limit=1]')==38
    assert re.search(r'\b4\.0\b', at_floor('attribute @e[tag=sd.mob.crown,sort=nearest,limit=1] minecraft:attack_damage get'))
    print('Elite team', status('#mob_budget'), members, flush=True)


if __name__=='__main__':
    verify()
