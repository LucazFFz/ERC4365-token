// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC4365.sol";
import "./IERC4365Supply.sol";

abstract contract ERC4365Supply is IERC4365Supply, ERC4365 {
    mapping(uint256 => uint256) private _totalSupply;

    mapping(uint256 => uint256) private _maxSupply;

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    function maxSupply(uint256 id) public view virtual returns (uint256) {
        uint256 max = _maxSupply[id];
        require(max != 0, "ERC4365Supply: no maxSupply set");
        return max;
    }

    function setMaxSupply(uint256 id, uint256 amount) external virtual {
        _setMaxSupply(id, amount);
    }

    function setBatchMaxSupplies(uint256[] memory ids, uint256[] memory amounts) external virtual {
        _setBatchMaxSupplies(ids, amounts);
    }

    function isMaxSupplySet(uint256 id) public view returns (bool) {
        uint256 max = _maxSupply[id];
        if(max != 0) return true;
        return false;
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return ERC4365Supply.totalSupply(id) > 0;
    }

    function _setMaxSupply(uint256 id, uint256 amount) internal virtual {
        _maxSupply[id] = amount;
    }

    function _setBatchMaxSupplies(uint256[] memory ids, uint256[] memory amounts) internal {
        require(ids.length == amounts.length, "ERC4365Supply: ids and amounts length mismatch");

        for (uint256 i = 0; i < ids.length; i++) {
            _setMaxSupply(ids[i], amounts[i]);
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        // mint token
        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        // burn token
        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];

                require(supply >= amount, "ERC4365: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}
