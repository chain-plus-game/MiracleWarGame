// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

abstract contract BaseGame {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        // Modifier
        require(msg.sender == _owner, "Only owner can call this.");
        _;
    }

    function owner()public view returns(address) {
        return _owner;
    }
}
