// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AutoChessEntryFunc {
    enum stage {
        init,
        fighting1,
        fighting2,
        onHit,
        destory,
        effect,
        ending
    }

    struct CardInstance {
        uint256 _id;
        bool _isEffects; // 效果是否处理
        uint256 _star;
        uint256[] _cardTypes;
        uint256[] _cardEntrys;
        uint256[] _cardAttributes; // 0 攻击，1 生命
        bool _isDestory;
    }

    struct fightData {
        CardInstance[] ownerCards;
        CardInstance[] otherCards;
    }

    struct funcStruct {
        bool isSet;
        function(
            uint256,
            uint256,
            stage,
            CardInstance[] memory,
            CardInstance[] memory,
            uint256
        ) _func;
    }

    struct EntryFunc {
        mapping(uint256 => funcStruct) _typeFunction;
    }

    function addHander(
        EntryFunc storage funcMap,
        uint256 index,
        function(
            uint256,
            uint256,
            AutoChessEntryFunc.stage,
            AutoChessEntryFunc.CardInstance[] memory,
            AutoChessEntryFunc.CardInstance[] memory,
            uint256
        ) callBack
    ) internal {
        funcMap._typeFunction[index] = AutoChessEntryFunc.funcStruct({
            isSet: true,
            _func: callBack
        });
    }

    function dispatch(
        EntryFunc storage funcMap,
        uint256 cardIndex,
        uint256 entryId,
        uint256 targetCardIndex,
        stage pipType,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards,
        uint256 harm
    ) internal {
        funcStruct memory _func = funcMap._typeFunction[entryId];
        if (_func.isSet) {
            _func._func(
                cardIndex,
                targetCardIndex,
                pipType,
                ownerCards,
                otherCards,
                harm
            );
        }
    }

    function dispatchAllFight(
        EntryFunc storage funcMap,
        uint256 ownerCardIndex,
        uint256 otherCardIndex,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards,
        stage pipTyle,
        uint256 harm
    ) internal {
        for (uint256 index = 0; index < ownerCards.length; index++) {
            for (uint256 j = 0; j < ownerCards[index]._cardEntrys.length; j++) {
                dispatch(
                    funcMap,
                    index,
                    ownerCards[index]._cardEntrys[j],
                    otherCardIndex,
                    pipTyle,
                    ownerCards,
                    otherCards,
                    harm
                );
            }
        }
        for (uint256 index = 0; index < otherCards.length; index++) {
            for (uint256 j = 0; j < otherCards[index]._cardEntrys.length; j++) {
                dispatch(
                    funcMap,
                    index,
                    otherCards[index]._cardEntrys[j],
                    ownerCardIndex,
                    pipTyle,
                    otherCards,
                    ownerCards,
                    harm
                );
            }
        }
    }

    function doFightingTo(
        EntryFunc storage funcMap,
        uint256 ownerCardIndex,
        uint256 otherCardIndex,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards,
        stage pipTyle
    ) internal {
        if (otherCards[otherCardIndex]._isDestory) return;
        if (otherCards[otherCardIndex]._cardTypes[0] != 0) {
            otherCards[otherCardIndex]._isDestory = true;
            dispatchAllFight(
                funcMap,
                ownerCardIndex,
                otherCardIndex,
                ownerCards,
                otherCards,
                stage.destory,
                ownerCards[ownerCardIndex]._cardAttributes[0]
            );
            return;
        }
        if (
            otherCards[otherCardIndex]._cardAttributes[1] >
            ownerCards[ownerCardIndex]._cardAttributes[0]
        ) {
            otherCards[otherCardIndex]._cardAttributes[1] -= ownerCards[
                ownerCardIndex
            ]._cardAttributes[0];
            dispatchAllFight(
                funcMap,
                ownerCardIndex,
                otherCardIndex,
                ownerCards,
                otherCards,
                pipTyle,
                ownerCards[ownerCardIndex]._cardAttributes[0]
            );
            return;
        }
        otherCards[otherCardIndex]._cardAttributes[1] = 0;
        otherCards[otherCardIndex]._isDestory = true;
        dispatchAllFight(
            funcMap,
            ownerCardIndex,
            otherCardIndex,
            ownerCards,
            otherCards,
            stage.destory,
            ownerCards[ownerCardIndex]._cardAttributes[0]
        );
    }

    function doFightingOne(
        EntryFunc storage funcMap,
        uint256 ownerCardIndex,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) internal {
        for (uint256 j = 0; j < otherCards.length; j++) {
            doFightingTo(
                funcMap,
                ownerCardIndex,
                j,
                ownerCards,
                otherCards,
                stage.fighting1
            );
        }
    }

    function doFighting(
        EntryFunc storage funcMap,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) internal {
        for (uint8 i = 0; i < ownerCards.length; i++) {
            doFightingOne(funcMap, i, ownerCards, otherCards);
        }
    }
}
