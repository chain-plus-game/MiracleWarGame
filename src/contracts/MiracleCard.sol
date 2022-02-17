// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "./GamePlusToken.sol";
import "./ERC1155CardGame.sol";
import "./MiracleDust.sol";

/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract MiracleCard is ERC1155 {
    address payable packTo;
    /** @dev  Replace "TOKEN" with your token name & "_XXXX_" with your token symbol */
    string public name = "MiracleNFT";
    string public symbol = "MiracleNFT";

    uint256 public cardMaxType = 3;
    uint256[] public _entrys = [1, 2, 3, 4, 5];
    uint256 public _entrysLength = 5;
    uint256 public useCast = 5;
    uint256 public useCastProportion = 50;

    // 铸造卡牌所需金额
    uint256 public createCardCast = 1000000000000000;
    // 购买卡包所需金额
    uint256 public buyCardPackCast = 1000000000000000;

    MiracleDust private MiracleDustToken;
    GamePlusToken public payToToken;

    // 随机卡包的卡面
    mapping(uint256 => string) public buyerPackUris;

    // 创建卡牌得最大星级
    uint256 public maxCardCreateStar = 10;

    // 卡包卡最大星级
    uint256 public maxBuyCardStar = 5;

    /** @dev Use ERC-1155 metadata standard for your JSON file & use hexadecimal of your token ID in _file_name.json */

    constructor(address payable payTo)
        ERC1155("https://nft.fuakorm.com/{id}.json")
    /** @dev If you want tokens to be non-fungible, value must be 1 */
    {
        packTo = payTo;
        payToToken = GamePlusToken(payTo);
        setTrustedAddress(owner());
    }

    function getPayTo() public view returns (address) {
        return packTo;
    }

    function setMiracleDust(address tokenAddress) public onlyOwner {
        MiracleDustToken = MiracleDust(tokenAddress);
    }

    function getMiracleDustTokenAddress() public view returns (address) {
        return address(MiracleDustToken);
    }

    function setCreateCardCast(uint256 _cast) public onlyOwner {
        createCardCast = _cast;
    }

    function setBuyCardPackCast(uint256 _cast) public onlyOwner {
        buyCardPackCast = _cast;
    }

    function setCardMaxType(uint256 maxType) public {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        cardMaxType = maxType;
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

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setEntrys(uint256[] memory entrys) public onlyOwner {
        _entrys = entrys;
    }

    function setEntrysLength(uint256 newEntrysLength) public onlyOwner {
        _entrysLength = newEntrysLength;
    }

    function setRandomPackUris(uint256 cardType, string memory randomUris)
        public
    {
        require(
            isTrustedAddress(msg.sender),
            "This method must called by trusted"
        );
        buyerPackUris[cardType] = randomUris;
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

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyOwner {
        safeTransferFrom(from, to, tokenId, 1, "");
    }

    function buyCardPack() public payable {
        require(msg.value >= buyCardPackCast, "no enough money");
        packTo.transfer(msg.value);
        // TODO 根据所有卡牌类型，随机一张卡
        for (uint256 index = 1; index < cardMaxType; index++) {
            uint256[] memory cardTypes = new uint256[](3);
            cardTypes[0] = index;
            uint tokenId = nextTokenId();
            _createCard(
                msg.sender,
                tokenId,
                cardTypes,
                getRandomCardEntrys(_entrys),
                buyerPackUris[index],
                maxCardCreateStar
            );
            emit CardCreated(msg.sender, tokenId);
        }
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
        string memory cardUri
    ) public onlyOwner {
        _createCardByOwner(cardTypes, cardEntrys, star, dust, cardUri);
    }

    function createCard(
        uint256 cardType,
        uint256[] memory cardEntrys,
        string memory tokenUri
    ) public payable {
        require(msg.value >= createCardCast, "no enough money");
        require(cardType <= cardMaxType, "not have this card type");
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
                tokenUri,
                maxCardCreateStar
            );
        } else {
            _createCard(
                msg.sender,
                tokenId,
                cardTypes,
                getRandomCardEntrys(_entrys),
                tokenUri,
                maxCardCreateStar
            );
        }
        emit CardCreated(msg.sender, tokenId);
    }

    function lockCardDust(
        uint256[] memory useCards,
        uint256[] memory lockVal,
        address lockTo
    ) public {
        require(
            isTrustedAddress(lockTo),
            "The destination address must be a trusted address"
        );
        require(useCards.length == lockVal.length, "length must be equal");
        uint256 addDustNum = 0;
        for (uint256 index = 0; index < useCards.length; index++) {
            (
                uint256 id,
                uint256 star,
                // 剩余粉尘
                uint256 tokenVal,
                uint256[] memory cardType,
                // 词条
                uint256[] memory cardEntrys,
                string memory tokenUri,
                address ownerAddress
            ) = getToken(useCards[index]);
            require(ownerAddress == msg.sender, "Insufficient permissions");
            require(tokenVal > lockVal[index], "Not enough numbers");
            addDustNum += lockVal[index];
            uint256 newVal = tokenVal - lockVal[index];
            setTokenValue(id, star, newVal, cardType, cardEntrys, tokenUri);
        }
        require(addDustNum > 0, "lock value Quantity must be greater than 0");
        MiracleDustToken.addDust(lockTo, addDustNum);
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
                string memory tokenUri,
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
            string memory tokenUri,

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
                string memory tokenUri,

            ) = getToken(cards[index]);
            uint256 newVal = tokenVal + rechargeNums[index];
            setTokenValue(id, star, newVal, cardType, cardEntrys, tokenUri);
        }
    }

    function cardCanUse(address fromAddress, uint256[] memory ids)
        public
        view
        returns (bool)
    {
        for (uint256 index = 0; index < ids.length; index++) {
            (
                ,
                ,
                // 剩余粉尘
                uint256 tokenVal,
                ,
                ,
                ,
                address cardOwner
            ) = getToken(ids[index]);
            if (cardOwner != fromAddress) {
                return false;
            }
            if (tokenVal <= 0) {
                return false;
            }
        }
        return true;
    }
}
