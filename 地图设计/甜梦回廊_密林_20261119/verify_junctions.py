"""Verify room-on-entry scenes, shrub traversal, mirror routing, and a live transition."""

from collections import deque
import re
import time

from architecture import PITCH, radius
from forest_floors import NEXT, NEXT_MAP
from forest_junctions import PAIRS
from world import ROOT,native
from verify import PLAYER,phase,status,storage,tags,trigger,wait
from verify_dimension import at_floor,cells,enter,entity_count,floor_block,map_edges,move,visit


def configure():
    native.WORK=ROOT/'.workbuddy/rogue_forest_junctions_20261123'
    native.NATIVE=native.WORK/'native'
    native.rcon.D=native.NATIVE


def command(row):
    return native.c(row)


def num(record, key):
    return int(re.search(rf'\b{key}: (-?\d+)', record)[1])


def settle(key):
    trigger(key)
    wait(lambda: status(PLAYER,'sd.floor_cmd')==0,'submit junction action')


def claim():
    wait(lambda:phase()==3,'typed reward')
    settle(38)
    wait(lambda:'tag:' in storage('offers[0]'),'weapon tag offer')
    settle(30)
    wait(lambda:phase()==1,'finish reward')


def clear_combat():
    if 'cell:' not in storage('encounter'):
        return
    settle(20)
    wait(lambda:phase()==2,'combat room opens its encounter')
    at_floor('kill @e[tag=sd.floor_enemy,distance=0..]')
    claim()


def graph_steps(a,b):
    graph={i:[] for i in range(25)}
    for (x,y,_),open_now in zip(PAIRS,map_edges()):
        if open_now=='1':
            graph[x].append(y); graph[y].append(x)
    q=deque([(a,0)]); seen={a}
    while q:
        node,d=q.popleft()
        if node==b: return d
        for n in graph[node]:
            if n not in seen: seen.add(n); q.append((n,d+1))
    raise AssertionError('disconnected layout')


def verify():
    configure()
    if PLAYER not in command('list'):
        native.clients()
    time.sleep(1)
    if 'sd.floor_run' in tags(PLAYER):
        settle(3)
        wait(lambda:phase()==0 and status('#rv_clean','zx.meta')==0,'clear previous probe')
    rooms=enter()
    assert len(rooms)==16
    assert '1b' in storage('floor.delayed_scene','zx:rogue')
    assert entity_count('@e[tag=sd.floor_vendor,distance=0..]')==0
    assert '1b' in storage('floor.cells[10].furnished','zx:rogue')
    for record in rooms.values():
        if record[3]==10: continue
        assert 'Found no elements' in storage(f'floor.cells[{record[3]}].furnished','zx:rogue')
    ordinary=next((i,a,b,axis) for i,(a,b,axis) in enumerate(PAIRS) if map_edges()[i]=='1')
    _,a,b,axis=ordinary
    x,z,kind,_=rooms[a]; mid=(radius(kind)+PITCH-radius(rooms[b][2]))//2
    xx,zz=(x+mid,z) if axis=='east' else (x,z+mid)
    assert floor_block(xx,81,zz,'air') and floor_block(xx,82,zz,'air')
    print('Rooms started as lit shells. Ordinary corridors are physically straight and open.',flush=True)

    for _ in range(35):
        if 'cell:' in storage('mirror.a'): break
        at_floor('function sweetdream_floor:junction/plan_mirrors')
    a=num(storage('mirror.a'),'cell'); b=num(storage('mirror.b'),'cell')
    assert graph_steps(a,b)>=4
    assert 'Found no elements' in storage('mirror.a.seen')
    visit(rooms[a]); clear_combat()
    assert '1b' in storage(f'floor.cells[{a}].furnished','zx:rogue')
    assert '1b' in storage('mirror.a.seen') and 'Found no elements' in storage('mirror.b.seen')
    x,z,_,_=rooms[a]
    move(x+8.5,81,z+8.2)
    before=status('#budget')
    at_floor('advancement grant @s only sweetdream_floor:junction/touch_host')
    wait(lambda:'sd.floor_mirror' in tags(PLAYER),'enter first mirror chamber')
    settle(81)
    assert status(PLAYER,'sd.mirror_side')==2 and status('#budget')==before
    command('scoreboard players set #budget sd.floor 0')
    settle(83)
    assert 'sd.floor_mirror' in tags(PLAYER)
    command(f'scoreboard players set #budget sd.floor {before}')
    settle(83)
    wait(lambda:status(PLAYER,'zx.rg_room')==b and status('#budget')==before-1,'enter opposite host and pay first visit')
    clear_combat()
    assert 'sd.floor_mirror' not in tags(PLAYER)
    print('Mirror distance, hidden discovery, free travel and paid first exit all passed.',flush=True)

    merchant=next(room for room in rooms.values() if room[2]=='merchant')
    visit(merchant)
    assert '1b' in storage(f'floor.cells[{merchant[3]}].furnished','zx:rogue')
    assert entity_count('@e[tag=sd.floor_vendor,distance=0..]')>=1
    shrub=storage('shrub'); edge=num(shrub,'edge'); r1=num(shrub,'r1'); r2=num(shrub,'r2')
    x,z=num(shrub,'x'),num(shrub,'z'); middle=(r1+PITCH-r2)//2
    east='axis: "east"' in shrub
    s=(x+middle,z) if east else (x,z+middle)
    assert map_edges()[edge]=='0' and floor_block(s[0],81,s[1],'dark_oak_leaves')
    assert status('#shrub_need')==1
    move(x+middle-1.1 if east else x+.5,81,z+.5 if east else z+middle-1.1)
    command(f'clear {PLAYER}')
    at_floor('function sweetdream:equipment/sword/tidemark/give')
    at_floor('advancement grant @s only sweetdream_floor:junction/shrub_touch')
    assert 'tidemark' in storage('shrub_quote')
    settle(80)
    wait(lambda:'1b' in storage('shrub.open'),'open shrub edge')
    assert map_edges()[edge]=='1' and floor_block(s[0],81,s[1],'air')
    assert 'tidemark' not in command(f'data get entity {PLAYER} Inventory')
    print('Reserved shrub is a single independent link. A weapon opened it and refreshed the map.',flush=True)

    transfer(rooms)


def transfer(rooms):
    astrology=next(room for room in rooms.values() if room[2]=='astrology')
    visit(astrology)
    for room in rooms.values():
        if room[2]=='blackmarket':
            command(f'data modify storage zx:rogue floor.cells[{room[3]}].kind set value "safe"')
    command('scoreboard players set #lumen sd.floor 11')
    command(f'gamemode adventure {PLAYER}')
    command(f'effect clear {PLAYER}')
    max_health=float(command(f'attribute {PLAYER} minecraft:max_health get').split()[-1])
    def health():
        return float(re.search(r': ([0-9.]+)f',command(f'data get entity {PLAYER} Health'))[1])
    target=max_health*.18
    if health()>target:
        command(f'damage {PLAYER} {health()-target:.4f} minecraft:magic')
    wait(lambda: 0<health()<max_health*.2,'lower health for transfer')
    command('scoreboard players set #phase sd.floor 5')
    settle(82)
    wait(lambda:NEXT in command(f'data get entity {PLAYER} Dimension') and status('#ready')==1,'arrive in independent floor 2',90)
    profile=storage('next_profile')
    assert all(f'{key}: 1b' in profile for key in ('rich','black','injured')),profile
    assert status('#lumen')==11 and status('#budget')==8
    second=cells()
    assert len(second)==16 and sum(room[2]=='gamble' for room in second.values())==1
    assert 'Found no elements' in storage('shrub')
    assert str(NEXT_MAP) in command(f'data get entity {PLAYER} Inventory[{{Slot:8b}}].components."minecraft:map_id"')
    print('Floor 2 preserved funds; all three modifiers were recorded, with one forced gamble and its own map.',flush=True)


if __name__=='__main__':
    verify()
