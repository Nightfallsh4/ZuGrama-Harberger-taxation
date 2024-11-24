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
        uint256 value;
        uint64 validFrom;
        uint64 validTill;
        uint64 updatedAt;
    }

    address public immutable auction;
    address public immutable admin;
    IERC20 immutable USDC;

    uint256 public taxRate; //Tax Rate. Is in 6 decimals. Where 100% = 1000000

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
        harbergerDetails.updatedAt = _validFrom; // Conversion to uint64 not risky since time will not exceed uint64
        harbergerDetails.validTill = _validTill;
        harbergerDetails.value = _initialValue;
        assetToHarberger[_asset][_assetId] = harbergerDetails;

        uint256 tax = getTotalTaxForValue(_initialValue);
        // @follow-up initial Value Can be winning Bid??
        USDC.safeTransferFrom(auction, address(this), tax + _initialValue); //@follow-up have to calculate the entire
            // tax owed and move it here

        SBT(_asset).mint(_bidder, _assetId);
    }

    function startBuyout(address _asset, uint256 _assetId) external { }

    function completeBuyOut(address _asset, uint256 _assetId) external { }

    function matchBuyOut(address _asset, uint256 _assetId) external { }

    function setTaxRate(uint256 _taxRate) external onlyAdmin {
        if (_taxRate > 1_000_000) {
            revert Harberger_CantExceed100Percent();
        }
        taxRate = _taxRate;
    }

    function getTotalTaxForValue(uint256 _value) public view returns (uint256 tax) {
        //@follow-up work on this
        tax = (_value * taxRate) / 1_000_000; // Value is USD i.e 6 decimals and taxRate is also 6 decimals
    }

    function getTaxOwedTillNow(address _asset, uint256 _assetId) public view returns (uint256 taxOwed) {
        HarbergerDetails memory harbergerDetails = getHarbegerDetails(_asset, _assetId);

        // tax Owed till now = totalTaxForPeriod * (currentTime / totalTimePeriod)
        uint256 totalTax = getTotalTaxForValue(harbergerDetails.value);

        uint64 timePeriod = harbergerDetails.validTill - harbergerDetails.updatedAt;
        taxOwed = (uint64(block.timestamp) * totalTax) / timePeriod;
    }

    function getCurrentValueOfAsset(address _asset, uint256 _assetId) public view returns (uint256 currentValue) {
        HarbergerDetails memory harbergerDetails = getHarbegerDetails(_asset, _assetId);

        // Current Value of assets is function of the time period. Value decrease linearly with time
        // Current Value of asset = (currentTime / totalTimePeriod ) * initialValue
        uint64 timePeriod = harbergerDetails.validTill - harbergerDetails.updatedAt;
        currentValue = (uint64(block.timestamp) * harbergerDetails.value) / timePeriod;
    }

    function getHarbegerDetails(address _asset, uint256 _assetId) public view returns (HarbergerDetails memory) {
        return assetToHarberger[_asset][_assetId];
    }
}
