// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC4365.sol";
import "./IERC4365Payable.sol";

abstract contract ERC4365Payable is IERC4365Payable, ERC4365 {
    mapping(uint256 => uint256) private _price;

    function price(uint256 id) public view virtual returns (uint256) {
        uint256 amount = _price[id];
        require(amount != 0, "ERC4365Pay: no price set");
        return amount;
    }

    function setPrice(uint256 id, uint256 amount) external virtual {
        _setPrice(id, amount);
    }

    function setBatchPrices(uint256[] memory ids, uint256[] memory amounts) external virtual {
        _setBatchPrices(ids, amounts);
    }

    function isPriceSet(uint256 id) public view virtual returns (bool) {
        uint256 amount = _price[id];
        if(amount != 0) return true;
        return false;
    }

    function _setPrice(uint256 id, uint256 amount) internal virtual {
        _price[id] = amount;
    }

    function _setBatchPrices(uint256[] memory ids, uint256[] memory amounts) internal {
        require(ids.length == amounts.length, "ERC4365Supply: ids and amounts length mismatch");

        for (uint256 i = 0; i < ids.length; i++) {
            _setPrice(ids[i], amounts[i]);
        }
    }
}