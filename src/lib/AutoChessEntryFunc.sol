// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AutoChessEntryFunc {
    struct EntryFunc {
        mapping(uint256 => function(uint256)) typeFunction;
    }

    function init(EntryFunc storage map) internal {
        map.typeFunction[1] = heroic;
    }

    event useCard(address indexed _address, uint256 tokenId);

    function dispatch(EntryFunc storage funcMap, uint256 eventId) internal {
        funcMap.typeFunction[eventId](eventId);
    }

    function heroic(uint256 index) private {
        emit useCard(msg.sender, index);
    }
}
