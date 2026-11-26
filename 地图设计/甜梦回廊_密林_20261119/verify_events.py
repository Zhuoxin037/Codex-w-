"""Verify the Forest event and generation update against Minecraft 1.21.5."""

import re
import time

from world import ROOT, native
from verify import PLAYER, phase, status, storage, tags, trigger, wait
from verify_dimension import at_floor, enter, move, visit


def configure():
    native.WORK = ROOT / '.workbuddy/rogue_forest_events_20261123'
    native.NATIVE = native.WORK / 'native'
    native.rcon.D = native.NATIVE


def command(row):
    return native.c(row)


def mana(key='current_mana', value=None):
    at_floor('function sweetdream:lib/uuid')
    command(f'data modify storage manacore:in arg set value {{uuid:"",key:"{key}"}}')
    command('data modify storage manacore:in arg.uuid set from storage zx:data self.uuid')
    if value is not None:
        command(f'data modify storage manacore:in arg.value set value {float(value)}d')
        command('function manacore:api/stats/set')
    command('function manacore:api/stats/get')
    return float(re.search(r': (-?[0-9.]+)d?\s*$',storage('r.value','manacore:out'))[1])


def settle(button):
    trigger(button)
    wait(lambda: status(PLAYER, 'sd.floor_cmd')==0, 'consume event choice')


def use_fixture(room, variant):
    _,_,_,i=room
    command(f'data modify storage zx:rogue floor.cells[{i}].variant set value {variant}')
    command(f'data remove storage sweetdream_floor:run rooms[{{cell:{i}}}]')
    command('data remove storage sweetdream_floor:run ambush_pending')
    visit(room)


def claim():
    wait(lambda: phase()==3,'show draw category')
    settle(38)
    wait(lambda:'tag:' in storage('offers[0]'),'draw at least one tag')
    settle(30)
    wait(lambda:phase()==1,'finish the draw')


def verify():
    configure()
    if PLAYER not in command('list'):
        native.clients()
    # Give the normal first-join cleanup a chance to finish before triggering the pad.
    time.sleep(1)
    if 'sd.floor_run' in tags(PLAYER):
        settle(3)
        wait(lambda:phase()==0 and status('#rv_clean','zx.meta')==0,'return from previous probe')
    rooms=enter()
    assert len(rooms)==16
    for kind in ('safe','blackmarket','gamble'):
        assert sum(room[2]==kind for room in rooms.values())<=1
    events=[room for room in rooms.values() if room[2]=='event']
    variants=[int(re.search(r'variant: (\d+)',storage(f'floor.cells[{r[3]}]','zx:rogue'))[1]) for r in events]
    assert len(variants)==len(set(variants)) and all(0<=i<=8 for i in variants)
    inventory=command(f'data get entity {PLAYER} Inventory')
    assert '林地补给' in inventory and 'mana_helm' in inventory and 'mana_plate' in inventory
    print('Generated 16 rooms, distinct events and the new starter kit.',flush=True)

    room=events[0]
    use_fixture(room,0)
    before=status('#lumen')
    settle(20)
    assert status('#lumen')==before+2

    use_fixture(room,1)
    settle(21)
    assert 'sd.event_well' in tags(PLAYER)
    mana(value=10)
    command(f'scoreboard players set {PLAYER} sd.event_time 59')
    wait(lambda: mana()>=11,'one timed mana from the well')
    command(f'tag {PLAYER} remove sd.event_well')
    print('Traveler still pays 2. Well sets a timed mana gain.',flush=True)

    use_fixture(room,3)
    settle(25)
    assert 'no elements' in storage('fire_quote').lower()
    assert f'cell: {room[3]}' not in storage('rooms')
    settle(20)
    assert 'sd.event_cross' in tags(PLAYER)
    capacity=command(f'attribute {PLAYER} minecraft:max_health get')
    assert '18.0' in capacity,capacity
    command(f'clear {PLAYER}')
    mana(value=10)
    command(f'damage {PLAYER} 1 minecraft:generic')
    assert mana()>=15, mana()
    print('Cross applies 10% max-health cost and returns 5 mana on damage.',flush=True)

    use_fixture(room,3)
    at_floor('function sweetdream:equipment/armor/boil_trace/give')
    cap=mana('max_mana')
    settle(25)
    assert 'slot:' in storage('fire_quote')
    settle(26)
    assert 'sd.event_fire' in tags(PLAYER)
    assert 'boil_trace' not in command(f'data get entity {PLAYER} Inventory')
    assert abs(mana('max_mana')-cap*.8)<.03,(cap,mana('max_mana'))
    assert '14.4' in command(f'attribute {PLAYER} minecraft:max_health get')
    command('data modify storage sweetdream_floor:run options set value []')
    command('data modify storage sweetdream_floor:run draw_category set value "weapon"')
    command('data modify storage sweetdream_floor:run exact_tier set value 2')
    at_floor('function sweetdream_floor:reward/check_tag {tag:"liuhuo",name:"流火"}')
    assert storage('options').count('tag: "liuhuo"')==3
    print('Fire took one tagged item, cut both caps and tripled a fire tag’s lottery weight.',flush=True)

    use_fixture(room,5)
    before=status('#lumen')
    settle(20)
    assert 2<=status('#lumen')-before<=4
    use_fixture(room,5)
    settle(21)
    claim()

    use_fixture(room,6)
    settle(20)
    assert '林地补给' in command(f'data get entity {PLAYER} Inventory')

    use_fixture(room,7)
    before=status('#budget')
    settle(20)
    assert status('#budget')==before+1

    use_fixture(room,8)
    settle(21)
    assert 'minecraft:arrow' in command(f'data get entity {PLAYER} Inventory')
    print('Cabin (both branches), medicine, trail sign and broken casket finish.',flush=True)

    use_fixture(room,4)
    settle(21)
    assert phase()==1 and f'cell: {room[3]}' in storage('ambush_pending')
    move(4.5,81,72.5)
    wait(lambda: status(PLAYER,'zx.rg_room')==10,'leave ambush room')
    visit(room)
    wait(lambda: phase()==2,'stronger ambush on return')
    assert 13<=status('#mob_budget')<=15
    before=status('#lumen')
    at_floor('kill @e[tag=sd.floor_enemy,distance=0..]')
    wait(lambda: phase()==3,'ambush cleans up and gives elite reward')
    assert status('#lumen')==before+4
    claim()

    settle(3)
    wait(lambda: phase()==0,'return to the lobby')
    assert 'sd.event_fire' not in tags(PLAYER) and 'sd.event_cross' not in tags(PLAYER)
    assert '20.0' in command(f'attribute {PLAYER} minecraft:max_health get')
    assert status(PLAYER,'sd.event_cut')==0
    print('Return ambush was 13–15 points and paid 4. Run-only modifiers reset at exit.',flush=True)


if __name__=='__main__':
    verify()
