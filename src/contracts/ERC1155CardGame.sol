// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../lib/EnumerableSet.sol";
import "../lib/EnumerableCardNFT.sol";
import "../lib/Bytes32.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
abstract contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;
    using Bytes32 for bytes32;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableCardNFT for EnumerableCardNFT.UintToAddressMap;
    using EnumerableCardNFT for EnumerableCardNFT.CardEntry;

    EnumerableCardNFT.UintToAddressMap private _tokenOwners;
    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    // bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    // bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) external view override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[id][account];
    }

    function allBalance(address account)
        public
        view
        returns (bytes32[] memory)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _holderTokens[account].all();
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function _balanceOf(address owner) internal view returns (uint256) {
        require(owner != address(0), " balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return
            _tokenOwners.getOwner(tokenId, "owner query for nonexistent token");
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(
                accounts[i] != address(0),
                "ERC1155: batch balance query for the zero address"
            );
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _msgSender() != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][from] = _balances[id][from].sub(
            amount,
            "ERC1155: insufficient balance for transfer"
        );
        _balances[id][to] = _balances[id][to].add(amount);

        _holderTokens[from].remove(id);
        _holderTokens[to].add(id);

        _tokenOwners.setTokenTo(id, to);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);

            _holderTokens[from].remove(id);
            _holderTokens[to].add(id);

            _tokenOwners.setTokenTo(id, to);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][account] = _balances[id][account].add(amount);

        _holderTokens[account].add(id);
        uint256[] memory cardType = new uint256[](1);
        cardType[0] = 1;
        uint256[] memory cardEntrys = new uint256[](1);
        cardEntrys[0] = 1;
        _tokenOwners.set(id, 10, 100, cardType, cardEntrys, "", account);
        ////////////////
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            account,
            id,
            amount,
            data
        );
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);

            _holderTokens[to].add(ids[i]);
            _tokenOwners.setTokenTo(ids[i], to);
            ////////////////
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
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
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
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
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155Receiver(to).onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    function getToken(uint256 tokenId)
        public
        view
        returns (
            uint256 id,
            uint256 star,
            // 剩余粉尘
            uint256 tokenVal,
            uint256[] memory cardType,
            // 词条
            uint256[] memory cardEntrys,
            bytes32 tokenUri,
            address ownerAddress
        )
    {
        EnumerableCardNFT.CardEntry memory card = _tokenOwners.get(
            tokenId,
            "card no find"
        );
        return (
            uint256(card._tokenId),
            card._star,
            card._tokenVal,
            card._cardType,
            card._cardEntrys,
            card._uri,
            card._ownerAddress
        );
    }

    function allTokenIds() public view returns (uint256[] memory) {
        return _tokenOwners.allTokenIds();
    }

    function _createCardByOwner(
        uint256[] memory cardTypes,
        uint256[] memory cardEntrys,
        uint256 star,
        uint256 dust,
        bytes32 cardUri
    ) internal {
        require(msg.sender != address(0), "ERC1155: mint to the zero address");
        uint256 tokenId = nextTokenId();
        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            msg.sender,
            _asSingletonArray(tokenId),
            _asSingletonArray(1),
            ""
        );

        _balances[tokenId][msg.sender] = _balances[tokenId][msg.sender].add(1);

        _holderTokens[msg.sender].add(tokenId);
        _tokenOwners.set(
            tokenId,
            star,
            dust,
            cardTypes,
            cardEntrys,
            cardUri,
            msg.sender
        );
        ////////////////
        emit TransferSingle(operator, address(0), msg.sender, tokenId, 1);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            msg.sender,
            tokenId,
            1,
            ""
        );
    }

    function _createCard(
        address account,
        uint256 id,
        uint256[] memory cardType,
        uint256[] memory cardEntrys,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(1),
            data
        );

        _balances[id][account] = _balances[id][account].add(1);

        _holderTokens[account].add(id);
        uint256 star = randomCardStar();
        _tokenOwners.set(id, star, 100, cardType, cardEntrys, "", account);
        ////////////////
        emit TransferSingle(operator, address(0), account, id, 1);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            account,
            id,
            1,
            data
        );
    }

    event CardCreated(address indexed toAddress, uint256 tokenId);

    function nextTokenId() internal view returns (uint256) {
        return _tokenOwners.length() + 1;
    }

    function setTokenUri(uint256 tokenId, bytes32 tokenUri) public {
        EnumerableCardNFT.CardEntry memory token = _tokenOwners.get(
            tokenId,
            "token not found"
        );
        require(
            token._ownerAddress == _msgSender(),
            "you are not token master"
        );
        require(token._uri == "", "token uri is already in use");

        _tokenOwners.set(
            uint256(token._tokenId),
            token._star,
            token._tokenVal,
            token._cardType,
            token._cardEntrys,
            tokenUri,
            _msgSender()
        );
    }

    function setTokenValue(
        uint256 tokenId,
        uint256 star,
        uint256 tokenValue,
        uint256[] memory cardType,
        uint256[] memory cardEntrys,
        bytes32 tokenUri
    ) public {
        _tokenOwners.set(
            uint256(tokenId),
            star,
            tokenValue,
            cardType,
            cardEntrys,
            tokenUri,
            _msgSender()
        );
    }

    function random() internal view returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        // uint randomHash = uint(keccak256(block.difficulty, block.timestamp));
        return randomHash % 1000;
    }

    function randomCardStar() internal returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        uint256 firstRandom = (randomHash % 1000) + msg.value / 100000000000000;
        if (firstRandom > 1000) {
            firstRandom = 1000;
        }
        return firstRandom / 100;
    }
}
