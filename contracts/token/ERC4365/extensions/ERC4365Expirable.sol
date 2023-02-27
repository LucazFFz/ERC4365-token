// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC4365.sol";
import "./IERC4365Expirable.sol";

/**
 * @dev See {IERC1238Expirable}.
 */
abstract contract ERC4365Expirable is IERC4365Expirable, ERC4365 {
    // Optional mapping for token expiry date
    mapping(uint256 => uint256) private _expiryDate;

    /**
     * @dev See {IERC1238Expirable-expiryDate}.
     */
    function expiryDate(uint256 id) public view virtual returns (uint256) {
        uint256 date = _expiryDate[id];

        require(date != 0, "ERC4365Expirable: no expiry date set");

        return date;
    }

    /**
     * @dev See {IERC1238Expirable-isExpired}.
     */
    function isExpired(uint256 id) public view virtual returns (bool) {
        uint256 date = _expiryDate[id];

        require(date != 0, "ERC4365Expirable: no expiry date set");

        return date < block.timestamp;
    }

    function isExpiryDateSet(uint256 id) public view virtual returns(bool) {
        uint256 date = _expiryDate[id];
        if(date != 0) return true;
        return false;
    }

    /**
     * @dev Sets the expiry date for the tokens with id `id`.
     * Requirements:
     * - The new date must be after the current expiry date.
     */
    function _setExpiryDate(uint256 id, uint256 date) internal virtual {
        require(date > block.timestamp, "ERC4365Expirable: expiry date cannot be in the past");
        require(date > _expiryDate[id], "ERC4365Expirable: expiry date can only be extended");

        _expiryDate[id] = date;
    }

    /**
     * @dev [Batched] version of {_setExpiryDate}.
     */
    function _setBatchExpiryDates(uint256[] memory ids, uint256[] memory dates) internal {
        require(ids.length == dates.length, "ERC4365Expirable: ids and token URIs length mismatch");

        for (uint256 i = 0; i < ids.length; i++) {
            _setExpiryDate(ids[i], dates[i]);
        }
    }

    /**
     * @dev Publicly expose {_setExpiryDate}.
     */
    function setExpiryDate(uint256 id, uint256 date) external virtual {
        _setExpiryDate(id, date);
    }

    /**
     * @dev Publicly expose {_setBatchExpiryDates}.
     */
    function setBatchExpiryDates(uint256[] memory ids, uint256[] memory dates) external virtual {
        _setBatchExpiryDates(ids, dates);
    }
}