// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.8.0;

import "./ERC1155.sol";


/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract _CONTRACT_NAME is ERC1155 {
    uint256 public constant ID01 = 1;
    uint256 public constant ID02 = 2;
    uint256 public constant ID03 = 3;
    uint256 public constant ID04 = 4;
    uint256 public constant ID05 = 5;
    uint256 public constant ID06 = 6;
    uint256 public constant ID07 = 7;
    uint256 public constant ID08 = 8;
    uint256 public constant ID09 = 9;
    uint256 public constant ID10 = 10;
    
/** @dev  Replace "TOKEN" with your token name & "_XXXX_" with your token symbol */ 
    string public name = "Miracle";
    string public symbol = "_Miracle_";
    
    /** @dev Use ERC-1155 metadata standard for your JSON file & use hexadecimal of your token ID in _file_name.json */

    constructor()
        ERC1155("https://address/{id}.json")
        
/** @dev If you want tokens to be non-fungible, value must be 1 */        
    {
        _mint(msg.sender, ID01, 1, "");
        _mint(msg.sender, ID02, 1, "");
        _mint(msg.sender, ID03, 1, "");
        _mint(msg.sender, ID04, 1, "");
        _mint(msg.sender, ID05, 1, "");
        _mint(msg.sender, ID06, 1, "");
        _mint(msg.sender, ID07, 1, "");
        _mint(msg.sender, ID08, 1, "");
        _mint(msg.sender, ID09, 1, "");
        _mint(msg.sender, ID10, 1, "");
    }


    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _ownerOf(tokenId);
    }

    function addNft(string tokenName,uint256 id,uint256 nonFungible){
        _mint(msg.sender, id, nonFungible, "");
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, 1, "");
    }

    /*  
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to); */
}
