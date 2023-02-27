// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "./IERC4365Receiver.sol";
import "../../utils/introspection/ERC165.sol";
import "./IERC4365.sol";

contract ERC4365 is Context, ERC165, IERC4365 {
    using Address for address;

    // id => (account => balance)
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // id => (account => redeemed)
    mapping(uint256 => mapping(address => uint256)) private _redeemed;

    string private _baseURI;

    constructor(string memory baseURI_) {
        _setBaseURI(baseURI_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC4365).interfaceId || super.supportsInterface(interfaceId);
    }

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    function identifier() public pure returns (bytes4) {
        return type(IERC4365).interfaceId;
    }

    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        require(account != address(0), "ERC4365: address zero is not a valid owner");
        return _balances[id][account];
    }

    function balanceOfBatch(address account, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        uint256 idsLength = ids.length;
        uint256[] memory batchBalances = new uint256[](idsLength);

        for (uint256 i = 0; i < idsLength; ++i) {
            batchBalances[i] = balanceOf(account, ids[i]);
        }

        return batchBalances;
    }

    function balanceOfBundle(address[] memory accounts, uint256[][] memory ids)
        public
        view
        virtual
        returns (uint256[][] memory)
    {
        uint256 accountsLength = accounts.length;
        uint256[][] memory bundleBalances = new uint256[][](accountsLength);

        for (uint256 i = 0; i < accountsLength; ++i) {
            bundleBalances[i] = balanceOfBatch(accounts[i], ids[i]);
        }

        return bundleBalances;
    }

    function balanceOfRedeemed(address account, uint256 id) public view virtual returns (uint256) {
        require(account != address(0), "ERC4365: address zero is not a valid owner");
        return _redeemed[id][account];
    }

    function balanceOfRedeemedBatch(address account, uint256[] memory ids) 
        public 
        view 
        virtual 
        returns(uint256[] memory) 
    {
        uint256 idsLength = ids.length;
        uint256[] memory batchRedeemed = new uint256[](idsLength);

        for (uint256 i = 0; i < idsLength; ++i) {
            batchRedeemed[i] = balanceOfRedeemed(account, ids[i]);
        }

        return batchRedeemed;
    }

    function balanceOfRedeemedBundle(address[] memory accounts, uint256[][] memory ids) 
        public 
        view 
        virtual 
        returns (uint256[][] memory) 
    {
        uint256 accountsLength = accounts.length;
        uint256[][] memory bundleRedeemed = new uint256[][](accountsLength);

        for (uint256 i = 0; i < accountsLength; ++i) {
            bundleRedeemed[i] = balanceOfRedeemedBatch(accounts[i], ids[i]);
        }

        return bundleRedeemed;
    }

    function _mintBundle(
        address[] calldata to,
        uint256[][] calldata ids,
        uint256[][] calldata amounts,
        bytes[] calldata data
    ) internal virtual {
        uint256 toLength = to.length;
        for (uint256 i = 0; i < toLength; i++) {
           _mintBatch(to[i], ids[i], amounts[i], data[i]);
        }
    }
    
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _redeem(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) internal virtual {
        require(_balances[id][account] >= _redeemed[id][account] + amount, 
            "ERC4365: redeem amount exceeds balance");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeRedeem(operator, account, ids, amounts, data);

        _redeemed[id][account] += amount;
        emit RedeemSingle(operator, account, id, amount);

        _afterRedeem(operator, account, ids, amounts, data);
    }

    function _redeemBatch(
        address account,
        uint256[] memory ids, 
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeRedeem(operator, account, ids, amounts, data);

        for(uint256 i = 0; i < ids.length; i++) {
            require(_balances[ids[i]][account] >= _redeemed[ids[i]][account] + amounts[i], 
                "ERC4365: redeem amount exceeds balance");

            _redeemed[ids[i]][account] += amounts[i];
        }

        emit RedeemBatch(operator, account, ids, amounts);

        _afterRedeem(operator, account, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC4365: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC4365: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC4365: burn from the zero address");
        require(ids.length == amounts.length, "ERC4365: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC4365: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _setBaseURI(string memory newBaseURI) internal virtual {
        _baseURI = newBaseURI;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _beforeRedeem(
        address operator,
        address account, 
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterRedeem(
        address operator,
        address account, 
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC4365Receiver(to).onERC4365Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC4365Receiver.onERC4365Received.selector) {
                    revert("ERC4365: ERC4365Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC4365: transfer to non-ERC4365Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC4365Receiver(to).onERC4365BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC4365Receiver.onERC4365BatchReceived.selector) {
                    
                    revert("ERC4365: ERC4365Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC4365: transfer to non-ERC4365Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
