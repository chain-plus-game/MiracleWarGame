// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../../abstract/easyRandom.sol";
import "../../lib/AutoChessEntryFunc.sol";
import "../../interface/IGameAutoCheessRoom.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GameAutoCheessRoom is EasyRandom, IGameAutoCheessRoom {
    using SafeMath for uint256;
    using AutoChessEntryFunc for AutoChessEntryFunc.EntryFunc;
    using AutoChessEntryFunc for AutoChessEntryFunc.CardInstance;
    using AutoChessEntryFunc for AutoChessEntryFunc.fightData;

    using EnumerableSet for EnumerableSet.UintSet;

    AutoChessEntryFunc.EntryFunc private _funcMap;
    EnumerableSet.UintSet private _holderAddress;

    constructor() {
        _funcMap.addHander(1, heroic);
        _funcMap.addHander(2, heroic);
        _funcMap.addHander(3, heroic);
        _funcMap.addHander(4, heroic);
        _funcMap.addHander(5, heroic);
    }

    function initCardGroup(
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory otherCards
    ) private {
        for (uint256 index = 0; index < ownerCards.length; index++) {
            for (
                uint256 entryIndex = 0;
                entryIndex < ownerCards[index]._cardEntrys.length;
                entryIndex++
            ) {
                uint256 entryId = ownerCards[index]._cardEntrys[entryIndex];
                _funcMap.dispatch(
                    index,
                    entryId,
                    AutoChessEntryFunc.stage.init,
                    ownerCards,
                    otherCards,
                    0
                );
            }
        }
    }

    function start(AutoChessEntryFunc.fightData memory _fight)
        public
        returns (uint8)
    {
        // init->第一轮效果->第二轮效果
        // 过一遍init
        initCardGroup(_fight.ownerCards, _fight.otherCards);
        emit initCardGroupStart(0, _fight.ownerCards);
        initCardGroup(_fight.otherCards, _fight.ownerCards);
        emit initCardGroupStart(1, _fight.otherCards);
        GameState winner = GameState.running;
        uint8 roundNum = 1;
        while (true) {
            winner = clickOver(_fight);
            if (winner != GameState.running) {
                break;
            }
            _funcMap.doFighting(_fight.otherCards, _fight.ownerCards);
            winner = clickOver(_fight);
            if (winner != GameState.running) {
                break;
            }
            _funcMap.doFighting(_fight.ownerCards, _fight.otherCards);
            roundNum += 1;
            emit eventRoundEnds(roundNum, _fight.ownerCards, _fight.otherCards);
        }
        return 0;
    }

    function clickOver(AutoChessEntryFunc.fightData memory _fight)
        internal
        pure
        returns (GameState)
    {
        bool ownerDel = true;
        for (uint256 index = 0; index < _fight.ownerCards.length; index++) {
            if (
                _fight.ownerCards[index]._cardTypes[0] == 1 &&
                _fight.ownerCards[index]._cardAttributes[1] > 0
            ) {
                ownerDel = false;
            }
        }
        bool otherDel = true;
        for (uint256 index = 0; index < _fight.otherCards.length; index++) {
            if (
                _fight.otherCards[index]._cardTypes[0] == 1 &&
                _fight.otherCards[index]._cardAttributes[1] > 0
            ) {
                otherDel = false;
            }
        }
        if (ownerDel && !otherDel) {
            return GameState.targetWiner;
        }
        if (!ownerDel && otherDel) {
            return GameState.ownerWiner;
        }
        return GameState.running;
    }

    function charge(
        uint256 cardIndex,
        uint256,
        AutoChessEntryFunc.stage pipType,
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory otherCards,
        uint256
    ) private {
        uint256 cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.init) {
            ownerCards[cardIndex]._cardAttributes[0] +=
                ownerCards[cardIndex]._star *
                1;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]
                ._star;
        }
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.fighting2) {
            _funcMap.doFightingOne(cardIndex, ownerCards, otherCards);
        }
        if (cardTypesId == 2) {
            // 点数>3时，使生命值最高的友军对生命值最低的敌军进行一次攻击
            uint256 rand = random(6);
            if (rand > 3) {
                uint256 max = 0;
                uint256 maxIndex = 0;
                for (uint256 index = 0; index < ownerCards.length; index++) {
                    if (ownerCards[index]._cardAttributes[1] > max) {
                        max = ownerCards[index]._cardAttributes[1];
                        maxIndex = index;
                    }
                }
            }
        }
        if (cardTypesId == 3) {
            // 己方所有单位的防御力上升此卡星级*1的数值
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[1] += ownerCards[cardIndex]
                    ._star;
            }
        }
    }

    function heroic(
        uint256 cardIndex,
        uint256,
        AutoChessEntryFunc.stage pipType,
        AutoChessEntryFunc.CardInstance[] memory ownerCards,
        AutoChessEntryFunc.CardInstance[] memory,
        uint256
    ) private {
        uint256 cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == AutoChessEntryFunc.stage.init) {
            ownerCards[cardIndex]._cardAttributes[0] +=
                ownerCards[cardIndex]._star *
                2;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]
                ._star;
            emit heroicEvent(cardIndex, ownerCards[cardIndex]);
        }
        if (pipType == AutoChessEntryFunc.stage.init) return;
        if (cardTypesId == 2) {
            // 己方所有当前单位上升掷点数值的攻击力
            uint256 rand = random(6);
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[0] += rand;
            }
        }
        if (cardTypesId == 3) {
            // 己方所有单位的防御力上升此卡星级*1的数值
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[1] += ownerCards[cardIndex]
                    ._star;
            }
        }
        emit heroicEvent(cardIndex, ownerCards[cardIndex]);
    }
}
