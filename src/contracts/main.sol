// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "./GamePlusToken.sol";
import "./MiracleCard.sol";
import "./MiracleDust.sol";
import "./AutoChess.sol";

contract MainDeploy {
    GamePlusToken private _GPTToken;
    MiracleCard private _CardToken;
    MiracleDust private _MiracleDustToken;
    GameAutoCheess private _CheessGame;

    // 这里是构造函数, 实例创建时候执行
    constructor() {
        _GPTToken = new GamePlusToken(10000);
        _CardToken = new MiracleCard(payable(_GPTToken));
        address[] memory defaultOperators = new address[](1);
        defaultOperators[0] = msg.sender;
        _MiracleDustToken = new MiracleDust(
            100000,
            address(_CardToken),
            msg.sender,
            msg.sender,
            defaultOperators
        );
        _CheessGame = new GameAutoCheess(address(_CardToken));
    }

    function getGamePlusAddress() public view returns (address) {
        return address(_GPTToken);
    }

    function getMiracleCardAddress() public view returns (address) {
        return address(_CardToken);
    }

    function getMiracleDustAddress() public view returns (address) {
        return address(_MiracleDustToken);
    }

    function getGameAutoCheessAddress() public view returns (address) {
        return address(_CheessGame);
    }
}
