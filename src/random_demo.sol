// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./safemath.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract VRFD20 is VRFConsumerBase, ConfirmedOwner(msg.sender) {
    
    //引入safemath库
    using SafeMath for uint256;
    
    // variables
    bytes32 private s_keyHash;
    uint256 private s_fee;
    mapping(bytes32 => address) private s_rollers;
    mapping(address => uint256) private s_results;
    
    uint256 private constant ROLL_IN_PROGRESS = 42;
    
    // constructor
    constructor(address vrfCoordinator, address link, bytes32 keyHash, uint256 fee)
        VRFConsumerBase(vrfCoordinator, link)
    {
        s_keyHash = keyHash;
        s_fee = fee;
    }

    // events
    event DiceRolled(bytes32 indexed requestId, address indexed roller);
    event DiceLanded(bytes32 indexed requestId, uint256 indexed result);

    // rollDice function
    function rollDice(address roller) public onlyOwner returns (bytes32 requestId) {
        // checking LINK balance
        require(LINK.balanceOf(address(this)) >= s_fee, "Not enough LINK to pay fee");

        // checking if roller has already rolled die
        require(s_results[roller] == 0, "Already rolled");

        // requesting randomness
        requestId = requestRandomness(s_keyHash, s_fee);

        // storing requestId and roller address
        s_rollers[requestId] = roller;

        // emitting event to signal rolling of die
        s_results[roller] = ROLL_IN_PROGRESS;
        emit DiceRolled(requestId, roller);
    }

    // fulfillRandomness function
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {

        // transform the result to a number between 1 and 20 inclusively
        uint256 d20Value = (randomness % 20) + 1;

        // assign the transformed value to the address in the s_results mapping variable
        s_results[s_rollers[requestId]] = d20Value;

        // emitting event to signal that dice landed
        emit DiceLanded(requestId, d20Value);
    }

    // house function
    function house(address player) public view returns (string memory) {
        // dice has not yet been rolled to this address
        require(s_results[player] != 0, "Dice not rolled");

        // not waiting for the result of a thrown die
        require(s_results[player] != ROLL_IN_PROGRESS, "Roll in progress");

        // returns the house name from the name list function
        return getHouseName(s_results[player]);
    }

    // getHouseName function
    function getHouseName(uint256 id) private pure returns (string memory) {        
        // array storing the list of house's names
        string[20] memory houseNames = [
            "Targaryen",
            "Lannister",
            "Stark",
            "Tyrell",
            "Baratheon",
            "Martell",
            "Tully",
            "Bolton",
            "Greyjoy",
            "Arryn",
            "Frey",
            "Mormont",
            "Tarley",
            "Dayne",
            "Umber",
            "Valeryon",
            "Manderly",
            "Clegane",
            "Glover",
            "Karstark"
        ];

        // returns the house name given an index
        return houseNames[id.sub(1)];
    }
}
