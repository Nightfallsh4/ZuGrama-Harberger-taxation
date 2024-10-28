// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/utils/Errors.sol";

contract SBT is ERC721 {
    address public immutable harberger;

    modifier onlyHarberger() {
        if (msg.sender != harberger) {
            revert SBT_Only_Harberger();
        }
        _;
    }

    constructor(string memory _name, string memory _symbol, address _harberger) ERC721(_name, _symbol) {
        harberger = _harberger;
    }

    function approve(address to, uint256 tokenId) public override onlyHarberger {
        _approve(to, tokenId, _msgSender());
    }

    function setApprovalForAll(address operator, bool approved) public override {
        revert SBT_Function_Disabled();
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyHarberger {
        super.transferFrom(from, to, tokenId);
    }
}
