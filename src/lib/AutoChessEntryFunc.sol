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
        ending
    }

    struct CardInstance {
        uint256 _id;
        bool _isEffects; // 效果是否处理
        uint256 _star;
        uint256[] _cardTypes;
        uint256[] _cardEntrys;
        uint256[] _cardAttributes; // 0 攻击，1 生命
    }

    struct fightData {
        CardInstance[] ownerCards;
        CardInstance[] otherCards;
    }

    struct EntryFunc {
        mapping(uint256 => function(
            uint256,
            uint256,
            stage,
            CardInstance[] memory,
            CardInstance[] memory
        )) typeFunction;
    }

    function init(EntryFunc storage map) internal {
        map.typeFunction[1] = heroic;
    }

    event useCard(address indexed _address, uint256 tokenId);

    function dispatch(
        EntryFunc storage funcMap,
        uint256 cardIndex,
        uint256 entryId,
        stage pipType,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) internal {
        funcMap.typeFunction[entryId](
            cardIndex,
            entryId,
            pipType,
            ownerCards,
            otherCards
        );
    }

    function heroic(
        uint256 cardIndex,
        uint256 entryIndex,
        stage pipType,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) private {
        // emit useCard(msg.sender, index);
    }

    event initCardGroupStart(uint8 indexed owner, CardInstance[] cardIndex);

    function start(fightData memory _fight, EntryFunc storage funcMap)
        internal
    {
        initCardGroup(_fight.ownerCards, _fight.otherCards, funcMap);
        emit initCardGroupStart(0, _fight.ownerCards);
        initCardGroup(_fight.otherCards, _fight.ownerCards, funcMap);
        emit initCardGroupStart(1, _fight.otherCards);
    }

    function initCardGroup(
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards,
        EntryFunc storage funcMap
    ) private {
        for (uint256 index = 0; index < ownerCards.length; index++) {
            for (
                uint256 entryIndex = 0;
                entryIndex < ownerCards[index]._cardEntrys.length;
                entryIndex++
            ) {
                uint256 entryId = ownerCards[index]._cardEntrys[entryIndex];
                dispatch(
                    funcMap,
                    index,
                    entryId,
                    stage.init,
                    ownerCards,
                    otherCards
                );
            }
        }
    }
}
