// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppStorage} from "../libraries/LibAppStorage.sol";

contract ERC721Facet {
    AppStorage internal s;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function name() external view returns (string memory) {
        return s.name;
    }

    function symbol() external view returns (string memory) {
        return s.symbol;
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return s.balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner) {
        owner = s.owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
    }

    function approve(address to, uint256 tokenId) external {
        address owner = s.owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || s.operatorApprovals[owner][msg.sender],
            "ERC721: approve caller is not token owner or approved for all"
        );

        s.tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address operator) {
        require(s.owners[tokenId] != address(0), "ERC721: invalid token ID");
        return s.tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(msg.sender != operator, "ERC721: approve to caller");
        s.operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return s.operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        transferFrom(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = s.owners[tokenId];
        return (spender == owner || s.tokenApprovals[tokenId] == spender || s.operatorApprovals[owner][spender]);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(s.owners[tokenId] == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        delete s.tokenApprovals[tokenId];

        s.balances[from] -= 1;
        s.balances[to] += 1;
        s.owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function initializeERC721(string memory _name, string memory _symbol) external {
        // Basic initialization, can be expanded to check double-init.
        s.name = _name;
        s.symbol = _symbol;
    }

    function mint(address to, uint256 tokenId) external {
        require(to != address(0), "ERC721: mint to the zero address");
        require(s.owners[tokenId] == address(0), "ERC721: token already minted");

        s.balances[to] += 1;
        s.owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
}
