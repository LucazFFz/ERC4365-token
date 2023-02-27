// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../token/ERC4365/ERC4365.sol";
import "../token/ERC4365/extensions/ERC4365Badge.sol";

contract Ticket is ERC4365, ERC4365Badge {

    uint256 public constant REQUIERD_VALUE_INDEX = 0;
    uint256 public constant TYPE_INDEX = 1;

    constructor(string memory baseURI_) ERC4365(baseURI_) {}

    function mint(uint256 id, uint256 amount) external payable {

        uint256 balance = balanceOfBadge(_msgSender(), id, 0);
        Badge memory badge = badge(id, 0);

        uint256 value = _bytesToUint(badge.data[REQUIERD_VALUE_INDEX]);

        require(balance >= value, "not enough");

        _mint(_msgSender(), id, amount, "");
    }

    function mint(address to, uint256 id, uint256 amount) external {
        _mint(to, id, amount, "");
    }

    function _bytesToUint(bytes memory b) internal pure returns (uint256){
        uint256 number;

        for(uint i=0;i<b.length;i++){
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }

        return number;
    }
}