// SPDX-License-Identifier: MIT
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

    constructor(address card) {
        cardNFT = MiracleCard(card);
        typeFunction.init();
    }

    function Authorize() public {
        _holderAddress.add(uint256(uint160(msg.sender)));
    }

    function challenge() public {
        typeFunction.dispatch(1);
    }
}
