// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "./MiracleCard.sol";
import "../lib/AutoChessEntryFunc.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GameAutoCheess {
    using SafeMath for uint256;
    using AutoChessEntryFunc for AutoChessEntryFunc.EntryFunc;
    using EnumerableSet for EnumerableSet.UintSet;
    MiracleCard public cardNFT;
    AutoChessEntryFunc.EntryFunc private typeFunction;
    EnumerableSet.UintSet private _holderAddress;

    uint256 public cardGroupLength = 5;
    mapping(address => uint256[]) private _cardGroup;

    constructor(address card) {
        cardNFT = MiracleCard(card);
        typeFunction.init();
    }

    function Authorize() public {
        _holderAddress.add(uint256(uint160(msg.sender)));
    }

    function addressCardGroup(address _add)
        public
        view
        returns (uint256[] memory)
    {
        return _cardGroup[_add];
    }

    event updateCardGroup(address indexed _address, uint256[] tokenIds);

    function setCardGroup(uint256[] memory group) public {
        require(group.length > cardGroupLength, "can not set group length");
        require(cardNFT.cardCanUse(msg.sender, group), "card can not use");
        _cardGroup[msg.sender] = group;
        emit updateCardGroup(msg.sender, group);
    }

    function challenge() public {
        typeFunction.dispatch(1);
    }
}
