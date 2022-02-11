// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155CardGame.sol";
import "./MiracleDust.sol";

/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract MiracleCard is ERC1155 {
    
    address _owner = address(0);
    address payable packTo;
    /** @dev  Replace "TOKEN" with your token name & "_XXXX_" with your token symbol */
    string public name = "MiracleNFT";
    string public symbol = "MiracleNFT";

    uint[] public _entrys = [1,2,3,4,5];
    uint public _entrysLength = 5;
    uint public useCast = 5;
    uint public useCastProportion = 50;
    
    MiracleDust public MiracleDustToken;
    /** @dev Use ERC-1155 metadata standard for your JSON file & use hexadecimal of your token ID in _file_name.json */

    constructor(address payable payTo, uint initDustNum)
        ERC1155("https://nft.fuakorm.com/{id}.json")
    /** @dev If you want tokens to be non-fungible, value must be 1 */
    {
        packTo = payTo;
        _owner = msg.sender;
        address[] memory owners = new address[](1);
        owners[0] = msg.sender;
        MiracleDustToken = new MiracleDust(initDustNum, address(this), payTo, _owner, owners);
    }

   // 默认位数，即小数点后几位
    function decimals() public view virtual returns (uint8) {
        return 0;
    }

    function setMDT(address mdtAddress) public{
        MiracleDustToken = MiracleDust(mdtAddress);
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _ownerOf(tokenId);
    }

    // function addNft(uint256 id, uint256 nonFungible) public {
    //     require(msg.sender == _owner,"This method must be the owner to be called");
    //     _mint(msg.sender, id, nonFungible, "");
    // }

    function setURI(string memory newuri) public {
        require(msg.sender == _owner,"This method must called by owner");
        _setURI(newuri);
    }

    function setEntrys(uint[] memory entrys) public{
        require(msg.sender == _owner,"This method must called by owner");
        _entrys = entrys;
    }

    function setEntrysLength(uint newEntrysLength) public{
        require(msg.sender == _owner,"This method must called by owner");
        _entrysLength = newEntrysLength;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(msg.sender == _owner,"This method must called by owner");
        safeTransferFrom(from, to, tokenId, 1, "");
    }

    function buyCardPack() public payable{
        require(msg.value >= 10,"no enough money");
        packTo.transfer(msg.value);
        // return makeCard(msg.sender);
    }

    function getRandomCardEntrys(uint[] memory cardEntrys) internal view returns (uint[] memory){
        uint[] memory inCardEntrys = new uint[](_entrysLength);
        uint curIndex = 0;
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        for (uint i = 0; i < cardEntrys.length; ++i) {
            if (curIndex >= (_entrysLength -1)){
                break;
            }
            if ((randomHash % cardEntrys[i]) > cardEntrys[i] / 2){
                inCardEntrys[curIndex] = cardEntrys[i];
                curIndex++;
            }
        }
        return inCardEntrys;
    }

    function createCard(uint cardType,uint[] memory cardEntrys) public payable{
        require(msg.value >= 100000000000000,"no enough money");
        packTo.transfer(msg.value);
        uint tokenId = nextTokenId();
        uint[] memory cardTypes = new uint[](3);
        cardTypes[0] = cardType;
        if (cardEntrys.length > 0){
            _createCard(msg.sender,tokenId,cardTypes,getRandomCardEntrys(cardEntrys),"");
        }else{
            _createCard(msg.sender,tokenId,cardTypes,getRandomCardEntrys(_entrys),"");
        }
        emit CardCreated(msg.sender,tokenId);
    }

    function useCard(uint[] memory useCardPip) public{
        require(MiracleDustToken != MiracleDust(address(0)), "miracle dust token not set");

        uint addDustNum = 0;
        for (uint index = 0; index < useCardPip.length; index++) {
            (        
            uint256 id,
            uint star,
            // 剩余粉尘
            uint tokenVal,
            uint[] memory cardType,
            // 词条
            uint[] memory cardEntrys,
            bytes32 tokenUri,
            address ownerAddress
            ) = getToken(useCardPip[index]);
            require(ownerAddress == msg.sender,"Insufficient permissions");
            require(tokenVal >= star*useCast, "Not enough numbers");
            uint newVal = tokenVal - star*useCast;

            addDustNum = star * useCast * useCastProportion / 100;
            setTokenValue(id,star,newVal,cardType,cardEntrys,tokenUri);
        }
        if(addDustNum>0){
            MiracleDustToken.addDust(msg.sender,addDustNum); 
        }
    }

    function rechargeCardUseDust(uint tokenId, uint num) public{
        require(MiracleDustToken != MiracleDust(address(0)), "miracle dust token not set");
        require(num > 0,"Recharge amount must be greater than 0");
        (        
            uint256 id,
            uint star,
            // 剩余粉尘
            uint tokenVal,
            uint[] memory cardType,
            // 词条
            uint[] memory cardEntrys,
            bytes32 tokenUri,
            address ownerAddress
        ) = getToken(tokenId);
        MiracleDustToken.BurnFromRechargeCard(msg.sender, num);
        uint newVal = tokenVal + num;

        setTokenValue(id,star,newVal,cardType,cardEntrys,tokenUri);
    }

    function rechargeCards(uint[] memory cards,uint[] memory rechargeNums) public{
        require(MiracleDustToken != MiracleDust(address(0)), "miracle dust token not set");
        require(cards.length == rechargeNums.length, "Array lengths are not equal");
        uint needDust = 0;
        for (uint index = 0; index < rechargeNums.length; index++) {
            needDust += rechargeNums[index];
        }
        require(needDust > 0, "Recharge amount must be greater than 0");
        MiracleDustToken.BurnFromRechargeCard(msg.sender, needDust);
        for (uint index = 0; index < cards.length; index++) {
            (        
                uint256 id,
                uint star,
                // 剩余粉尘
                uint tokenVal,
                uint[] memory cardType,
                // 词条
                uint[] memory cardEntrys,
                bytes32 tokenUri,
                address ownerAddress
            ) = getToken(cards[index]);
            uint newVal = tokenVal + rechargeNums[index];
            setTokenValue(id,star,newVal,cardType,cardEntrys,tokenUri);
        }
    }
}
