// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

abstract contract EasyRandom {
    uint256 randNonce = 0;

    event randomEvent(uint256 indexed rand);
    function random(uint256 max) internal returns (uint256) {
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
        randNonce ++;
        uint256 num = randomHash % max;
        emit randomEvent(num);
        return num;
    }
}
