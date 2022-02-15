// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MiracleCard.sol";
import "../lib/AutoChessEntryFunc.sol";

contract GameAutoCheess {
    MiracleCard public cardNFT;

    using AutoChessEntryFunc for AutoChessEntryFunc.EntryFunc;
    AutoChessEntryFunc.EntryFunc private typeFunction;

    constructor(address card) {
        cardNFT = MiracleCard(card);
        typeFunction.init();
    }

    function challenge() public{
        typeFunction.dispatch(1);
    }


}
