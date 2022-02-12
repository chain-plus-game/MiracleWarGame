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

    uint256[] public _entrys = [1, 2, 3, 4, 5];
    uint256 public _entrysLength = 5;
    uint256 public useCast = 5;
    uint256 public useCastProportion = 50;

    // 铸造卡牌所需金额
    uint256 public createCardCast = 100000000000000;
    // 购买卡包所需金额
    uint256 public buyCardPackCast = 100000000000000;

    MiracleDust private MiracleDustToken;

    mapping(address => bool) private _trustedAddress;

    // 随机卡包的卡面
    bytes32[] public randomPackUris;

    // 创建卡牌得最大星级
    uint256 public maxCardCreateStar = 10;

    // 卡包卡最大星级
    uint256 public maxBuyCardStar = 5;

    // 卡包一次数量
    uint256 public cardPackBuyerNum = 3;

    /** @dev Use ERC-1155 metadata standard for your JSON file & use hexadecimal of your token ID in _file_name.json */

    constructor(address payable payTo, uint256 initDustNum)
        ERC1155("https://nft.fuakorm.com/{id}.json")
    /** @dev If you want tokens to be non-fungible, value must be 1 */
    {
        packTo = payTo;
        _owner = msg.sender;
        _trustedAddress[msg.sender] = true;
        address[] memory owners = new address[](1);
        owners[0] = msg.sender;
        MiracleDustToken = new MiracleDust(
            initDustNum,
            address(this),
            payTo,
            _owner,
            owners
        );
    }

    function getMiracleDustTokenAddress() public view returns (address) {
        return address(MiracleDustToken);
    }

    function setCreateCardCast(uint256 _cast) public {
        require(msg.sender == _owner, "This method must called by owner");
        createCardCast = _cast;
    }

    function setBuyCardPackCast(uint256 _cast) public {
        require(msg.sender == _owner, "This method must called by owner");
        buyCardPackCast = _cast;
    }

    function isTrustedAddress(address _address) public view returns (bool) {
        return _trustedAddress[_address];
    }

    function setTrustedAddress(address _address) public {
        require(msg.sender == _owner, "This method must called by owner");
        _trustedAddress[_address] = true;
    }

    function removeTrustedAddress(address _address) public {
        require(msg.sender == _owner, "This method must called by owner");
        _trustedAddress[_address] = false;
    }

    // 默认位数，即小数点后几位
    function decimals() public view virtual returns (uint8) {
        return 0;
    }

    function setMDT(address mdtAddress) public {
        MiracleDustToken = MiracleDust(mdtAddress);
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _ownerOf(tokenId);
    }

    function setURI(string memory newuri) public {
        require(msg.sender == _owner, "This method must called by owner");
        _setURI(newuri);
    }

    function setEntrys(uint256[] memory entrys) public {
        require(msg.sender == _owner, "This method must called by owner");
        _entrys = entrys;
    }

    function setEntrysLength(uint256 newEntrysLength) public {
        require(msg.sender == _owner, "This method must called by owner");
        _entrysLength = newEntrysLength;
    }

    function setRandomPackUris(bytes32[] memory randomUris) public {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        randomPackUris = randomUris;
    }

    function setMaxCardCreateStar(uint256 _max) public {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        maxCardCreateStar = _max;
    }

    function setMaxBuyCardStar(uint256 _max) public {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        maxBuyCardStar = _max;
    }

    function setCardPackBuyerNum(uint256 _num) public {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        cardPackBuyerNum = _num;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(msg.sender == _owner, "This method must called by owner");
        safeTransferFrom(from, to, tokenId, 1, "");
    }

    function buyCardPack() public payable {
        require(msg.value >= buyCardPackCast, "no enough money");
        packTo.transfer(msg.value);
    }

    function getRandomCardEntrys(uint256[] memory cardEntrys)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory inCardEntrys = new uint256[](_entrysLength);
        uint256 curIndex = 0;
        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        for (uint256 i = 0; i < cardEntrys.length; ++i) {
            if (curIndex >= (_entrysLength - 1)) {
                break;
            }
            if ((randomHash % cardEntrys[i]) > cardEntrys[i] / 2) {
                inCardEntrys[curIndex] = cardEntrys[i];
                curIndex++;
            }
        }
        return inCardEntrys;
    }

    function CreateCardByOwner(
        uint256[] memory cardTypes,
        uint256[] memory cardEntrys,
        uint256 star,
        uint256 dust,
        bytes32 cardUri
    ) public {
        require(msg.sender == _owner, "This method must called by owner");
        _createCardByOwner(cardTypes, cardEntrys, star, dust, cardUri);
    }

    function createCard(uint256 cardType, uint256[] memory cardEntrys)
        public
        payable
    {
        require(msg.value >= createCardCast, "no enough money");
        packTo.transfer(msg.value);
        uint256 tokenId = nextTokenId();
        uint256[] memory cardTypes = new uint256[](3);
        cardTypes[0] = cardType;
        if (cardEntrys.length > 0) {
            _createCard(
                msg.sender,
                tokenId,
                cardTypes,
                getRandomCardEntrys(cardEntrys),
                "",
                maxCardCreateStar
            );
        } else {
            _createCard(
                msg.sender,
                tokenId,
                cardTypes,
                getRandomCardEntrys(_entrys),
                "",
                maxCardCreateStar
            );
        }
        emit CardCreated(msg.sender, tokenId);
    }

    function useCard(uint256[] memory useCardPip) public {
        require(
            MiracleDustToken != MiracleDust(address(0)),
            "miracle dust token not set"
        );

        uint256 addDustNum = 0;
        for (uint256 index = 0; index < useCardPip.length; index++) {
            (
                uint256 id,
                uint256 star,
                // 剩余粉尘
                uint256 tokenVal,
                uint256[] memory cardType,
                // 词条
                uint256[] memory cardEntrys,
                bytes32 tokenUri,
                address ownerAddress
            ) = getToken(useCardPip[index]);
            require(ownerAddress == msg.sender, "Insufficient permissions");
            require(tokenVal >= star * useCast, "Not enough numbers");
            uint256 newVal = tokenVal - star * useCast;

            addDustNum = (star * useCast * useCastProportion) / 100;
            setTokenValue(id, star, newVal, cardType, cardEntrys, tokenUri);
        }
        if (addDustNum > 0) {
            MiracleDustToken.addDust(msg.sender, addDustNum);
        }
    }

    function rechargeCardUseDust(uint256 tokenId, uint256 num) public {
        require(
            MiracleDustToken != MiracleDust(address(0)),
            "miracle dust token not set"
        );
        require(num > 0, "Recharge amount must be greater than 0");
        (
            uint256 id,
            uint256 star,
            // 剩余粉尘
            uint256 tokenVal,
            uint256[] memory cardType,
            // 词条
            uint256[] memory cardEntrys,
            bytes32 tokenUri,

        ) = getToken(tokenId);
        MiracleDustToken.BurnFromRechargeCard(msg.sender, num);
        uint256 newVal = tokenVal + num;

        setTokenValue(id, star, newVal, cardType, cardEntrys, tokenUri);
    }

    function rechargeCards(
        uint256[] memory cards,
        uint256[] memory rechargeNums
    ) public {
        require(
            MiracleDustToken != MiracleDust(address(0)),
            "miracle dust token not set"
        );
        require(
            cards.length == rechargeNums.length,
            "Array lengths are not equal"
        );
        uint256 needDust = 0;
        for (uint256 index = 0; index < rechargeNums.length; index++) {
            needDust += rechargeNums[index];
        }
        require(needDust > 0, "Recharge amount must be greater than 0");
        MiracleDustToken.BurnFromRechargeCard(msg.sender, needDust);
        for (uint256 index = 0; index < cards.length; index++) {
            (
                uint256 id,
                uint256 star,
                // 剩余粉尘
                uint256 tokenVal,
                uint256[] memory cardType,
                // 词条
                uint256[] memory cardEntrys,
                bytes32 tokenUri,

            ) = getToken(cards[index]);
            uint256 newVal = tokenVal + rechargeNums[index];
            setTokenValue(id, star, newVal, cardType, cardEntrys, tokenUri);
        }
    }
}
