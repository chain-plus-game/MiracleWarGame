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
        uint rand;
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
            CardInstance[] memory
        ) _func;
    }

    struct EntryFunc {
        mapping(uint256 => funcStruct) typeFunction;
    }

    function addHander(
        EntryFunc storage map,
        uint256 index,
        function(
            uint256,
            uint256,
            stage,
            CardInstance[] memory,
            CardInstance[] memory
        ) callBack
    ) private {
        map.typeFunction[index] = funcStruct({isSet: true, _func: callBack});
    }

    function init(EntryFunc storage map) internal {
        addHander(map, 1, heroic);
        addHander(map, 2, heroic);
        addHander(map, 3, heroic);
        addHander(map, 4, heroic);
        addHander(map, 5, heroic);
    }

    event useCard(address indexed _address, uint256 tokenId, uint256 entryId);

    function dispatch(
        EntryFunc storage funcMap,
        uint256 cardIndex,
        uint256 entryId,
        stage pipType,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) internal {
        funcStruct memory _func = funcMap.typeFunction[entryId];
        if (_func.isSet) {
            _func._func(cardIndex, entryId, pipType, ownerCards, otherCards);
        }
    }


    event heroicEvent(uint indexed cardIndex,CardInstance _card);
    function heroic(
        uint256 cardIndex,
        uint256 entryIndex,
        stage pipType,
        CardInstance[] memory ownerCards,
        CardInstance[] memory otherCards
    ) private {
        emit useCard(
            msg.sender,
            ownerCards[cardIndex]._id,
            ownerCards[cardIndex]._cardEntrys[entryIndex]
        );
        uint cardTypesId = ownerCards[cardIndex]._cardTypes[0];
        if (cardTypesId == 1 && pipType == stage.init){
            ownerCards[cardIndex]._cardAttributes[0] += ownerCards[cardIndex]._star*2;
            ownerCards[cardIndex]._cardAttributes[1] += ownerCards[cardIndex]._star;
        }
        if (cardTypesId == 2){
            // 己方所有当前单位上升掷点数值的攻击力
            uint rand = randomCardStar(6, ownerCards[cardIndex].rand);
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[0] += rand;
            }
        }
        if (cardTypesId == 3){
            // 己方所有单位的防御力上升此卡星级*1的数值
            for (uint256 index = 0; index < ownerCards.length; index++) {
                ownerCards[index]._cardAttributes[1] += ownerCards[cardIndex]._star;
            }
        }
        emit heroicEvent(cardIndex,ownerCards[cardIndex]);
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

    event randomEvent(uint indexed rand);
    function randomCardStar(uint256 max,uint rand) internal returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(
                    uint256(uint160(msg.sender)),
                    block.difficulty,
                    block.timestamp,
                    rand
                )
            )
        );
        uint256 num = randomHash % max;
        emit randomEvent(num);
        return num;
    }
}
