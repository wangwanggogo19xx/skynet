#!/usr/bin/env python
# coding:utf-8

import re
def legal_hand(s):
    '''
    tile: [0-9][wtb] or [dnxbzfb]
    input like '1w 2w 3w 4w 4w 4w 1t 2t 3t d d d b b'
    '''
    def next_tile(tile):
        if not tile or len(tile) == 1:
            return
        try:
            a = int(tile[0])
            if a == 9:
                return
            return str(a+1)+tile[1]
        except:
            return
    def last_tile(tile):
        if not tile or len(tile) == 1:
            return
        try:
            a = int(tile[0])
            if a == 1:
                return
            return str(a-1)+tile[1]
        except:
            return
    def chow_available(dct, tile):  # get all possible chows(顺子) 
        res = []
        if not tile or tile not in dct or dct[tile] == 0:
            return []
        l1 = last_tile(tile)
        l2 = last_tile(l1)
        n1 = next_tile(tile)
        n2 = next_tile(n1)
        # if target tile has two neibour(a chow), 
        # add the chow into candidate operators
        if dct.get(l1, 0) > 0:
            if dct.get(l2, 0) > 0:
                res.append([l2, l1, tile])
            if dct.get(n1, 0) > 0:
                res.append([l1, tile, n1])
        if dct.get(n1, 0) > 0 and dct.get(n2, 0) > 0:
            res.append([tile, n1, n2])
        return res

    def pong_available(dct, tile):  # get all possible pongs(刻子)
        if not tile or tile not in dct or dct[tile] == 0:
            return []
        if dct[tile] >= 3:
            return [[tile, tile, tile]]
        return []

    def just_one_pair(dct):  # judge if only one pair(对子/将) remains
        pairs = 0
        for tile in dct:
            if dct[tile] > 0 and dct[tile] !=2:
                return False
            if dct[tile] == 2:
                pairs += 1
        return pairs == 1

    def operate(dct, operator):  # remove tiles in the operator(chow or pong) 
        newdct = {}
        newdct.update(dct)
        for tile in operator:
            if tile not in dct or dct[tile] < 1:
                print('wrong operator:')
                print(dct)
                print(operator)
                raise('wrong operator')
            newdct[tile] -= 1
            if newdct[tile] <= 0:
                newdct.pop(tile)
                pass
        return newdct

    def one_step(dct, top_step = False):
        # use iteration to remove chows/pongs from the tiles, until finding a legal hand
        for tile in dct:
            operators = chow_available(dct, tile) + pong_available(dct, tile) 
            # find all possible operators(chows and pongs)
            if not operators:
                if just_one_pair(dct): 
                # no chows and pongs, and only one pair remains, legal hand
                    return True
            for operator in operators:
                newdct = operate(dct, 
                ) # remove chow/pong, iterate
                if one_step(newdct):
                    return True
        return False # find nothing
    
    # main part
    s = s.split(' ')
    for ch in s: # judge availablity
        if not (re.match(r'^[0-9][wtb]$', ch) or ch in 'dnxbzfb'): 
            raise('Invalid Input String')
    
    # save as hash form
    dct = {}
    for tile in s:
        if tile in dct:
            dct[tile] += 1
        else:
            dct[tile] = 1
    return one_step(dct, top_step = True)

# tests
if __name__ == '__main__':
    print(legal_hand('1w 2w 3w 3w 3w 3w 1t 2t 3t d d d b b'))
    print(legal_hand('1w 1w 1w 2w 3w 4w 4w 5w 6w 1t 1t 1t'))
    print(legal_hand('1w 1w 1w 1w 2w 2w 2w 2w 2w 2w 2w 2w 3w'))