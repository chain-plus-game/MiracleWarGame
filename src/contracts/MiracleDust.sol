 // SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract MiracleDust is ERC777 {

    address _miracleCard = address(0);
    address _owner = address(0);

    // 这里是构造函数, 实例创建时候执行
    constructor(uint256 initialSupply, address cardAddress,address defaultMint,address owner, address[] memory defaultOperators)
            ERC777("MiracleDust","MDT",defaultOperators) 
    {
        _owner = owner;
        _miracleCard = cardAddress;
        uint _totalSupply = initialSupply * 10 ** uint256(decimals());  // 这里确定了总发行量
        _mint(defaultMint,_totalSupply,"","");
    }

    function miracleCardAddress() public view returns(address){
        return _miracleCard;
    }

    function addDust(address to, uint num) public {
        require(_miracleCard != address(0), "miracleCard address is not set");
        require(msg.sender == _miracleCard, "This method can only be called by the specified contract");

        require(to != address(0), "ERC1155: mint to the zero address");
        uint addNum = num * 10 ** uint256(decimals());
        _mint(to, addNum,"","");
    }

    function BurnFromRechargeCard(address fromAddress,uint num) public {
        require(_miracleCard != address(0), "miracleCard address is not set");
        require(msg.sender == _miracleCard, "This method can only be called by the specified contract");
        uint dust = num * 10 ** uint256(decimals());
        _burn(fromAddress, dust,"","");
    }
}
