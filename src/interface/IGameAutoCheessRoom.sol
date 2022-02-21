// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
import "../lib/AutoChessEntryFunc.sol";

interface IGameAutoCheessRoom {
    enum GameState {
        running,
        ownerWiner,
        targetWiner
    }
    event initCardGroupStart(
        uint8 indexed owner,
        AutoChessEntryFunc.CardInstance[] cardIndex
    );
    event eventRoundEnds(
        uint8 indexed roundNum,
        AutoChessEntryFunc.CardInstance[] ownerCard,
        AutoChessEntryFunc.CardInstance[] otherCard
    );
    event heroicEvent(
        uint256 indexed cardIndex,
        AutoChessEntryFunc.CardInstance _card
    );

    event chargeEvent(
        uint256 indexed cardIndex,
        AutoChessEntryFunc.CardInstance _card
    );
}