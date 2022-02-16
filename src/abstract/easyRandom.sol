// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

abstract contract EasyRandom {
    uint256 randNonce = 0;

    function randomCardStar(uint256 max) internal returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(
                    uint256(uint160(msg.sender)),
                    block.difficulty,
                    block.timestamp,
                    randNonce
                )
            )
        );
        uint256 maxVal = max * 100;
        uint256 firstRandom = (randomHash % maxVal) +
            msg.value /
            100000000000000;
        if (firstRandom > maxVal) {
            firstRandom = maxVal;
        }
        uint256 ramMax = max * 10;
        randNonce++;
        return firstRandom / ramMax;
    }
}
