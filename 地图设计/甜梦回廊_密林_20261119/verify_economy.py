"""Smoke-test the merchant and combat reward entry points in a private Forest world."""

import re

from world import ROOT, native
from verify_dimension import at_floor, enter, visit
from verify import PLAYER, phase, status, storage, tags, trigger, wait


def configure():
    native.WORK = ROOT / ".workbuddy/rogue_forest_economy_20261123"
    native.NATIVE = native.WORK / "native"
    native.rcon.D = native.NATIVE


def lumen():
    return status("#lumen", "sd.floor")


def selected():
    return native.c(f"data get entity {PLAYER} SelectedItem")


def field(record, key):
    return re.search(rf'{key}: (?:"([^"]+)"|(\d+))', record).group(1, 2)


def verify():
    configure()
    if PLAYER not in native.c('list'):
        native.clients()
    if 'sd.floor_run' in tags(PLAYER):
        trigger(3)
        wait(lambda: phase() == 0 and status('#rv_clean', 'zx.meta') == 0, 'leave the previous probe run')
    rooms = enter()
    merchant = next(room for room in rooms.values() if room[2] == "merchant")
    visit(merchant)
    trigger(23)
    wait(lambda: 'code: 72' in storage('merchant.stock'), 'merchant fills all three stock positions')
    first = storage('merchant.stock[0]')
    price = int(field(first, "price")[1])
    identifier = field(first, "id")[0]
    assert price in (3, 4, 5, 7), first
    trigger(23)
    assert storage('merchant.stock[0]') == first
    trigger(70)
    wait(lambda: status(PLAYER, 'sd.floor_cmd') == 0, 'resolve insufficient funds')
    assert lumen() == 0 and 'code: 70' not in storage('merchant.bought')
    native.c('scoreboard players set #lumen sd.floor 30')
    native.c(f'clear {PLAYER}')
    trigger(70)
    wait(lambda: lumen() == 30 - price, 'purchase first merchant offer')
    assert identifier in selected(), selected()
    assert f'sd_floor_refund: {price // 5 + 1}' in selected(), selected()
    trigger(70)
    wait(lambda: status(PLAYER, 'sd.floor_cmd') == 0, 'resolve a repeated purchase')
    assert lumen() == 30 - price
    trigger(74)
    wait(lambda: 'value: ' in storage('sale'), 'quote held item')
    trigger(75)
    wait(lambda: lumen() == 30 - price + price // 5 + 1, 'resell held equipment')
    assert identifier not in selected()
    trigger(75)
    wait(lambda: status(PLAYER, 'sd.floor_cmd') == 0, 'resolve a repeated resale')
    assert lumen() == 30 - price + price // 5 + 1
    print('Merchant has persistent stock, rejects duplicate purchases and pays actual-price resale.')

    before = lumen()
    trigger(73)
    wait(lambda: phase() == 3, 'merchant category menu')
    assert lumen() == before - 5
    assert storage('choosing_category').strip().endswith('1b')
    trigger(39)
    wait(lambda: 'tag:' in storage('offers[0]'), 'armor tags offered')
    assert 'armor' in storage('draw_category')
    assert int(re.search(r': (\d+)\s*$', storage('exact_tier'))[1]) >= 2
    trigger(30)
    wait(lambda: phase() == 1, 'claim armor')
    assert 'armor' in selected() and 'sd_floor_refund' in selected(), selected()
    assert lumen() == before - 5
    trigger(73)
    wait(lambda: status(PLAYER, 'sd.floor_cmd') == 0, 'resolve repeated merchant draw')
    assert phase() == 1 and lumen() == before - 5
    print('Paid draw is one-time, starts at tier 2 and awards armor when selected.')

    combat = next(room for room in rooms.values() if room[2] == 'combat')
    visit(combat)
    trigger(20)
    wait(lambda: phase() == 2, 'real combat begins')
    before = lumen()
    at_floor('kill @e[tag=sd.floor_enemy]')
    wait(lambda: phase() == 3, 'combat clears into typed reward')
    assert lumen() == before + 1
    trigger(38)
    wait(lambda: 'tag:' in storage('offers[0]'), 'weapon tags offered')
    assert 'weapon' in storage('draw_category')
    native.c(f'clear {PLAYER}')
    trigger(30)
    wait(lambda: phase() == 1, 'claim weapon')
    assert 'sd_floor_refund' in selected() and any(f'"{x}"' in selected() for x in ('sword', 'axe', 'bow', 'staff')), selected()
    print('Actual combat awards 1 shard and a typed weapon. Offhand candidates stay outside both draw categories.')

    visit(merchant)
    for kind, prices in [('alpha', (8, 10)), ('offhand', (12, 15))]:
        native.c('data modify storage sweetdream_floor:run merchant.stock set value []')
        native.c('data modify storage sweetdream_floor:run merchant.bought set value []')
        native.c('scoreboard players set #stock_code sd.floor 70')
        at_floor(f'function sweetdream_floor:market/{kind}')
        offer = storage('merchant.stock[0]')
        cost = int(field(offer, 'price')[1])
        assert cost in prices, offer
        native.c(f'clear {PLAYER}')
        native.c('scoreboard players set #lumen sd.floor 20')
        trigger(70)
        wait(lambda: lumen() == 20 - cost, f'purchase {kind}')
        assert f'sd_floor_refund: {cost // 2 + 1}' in selected(), selected()
        trigger(74)
        wait(lambda: 'value: ' in storage('sale'), f'quote {kind}')
        trigger(75)
        wait(lambda: lumen() == 20 - cost + cost // 2 + 1, f'resell {kind}')
    print('Both upgrade and offhand resales use half the actual price rounded down, plus one.')


if __name__ == '__main__':
    verify()
