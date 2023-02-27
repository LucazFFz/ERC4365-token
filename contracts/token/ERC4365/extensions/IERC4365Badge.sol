// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC4365.sol";
import "./ERC4365Badge.sol";

/**
 * @dev Proposal of an interface for ERC-4365 tokens with support for ERC-1238 badge tokens.
 * 
 * This extension makes it possible to associate  tokens with ERC-1238 tokens (badges) by
 * storing one or multiple references to ERC-1238 contracts and ids for each unique token. 
 * 
 * This makes it easy to for example limit which account is able to mint tokens depending
 * on which ERC-1238 badges they have. Additionally, accounts possessing specific badges can
 * receive discounts when minting tokens. 
 */
interface IERC4365Badge is IERC4365 {
    /**
     * @dev Adds an ERC-1238 token reference `badge_` with id `badgeId` for the token of token type `id`.
     *
     * Requirements:
     * - `badge_.contract_` must implement the IERC1238 interface.
     */
    function addBadge(uint256 tokenId, uint256 badgeId, Badge memory badge_) external;

    /**
     * @dev Adds a batch of ERC-1238 token references `badges` with ids `badgeIds` 
     * for the token of token type `tokenId`.
     *
     * Requirements:
     * - `badgeIds` and `badges` must have the same length.
     */
    function addBadgesBatch(uint256 tokenId, uint256[] memory badgeIds, Badge[] memory badges) external;

    /**
     * @dev Returns the ERC-1238 token reference data with id `badgeId`. 
     */
    function badge(uint256 tokenId, uint256 badgeId) external view returns (Badge memory);

    /**
     * @dev Returns all ERC-1238 token reference data set for token of token type `id`.
     */
    function allBadges(uint256 id) external view returns (Badge[] memory);

    /**
     * @dev Returns the balance of ERC-1238 tokens owned by `account` added to token type `tokenId` 
     * by using the reference data in `tokenId`.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function balanceOfBadge(address account, uint256 tokenId, uint256 badgeId) external view returns (uint256);

    /**
     * @dev Returns the balance of all ERC-1238 tokens owned by `account` added to token type `tokenId`.
     */
    function balanceOfAllBadges(address account, uint256 id) external view returns (uint256[] memory);

    /**
     * @dev Returns the balance of all ERC-1238 tokens owned by `account` added to a batch of token type `ids`.
     */
    function balancesOfAllBadgesBatch(address account, uint256[] memory ids) external view returns (uint256[][] memory);
}