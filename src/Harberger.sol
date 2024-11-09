// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "src/utils/Errors.sol";
import "src/utils/Events.sol";
import { SBT } from "src/SBT.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Harberger {
    using SafeERC20 for IERC20;

    struct HarbergerDetails {
        uint256 currentValue;
        uint64 validFrom;
        uint64 validTill;
    }

    address public immutable auction;
    address public immutable admin;
    IERC20 immutable USDC;

    uint256 public taxRate; //Tax Rate per second. ie USD per second of owning the asset

    mapping(address asset => mapping(uint256 assetId => HarbergerDetails)) private assetToHarberger;

    constructor(address _admin, address _auction, address _usdc) {
        auction = _auction;
        admin = _admin;
        USDC = IERC20(_usdc);
    }

    modifier onlyAuction() {
        if (msg.sender != auction) {
            revert Harberger_NotAuction();
        }
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert Harberger_NotAdmin();
        }
        _;
    }

    function initialMint(
        address _asset,
        uint256 _assetId,
        uint64 _validFrom,
        uint64 _validTill,
        address _bidder,
        uint256 _initialValue
    )
        external
        onlyAuction
    {
        HarbergerDetails memory harbergerDetails = getHarbegerDetails(_asset, _assetId);

        if (harbergerDetails.validFrom != 0) {
            revert Harberger_AssetAlreadyExists();
        }

        harbergerDetails.validFrom = _validFrom;
        harbergerDetails.validTill = _validTill;
        harbergerDetails.currentValue = _initialValue;
        assetToHarberger[_asset][_assetId] = harbergerDetails;

        uint256 tax = getTotalTaxForValue(_initialValue);

        // USDC.safeTransferFrom(_bidder) @follow-up have to calculate the entire tax owed and move it here

        SBT(_asset).mint(_bidder, _assetId);
    }

    function setTaxRate(uint256 _taxRate) external onlyAdmin {
        taxRate = _taxRate;
    }

    function getTotalTaxForValue(uint256 _value) public returns (uint256 tax) {
        //@follow-up work on this
        tax = _value * taxRate;
    }

    function getHarbegerDetails(address _asset, uint256 _assetId) public view returns (HarbergerDetails memory) {
        return assetToHarberger[_asset][_assetId];
    }
}
