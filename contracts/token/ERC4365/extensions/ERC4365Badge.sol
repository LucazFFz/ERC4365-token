// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC4365Badge.sol";
import "../../ERC1238/IERC1238.sol";
import "../../ERC1238/ERC1238.sol";
import "../ERC4365.sol";

// [0, 0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B, ["0x05"]]

struct Badge {
    uint256 id;
    address contract_;
    bytes[] data;
}


abstract contract ERC4365Badge is IERC4365Badge, ERC4365 {

    mapping(uint256 => uint256[]) private _ids;
    mapping(uint256 => mapping(uint256 => Badge)) private _badges;

    function balanceOfBadge(address account, uint256 tokenId, uint256 badgeId) public view virtual returns (uint256) {
        require(account != address(0), "ERC4365: address zero is not a valid owner");

        uint256 id = _badges[tokenId][badgeId].id;
        address contract_ = _badges[tokenId][badgeId].contract_;

        return ERC1238(contract_).balanceOf(account, id);
    }

    function balanceOfAllBadges(address account, uint256 id) public view virtual returns (uint256[] memory) {
        uint256 idsLength = _ids[id].length;
        uint256[] memory balances = new uint256[](idsLength);

        for(uint256 i = 0; i < idsLength; i++) {
            balances[i] = balanceOfBadge(account, id, _ids[id][i]);
        }

        return balances;
    }

    function balancesOfAllBadgesBatch(address account, uint256[] memory ids) public view virtual returns (uint256[][] memory) {
        uint256 idsLength = ids.length;
        uint256[][] memory batchBalances = new uint256[][](idsLength); 

        for(uint256 i = 0; i < idsLength; i++) {
            batchBalances[i] = balanceOfAllBadges(account, ids[i]);
        }

        return batchBalances;
    }

    function badge(uint256 tokenId, uint256 badgeId) public view returns (Badge memory) {
        require(isBadgeSet(tokenId, badgeId), "ERC4365Badge: no badge set");

        return _badges[tokenId][badgeId];
    }

    function allBadges(uint256 id) public view returns (Badge[] memory) {
        uint256 idsLength = _ids[id].length;
        Badge[] memory badges = new Badge[](idsLength);

        for(uint256 i = 0; i < idsLength; i++) {
            badges[i] = badge(id, _ids[id][i]);
        }

        return badges;
    }

    function addBadge(uint256 tokenId, uint256 badgeId, Badge memory badge_) external virtual {
        _addBadge(tokenId, badgeId, badge_);
    }

    function addBadgesBatch(uint256 tokenId, uint256[] memory badgeIds, Badge[] memory badges) external virtual {
        _addBadgesBatch(tokenId, badgeIds, badges);
    }

    function isBadgeSet(uint256 tokenId, uint256 badgeId) public view virtual returns (bool) {
        if(_badges[tokenId][badgeId].contract_ != address(0)) return true;
        return false;
    }

    function isAnyBadgeSet(uint256 id) public view virtual returns (bool) {
        if(_ids[id].length > 0) return true;
        return false;
    }

    function _addBadge(uint256 tokenId, uint256 badgeId, Badge memory badge_) internal virtual {
        require(IERC1238(badge_.contract_).
            supportsInterface(type(IERC1238).interfaceId), 
            "ERC4365Badge: contract does not implement IERC1238 interface");

        _badges[tokenId][badgeId] = badge_;
        _ids[tokenId].push(badgeId);
    }

    function _addBadgesBatch(uint256 tokenId, uint256[] memory badgeIds, Badge[] memory badges) internal {
        require(badgeIds.length == badges.length, "ERC4365Badge: badgeIds and badges length mismatch");

        for(uint256 i = 0; i < badgeIds.length; i++) {
            _addBadge(tokenId, badgeIds[i], badges[i]);
        }
    }
}