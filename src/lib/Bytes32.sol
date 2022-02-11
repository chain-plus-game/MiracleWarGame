// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Bytes32 {
    
    function bytes32ToStr(bytes32 _bytes32)
        public pure 
        returns (string memory)
        {
            // string memory str = string(_bytes32);
            // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
            // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)
        
            bytes memory bytesArray = new bytes(32);
            for (uint256 i; i < 32; i++) {
                bytesArray[i] = _bytes32[i];
                }
            return string(bytesArray);
        }
}
