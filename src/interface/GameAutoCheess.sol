// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
import "../lib/AutoChessEntryFunc.sol";

interface IGameAutoCheess {

    event updateCardGroup(address indexed _address, uint256[] tokenIds);

    event eventInitCardGroup(
        address indexed _from,
        address to,
        AutoChessEntryFunc.fightData
    );

    event battleOver(
        address indexed _winerAddress,
        address failAddress,
        uint256 winAddScore,
        uint256 winSCoreBefore,
        uint256 failSubScore,
        uint256 failSocreBefore
    );
}
