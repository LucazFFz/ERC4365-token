// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Interface proposal for Redeemable tokens.
 * Note: The ERC-165 identifier for this interface is 0xa1ee4fb5. 
 */
interface IERC4365 is IERC165 {
    /**
     * @dev Emitted when `amount` of tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 amount);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    /**
     * @dev Emitted when `amount` of tokens of token type `id` are redeemed in `account` by `operator`.
     */
    event RedeemSingle(address indexed operator, address indexed account, uint256 indexed id, uint256 amount);

    /**
     * @dev Equivalent to multiple {RedeemSingle} events, where `operator` and `account` the same for all
     * transfers.
     */
    event RedeemBatch(address indexed operator, address indexed account, uint256[] indexed ids, uint256[] amounts);

    /**
     * @dev Returns the balance of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev Returns the balance of `account` for a batch of token `ids`.
     */
    function balanceOfBatch(address account, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Returns the balance of multiple `accounts` for a batch of token `ids`.
     * This is equivalent to calling {balanceOfBatch} for several accounts in just one call.
     *
     * Requirements:
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBundle(address[] calldata accounts, uint256[][] calldata ids) 
        external 
        view 
        returns (uint256[][] memory);

    /**
     * @dev Returns the balance of tokens of token type `id` redeemed by `account`.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function balanceOfRedeemed(address account, uint256 id) external view returns (uint256);

    /**
     * @dev Returns the balance of `account` for a batch of redeemed token `ids`.
     */
    function balanceOfRedeemedBatch(address account, uint256[] calldata ids) external view returns (uint256[] memory);

     /**
     * @dev Returns the balance of multiple `accounts` for a batch of redeemed token `ids`.
     * This is equivalent to calling {balanceOfRedeemedBatch} for several accounts in just one call.
     *
     * Requirements:
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfRedeemedBundle(address[] calldata accounts, uint256[][] calldata ids) 
        external 
        view 
        returns (uint256[][] memory);
}