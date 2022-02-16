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
        mapping(uint256 => function(uint256, CardInstance memory)) typeFunction;
    }

    function init(EntryFunc storage map) internal {
        map.typeFunction[1] = heroic;
    }

    event useCard(address indexed _address, uint256 tokenId);

    function dispatch(
        EntryFunc storage funcMap,
        uint256 eventId,
        CardInstance memory card
    ) internal {
        funcMap.typeFunction[eventId](eventId, card);
    }

    function heroic(uint256 index, CardInstance memory card) private {
        emit useCard(msg.sender, index);
    }

    
}
