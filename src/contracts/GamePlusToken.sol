// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract GamePlusToken is ERC20 {
    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private _tokenAddress;

    uint256 public DividendNum = 0;

    // okt 1个币开始分红
    uint256 public DividendBeginNum = 10**18;

    // 这里是构造函数, 实例创建时候执行
    constructor(uint256 initialSupply) ERC20("GamePlusToken", "GPT") {
        uint256 _totalSupply = initialSupply * 10**uint256(decimals()); // 这里确定了总发行量
        _mint(msg.sender, _totalSupply);
    }

    event dividendUserAdd(address indexed toAddress);

    function decimals() public view virtual override returns (uint8) {
        return 10;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _tokenAddress.add(uint256(uint160(to)));
        emit dividendUserAdd(to);
    }

    function poolNum() public view returns(uint256){
        return address(this).balance;
    }

    receive() external payable {}

    event DividendsTo(address indexed toAddress, uint256 dividendsNum,uint256 lastPool);
    event heldNumEvent(address indexed formAddress,uint256 held);
    event curBalanceEvent(address indexed formAddress,uint256 dividend,uint256 cur);

    function TryDividends() public {
        uint256 thisBalance = address(this).balance;
        require(thisBalance >= DividendBeginNum,"There is not enough money in the current prize pool");
        uint256 curBalance = thisBalance;
        uint256 totalSupply = totalSupply();
        for (uint256 index = 0; index < _tokenAddress.length(); index++) {
            address dividendTo = address(uint160(_tokenAddress.at(index)));
            uint256 heldNum = balanceOf(dividendTo);
            if (heldNum > 0) {
                uint256 dividendNum = heldNum * (thisBalance / totalSupply);
                if (dividendNum > 0){
                    emit heldNumEvent(dividendTo, heldNum);
                    if (curBalance < dividendNum){
                        break;
                    }
                    curBalance -= dividendNum;
                    payable(dividendTo).transfer(dividendNum);
                    emit DividendsTo(dividendTo, dividendNum, curBalance);
                }
            }
        }
    }
}
